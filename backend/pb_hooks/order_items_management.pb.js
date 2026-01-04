/// <reference path="../pb_data/types.d.ts" />


// ==================================================================
// CUSTOM API ENDPOINTS
// ==================================================================

routerAdd("POST", "/api/custom/update-order-item-status", (c) => {
    const data = new DynamicModel({ "new_status": "", "items": [] });
    c.bindBody(data);

    if (!data.new_status || !data.items || data.items.length === 0) {
        throw new BadRequestError("Dati mancanti: status o items vuoti.");
    }

    try {
        $app.runInTransaction((txApp) => {
            const ids = data.items;
            for (let id of ids) {
                const record = txApp.findRecordById("order_items", id);
                record.set("status", data.new_status);

                if(data.new_status === "fired") {
                    record.set("fired_at", new Date());
                }

                txApp.save(record);
            }
        });

        return c.json(200, { "success": true, "message": "Items aggiornati." });
    } catch (err) {
        throw new BadRequestError("Errore update batch: " + err.message);
    }
});

routerAdd("POST", "/api/custom/edit-order-item", (c) => {
    const data = new DynamicModel({
        "item_id": "",
        "edited_quantity": 0,
        "new_notes": "",
        "new_removed_ingredients": [],
        "new_selected_extras": [],
        "new_course": "",
    });
    c.bindBody(data);

    if (!data.item_id || data.edited_quantity <= 0) {
        throw new BadRequestError("Dati mancanti o invalidi.");
    }

    let operationType = "";

    try {
        $app.runInTransaction((txApp) => {
            const originalItem = txApp.findRecordById("order_items", data.item_id);
            const originalQuantity = originalItem.getInt("quantity");

            if (data.edited_quantity > originalQuantity) {
                throw new BadRequestError("Quantità eccessiva.");
            }

            // CASO 1: Modifica Totale (UPDATE)
            if (data.edited_quantity === originalQuantity) {
                operationType = "update";
                originalItem.set("notes", data.new_notes);
                originalItem.set("course", data.new_course);
                originalItem.set("selected_extras", data.new_selected_extras);
                originalItem.set("removed_ingredients", data.new_removed_ingredients);

                txApp.save(originalItem);

            }
            // CASO 2: Split (Divisione)
            else {
                operationType = "split";
                const remainingQuantity = originalQuantity - data.edited_quantity;

                // Riduciamo vecchio
                originalItem.set("quantity", remainingQuantity);
                txApp.save(originalItem);

                // Creiamo nuovo
                const collection = txApp.findCollectionByNameOrId("order_items");
                const newRecord = new Record(collection);

                newRecord.set("order", originalItem.get("order"));
                newRecord.set("menu_item", originalItem.get("menu_item"));
                newRecord.set("menu_item_name", originalItem.get("menu_item_name"));
                newRecord.set("price_each", originalItem.get("price_each"));
                newRecord.set("status", originalItem.get("status"));
                newRecord.set("requires_firing", originalItem.get("requires_firing"));

                newRecord.set("quantity", data.edited_quantity);
                newRecord.set("notes", data.new_notes);
                newRecord.set("course", data.new_course);
                newRecord.set("selected_extras", data.new_selected_extras);
                newRecord.set("removed_ingredients", data.new_removed_ingredients);

                // controlliamo se il nuovo può essere unito a esistenti
                const utils = require(`${__hooks}/utils.js`);
                const merged = utils.mergeItemIfPossible(newRecord, txApp);
                if (!merged) {
                    txApp.save(newRecord);
                }
            }
        });

        return c.json(200, {
            "success": true,
            "message": operationType === "update" ? "Item aggiornato" : "Item diviso",
        });

    } catch (err) {
        throw new BadRequestError("Errore modifica item: " + err.message);
    }
});

// ==================================================================
// DATABASE HOOKS
// ==================================================================


/**
 * HOOK: onRecordUpdate
 */
onRecordAfterUpdateSuccess((e) => {
    e.next(); // Esegui update standard prima

    console.log(">> Hook UPDATE order_items:", e.record.id);
    const utils = require(`${__hooks}/utils.js`);
    try {
        $app.runInTransaction((txApp) => {
            const currentRecord = txApp.findRecordById("order_items", e.record.id);
            utils.mergeItemIfPossible(currentRecord, txApp);
        });
    } catch (ex) {
        console.warn(`[MERGE UPDATE ERROR] Impossibile processare item ${e.record.id}:`, ex);
    }

}, "order_items");
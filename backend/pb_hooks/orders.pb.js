// pb_hooks/orders.pb.js

routerAdd("POST", "/api/custom/create-order", (c) => {
    // -----------------------------------------------------------
    // 1. LETTURA DATI (c.bind è il metodo sicuro di Echo/PB)
    // -----------------------------------------------------------
    const data = new DynamicModel(
        {
            "session": "",
            "waiter": "",
            "items": []
        }
    );
    c.bindBody(data); // Popola l'oggetto 'data' con il JSON ricevuto

    // Debug
    console.log("Dati ricevuti:", JSON.stringify(data));

    if (!data.session || !data.items || !data.items.length) {
        throw new BadRequestError("Dati mancanti: sessione o items vuoti.");
    }

    let createdOrderRecord;

    try {
        // -----------------------------------------------------------
        // 2. TRANSAZIONE (Niente più DAO!)
        // -----------------------------------------------------------
        // Si usa $app.runInTransaction.
        // 'txApp' è l'istanza dell'app confinata nella transazione.
        $app.runInTransaction((txApp) => {

            // Cerca le collezioni usando txApp
            const orderCollection = txApp.findCollectionByNameOrId("orders");
            const orderItemCollection = txApp.findCollectionByNameOrId("order_items");

            // A. Calcolo Totale
            let totalAmount = 0.0;
            const items = data.items;

            items.forEach((item) => {
                const price = parseFloat(item.price_each) || 0;
                const qty = parseInt(item.quantity) || 1;
                totalAmount += (price * qty);
            });

            // B. Creazione Record Ordine
            // Nota: Record è globale
            const order = new Record(orderCollection);

            // I metodi .set() sono uguali a prima
            order.set("session", data.session);
            if (data.waiter) order.set("waiter", data.waiter);
            order.set("total_amount", totalAmount);

            // SALVATAGGIO: Ora si usa txApp.save(record) invece di saveRecord
            txApp.save(order);

            createdOrderRecord = order;

            // C. Creazione Record Items
            items.forEach((itemData) => {
                const item = new Record(orderItemCollection);
                const menu_item = txApp.findRecordById("menu_items", itemData.menu_item);

                item.set("order", order.id);
                item.set("menu_item", itemData.menu_item);
                item.set("menu_item_name", menu_item.get("name"));
                item.set("price_each", itemData.price_each);
                item.set("quantity", itemData.quantity);
                item.set("notes", itemData.notes);
                let requiresFiring = menu_item.get("produced_by").length > 0;
                item.set("requires_firing", requiresFiring);
                item.set("status", requiresFiring ? "pending" : "ready");
                item.set("course", itemData.course);

                if (itemData.removed_ingredients) {
                    item.set("removed_ingredients", itemData.removed_ingredients);
                }
                if (itemData.selected_extras) {
                    item.set("selected_extras", itemData.selected_extras);
                }

                // Salvataggio item
                txApp.save(item);
            });
        });

        // Ritorna il record creato
        return c.json(200, createdOrderRecord);

    } catch (err) {
        console.error("Errore creazione ordine:", err);
        throw new BadRequestError("Impossibile creare l'ordine: " + err.message);
    }
});
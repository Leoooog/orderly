/// <reference path="../pb_data/types.d.ts" />

// pb_hooks/orders.pb.js

routerAdd("POST", "/api/custom/update-order-item-status", (c) => {

    const data = new DynamicModel(
        {
            "new_status": "",
            "items": []
        }
    );
    c.bindBody(data); // Popola l'oggetto 'data' con il JSON ricevuto

    console.log("Dati ricevuti per update:", JSON.stringify(data));

    if (!data.new_status || !data.items) {
        throw new BadRequestError("Dati mancanti: status o items vuoti.");
    }

    try {
        // -----------------------------------------------------------
        // 2. TRANSAZIONE (Batch Update)
        // -----------------------------------------------------------
        // Usiamo $app.runInTransaction per garantire che:
        // O si aggiornano TUTTI gli items, o NESSUNO (in caso di errore).

        $app.runInTransaction((txApp) => {
            // Iteriamo su ogni ID ricevuto
            // data.items in JSVM viene trattato come un array standard
            const ids = data.items;

            for (let id of ids) {
                // A. Trova il record esistente
                // findRecordById lancia un'eccezione se l'ID non esiste,
                // il che farà abortire automaticamente la transazione (perfetto).
                const record = txApp.findRecordById("order_items", id);

                // B. Aggiorna lo stato
                record.set("status", data.new_status);
                if(data.new_status === "fired") {
                    record.set("fired_at", new Date());
                }

                // C. Salva il record aggiornato
                txApp.save(record);
            }
        });

        // -----------------------------------------------------------
        // 3. RISPOSTA
        // -----------------------------------------------------------
        return c.json(200, {
            "success": true,
            "message": "Items aggiornati con successo."
        });

    } catch (err) {
        console.error("Errore update batch:", err);
        // Ritorniamo un errore chiaro al client (Flutter)
        throw new BadRequestError("Impossibile aggiornare gli items: " + err.message);
    }
});
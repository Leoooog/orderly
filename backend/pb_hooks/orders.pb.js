// pb_hooks/orders.pb.js

routerAdd("POST", "/api/custom/create-order", (c) => {
    // 1. Leggi i dati inviati dal client (Flutter)
    const data = $apis.requestInfo(c).data;

    if (!data.session || !data.items || data.items.length === 0) {
        throw new BadRequestError("Dati mancanti: sessione o items vuoti.");
    }

    const dao = $app.dao();

    let createdOrderRecord;

    // 2. Esegui tutto in una transazione
    dao.runInTransaction((txDao) => {
        const orderCollection = dao.findCollectionByNameOrId("orders");
        const orderItemCollection = dao.findCollectionByNameOrId("order_items");

        // A. Calcola il totale lato server per sicurezza (o usa quello inviato)
        let totalAmount = 0.0;
        data.items.forEach((item) => {
            // Assicuriamoci che price_each e quantity siano numeri
            const price = parseFloat(item.price_each) || 0;
            const qty = parseInt(item.quantity) || 1;
            totalAmount += (price * qty);
        });

        // B. Crea il record "Order"
        const order = new Record(orderCollection);
        order.set("session", data.session);
        order.set("waiter", data.waiter);
        order.set("status", "pending");
        order.set("total_amount", totalAmount);

        // Salva l'ordine usando il DAO della transazione (txDao)
        txDao.saveRecord(order);
        createdOrderRecord = order;

        // C. Crea i record "OrderItem"
        data.items.forEach((itemData) => {
            const item = new Record(orderItemCollection);

            // Collega l'item all'ordine appena creato
            item.set("order", order.id);

            // Mappa i campi
            item.set("menu_item", itemData.menu_item);
            item.set("menu_item_name", itemData.menu_item_name);
            item.set("price_each", itemData.price_each);
            item.set("quantity", itemData.quantity);
            item.set("notes", itemData.notes);
            item.set("status", "pending"); // Default status
            item.set("course", itemData.course);

            // Gestione array di relazioni (assicurati che siano array nel JSON)
            if (itemData.removed_ingredients) {
                item.set("removed_ingredients", itemData.removed_ingredients);
            }
            if (itemData.selected_extras) {
                item.set("selected_extras", itemData.selected_extras);
            }

            txDao.saveRecord(item);
        });
    });

    // 3. Ritorna l'ordine creato (espandi se necessario)
    return c.json(200, createdOrderRecord);
});
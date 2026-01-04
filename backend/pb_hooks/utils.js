/**
 * Confronta due array di stringhe (ID).
 * Restituisce true se contengono gli stessi valori, indipendentemente dall'ordine.
 */
function compareIdArrays(arr1, arr2) {
    const a1 = arr1 || [];
    const a2 = arr2 || [];

    if (a1.length !== a2.length) return false;

    const sorted1 = [...a1].sort();
    const sorted2 = [...a2].sort();

    return sorted1.every((value, index) => value === sorted2[index]);
}


/**
 * Logica CORE di unione items.
 * Cerca duplicati nello stesso contesto (Sessione) e unisce se trova corrispondenza.
 * @param {core.Record} targetItem - L'item che è stato appena creato o aggiornato
 * @param {core.App} txApp - Istanza PocketBase (transazionale)
 */
function mergeItemIfPossible(targetItem, txApp) {
    try {
        // 1. Controllo preliminare: uniamo solo items 'pending'
        if (targetItem.get("status") !== "pending") {
            return;
        }

        const orderId = targetItem.get("order");

        // Recuperiamo l'ordine per risalire alla sessione
        // Usa findRecordById standard, se fallisce lancia eccezione che viene catchata
        const order = txApp.findRecordById("orders", orderId);
        const sessionId = order.get("session");

        // 3. Trova tutti gli ordini della sessione
        const sessionOrders = txApp.findRecordsByFilter("orders", `session = "${sessionId}"`);
        const orderIds = sessionOrders.map(o => o.id);

        if (orderIds.length === 0) return;

        // Costruisci filtro per cercare in tutti gli ordini della sessione
        const orderIdsFilter = orderIds.map(id => `order = "${id}"`).join(" || ");

        // 4. Cerca potenziali duplicati
        // Nota: rimossi i commenti interni per evitare errori di parsing
        const potentialDuplicates = txApp.findRecordsByFilter(
            "order_items",
            `(${orderIdsFilter}) && id != "${targetItem.get("id")}" && menu_item = "${targetItem.get("menu_item")}" && status = "pending"`
        );

        for (const existingItem of potentialDuplicates) {
            // Confronto approfondito
            const areNotesSame = existingItem.get("notes") === targetItem.get("notes");
            const areCoursesSame = existingItem.get("course") === targetItem.get("course");
            const areExtrasSame = compareIdArrays(existingItem.get("selected_extras"), targetItem.get("selected_extras"));
            const areRemovalsSame = compareIdArrays(existingItem.get("removed_ingredients"), targetItem.get("removed_ingredients"));
            console.log(targetItem.get("id"), "vs", existingItem.id);
            if (areNotesSame && areCoursesSame && areExtrasSame && areRemovalsSame) {
                console.log(`[MERGE] Unisco Item Corrente (${targetItem.get("id")}) dentro Esistente (${existingItem.id})`);

                // Calcolo nuova quantità
                const newQuantity = existingItem.getInt("quantity") + targetItem.getInt("quantity");

                // Aggiorno l'item esistente
                existingItem.set("quantity", newQuantity);
                // txApp.delete(targetItem);
                txApp.save(existingItem);
                // Cancello l'item corrente duplicato
                txApp.delete(targetItem);

                return true; // Stop dopo la prima unione
            }
        }
        return false; // Nessuna unione effettuata
    } catch (err) {
        // Logghiamo l'errore ma non blocchiamo l'esecuzione per non far fallire la richiesta HTTP originale
        console.warn(`[MERGE INTERNAL WARNING] Item ${targetItem.get("id")}:`, err);
        return false;
    }
}

module.exports = {
    mergeItemIfPossible: mergeItemIfPossible
};
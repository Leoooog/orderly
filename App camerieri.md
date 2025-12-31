# Documentazione App Cameriere "Orderly"

## Introduzione

Questa documentazione descrive in dettaglio il funzionamento dell'applicazione "Orderly" per camerieri, inclusi i suoi componenti, il flusso di lavoro e le principali funzionalità.  L'app è progettata per facilitare la gestione degli ordini, dei tavoli e dei pagamenti in un ristorante.

## Architettura

L'app è sviluppata in Flutter e utilizza Riverpod per la gestione dello stato e GoRouter per la navigazione.  L'architettura è modulare, con una chiara separazione tra UI, logica di business e gestione dei dati.

### Struttura delle Cartelle

*   `lib/modules/waiter`: Contiene tutto il codice specifico del modulo cameriere.
*   `lib/data`: Definisce i modelli di dati e le fonti dati (mock o API).
*   `lib/shared`: Contiene widget e logica condivisi tra più moduli.

### Componenti Chiave

*   **LoginScreen**: Gestisce l'autenticazione del cameriere tramite PIN.
*   **TablesView**: Visualizza lo stato dei tavoli e consente di interagire con essi.
*   **MenuView**: Permette di prendere le ordinazioni per un tavolo specifico.
*   **CartSheet**: Mostra il carrello corrente e consente di inviare l'ordine.
*   **SettingsScreen**: Permette di configurare le impostazioni dell'app (lingua, tema, reset dati).
*   **ItemEditDialog**: Consente di modificare le quantità, le note, il corso e gli extra di un elemento nel carrello.

## Flusso di Lavoro

1.  **Autenticazione**: Il cameriere inserisce il suo PIN nella schermata di login.
2.  **Selezione Tavolo**: Dopo l'autenticazione, viene visualizzata la schermata `TablesView` che mostra lo stato di tutti i tavoli.
3.  **Gestione Tavolo**:
    *   **Apri Tavolo**: Se il tavolo è libero, il cameriere può aprirlo, specificando il numero di coperti.
    *   **Prendi Ordinazione**: Se il tavolo è occupato, il cameriere può selezionarlo per visualizzare il menu e prendere l'ordinazione.
    *   **Azioni**: Tramite pressione prolungata, si possono spostare, unire, liberare o incassare il tavolo.
4.  **Menu e Ordinazione**: Nella schermata `MenuView`, il cameriere può:
    *   Navigare tra le categorie del menu.
    *   Aggiungere/modificare/rimuovere elementi dal carrello.
    *   Specificare note per la cucina.
    *   Inviare l'ordine alla cucina.
5.  **Carrello**: Il `CartSheet` mostra gli elementi aggiunti all'ordine, il totale parziale e permette di inviare l'ordine.
6.  **Successo**: Dopo l'invio dell'ordine, viene visualizzata una schermata di conferma.
7.  **Incasso**: Dalla schermata dei tavoli, si può aprire il `BillScreen` per gestire il pagamento, sia per articolo che "alla romana".
8.  **Cucina**: L'app cucina (non documentata qui) riceve gli ordini e aggiorna lo stato dei piatti.
9.  **Notifiche**: Quando un tavolo è pronto, il cameriere riceve una vibrazione (implementazione da completare).
10. **Impostazioni**: L'app permette di cambiare lingua, tema e resettare i dati locali.

## Funzionalità Dettagliate

### LoginScreen

*   Autenticazione tramite PIN numerico.
*   PIN "1234" hardcoded (da sostituire con autenticazione backend).
*   Mostra un messaggio di errore in caso di PIN errato.
*   Naviga alla `TablesView` in caso di successo.

### TablesView

*   Visualizza lo stato dei tavoli (libero, occupato, ordinato, pronto, servito).
*   Permette di aprire un tavolo libero specificando il numero di coperti.
*   Permette di selezionare un tavolo occupato per visualizzare il menu.
*   Menu contestuale (long press) per azioni rapide:
    *   Sposta tavolo
    *   Unisci tavolo
    *   Libera tavolo
    *   Incasso
*   Vibrazione quando un tavolo è "pronto" (da implementare completamente).

### MenuView

*   Visualizza il menu diviso per categorie.
*   Permette di filtrare i piatti per nome o ingredienti.
*   Permette di aggiungere piatti al carrello, specificando la quantità, le note e il corso.
*   Mostra un carrello "persistente" nella parte inferiore dello schermo.

### CartSheet

*   Visualizza la lista degli elementi nel carrello, raggruppati per portata.
*   Permette di modificare la quantità di ogni elemento.
*   Permette di rimuovere elementi dal carrello.
*   Permette di visualizzare il totale parziale.
*   Permette di inviare l'ordine alla cucina.
*   Animazione di slide-up/slide-down.

### ItemEditDialog

*   Aperto dal CartSheet o dalla HistoryTab.
*   Permette di modificare:
    *   Quantità (per fare split parziali)
    *   Note per la cucina
    *   Portata
    *   Extra
*   Salva le modifiche nel carrello.

### BillScreen

*   Gestisce il pagamento del conto.
*   Due modalità:
    *   Per Piatto: permette di selezionare quali piatti far pagare (e quindi dividere il conto).
    *   Alla Romana: divide il conto equamente tra i partecipanti.
*   Permette di specificare il metodo di pagamento (carta, contanti).
*   Aggiorna lo stato del tavolo dopo il pagamento.

### SettingsScreen

*   Permette di cambiare la lingua dell'app.
*   Permette di cambiare il tema (chiaro, scuro, automatico).
*   Permette di resettare il database locale (cancella tutti i dati).
*   Mostra informazioni sulla versione dell'app.

## Gestione dello Stato (Riverpod)

Riverpod è utilizzato per gestire lo stato dell'applicazione. I provider principali sono:

*   **authProvider**: Gestisce lo stato di autenticazione dell'utente.
*   **tablesProvider**: Gestisce la lista dei tavoli e il loro stato.
*   **cartProvider**: Gestisce il carrello corrente.
*   **menuProvider**: Espone la lista dei piatti del menu.
*   **themeProvider**: Gestisce il tema corrente dell'app.
*   **localeProvider**: Gestisce la lingua corrente dell'app.

## Navigazione (GoRouter)

GoRouter è utilizzato per la navigazione tra le schermate.  Le rotte principali sono:

*   `/login`: Schermata di login.
*   `/tables`: Schermata principale con la lista dei tavoli.
*   `/menu/:id`: Schermata del menu per un tavolo specifico (l'ID del tavolo è passato come parametro).
*   `/settings`: Schermata delle impostazioni.

## Persistenza Dati (Hive)

Hive è utilizzato per la persistenza locale dei dati. Vengono salvati:

*   La lista dei tavoli (`kTablesBox`, `kTablesKey`).
*   Gli storni (`kVoidsBox`).
*   Le impostazioni (`kSettingsBox`, `kThemeModeKey`).

## Thread Vibration (vibration)

Utilizzato per dare un feedback tattile quando un tavolo è pronto.

## TODO

*   Implementare il backend per l'autenticazione e la gestione dei dati.
*   Completare l'implementazione delle notifiche (vibrazione).
*   Aggiungere controlli per la gestione degli errori di connessione.
*   Implementare il pagamento "alla romana".
*   Configurazione della localizzazione e delle motivazioni di storno da backend.
*   Inserire un logo nell'app.

## Conclusioni

L'app "Orderly" per camerieri è uno strumento potente e flessibile per la gestione del ristorante.  La sua architettura modulare e l'utilizzo di tecnologie moderne come Flutter, Riverpod e GoRouter la rendono facile da manutenere ed estendere.
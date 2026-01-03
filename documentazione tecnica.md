📘 Orderly: Documentazione Tecnica di Progetto

Versione: 1.2
Stato: Sviluppo Attivo (Fase Frontend/Logica Locale completata)
Stack Tecnologico: Flutter (Monorepo), Riverpod 2.0, Hive CE, GoRouter, PocketBase.

1. Visione Generale

Orderly è un ecosistema software modulare per la gestione completa di ristoranti, pizzerie e bar.
Il sistema è progettato per essere agnostico rispetto all'infrastruttura: lo stesso codice sorgente alimenta sia la versione SaaS (Cloud) che la versione On-Premise (Local Box).

Pilastri Architetturali

Offline-First: Continuità operativa locale garantita anche senza internet grazie alla persistenza su database locale (Hive).

Multi-Platform: Unica codebase Flutter che compila per Web, Android e Windows.

Modularità: 4 applicazioni distinte basate su ruoli specifici (Sala, Cucina, Cassa, Admin) che condividono la logica di business.

Hybrid Backend: Supporta sia Cloud (VPS) che Local Server (Raspberry Pi) usando lo stesso software backend (PocketBase).

2. Architettura del Sistema

Il progetto è strutturato come un Monorepo Flutter che condivide la logica di business (data, logic, core) ma compila 4 applicazioni distinte (Target).

### 2.1 Strategia di Deployment (Dual-Mode)

| Caratteristica | Modalità SaaS (Cloud) | Modalità Local Box (On-Premise) |
| :--- | :--- | :--- |
| **Server** | VPS Cloud (es. Hetzner/AWS) | Raspberry Pi 4/5 (in loco) |
| **Connettività** | Richiede Internet stabile | Rete Wi-Fi locale (LAN) isolata |
| **Target Client** | Ristoranti con fibra, catene | Locali in zone remote, bunker, sagre |
| **Endpoint** | `https://api.orderly.cloud` | `http://192.168.10.100` |
| **Aggiornamenti** | Automatici (Web) | Manuali (USB) o Pull (Notturni) |

2.2 Stack Tecnologico

Frontend (App):

Framework: Flutter (Dart).

State Management: Riverpod 2.0 (NotifierProvider, ConsumerWidget).

Routing: GoRouter (Router indipendenti per modulo).

Persistenza Locale: Hive CE (Community Edition).

Localizzazione: flutter_localizations + file .arb.

Backend:

Engine: PocketBase (Go + SQLite). Scelto per la portabilità (singolo eseguibile) e le performance real-time.

Protocollo: Server-Sent Events (SSE) per aggiornamenti in tempo reale.

Management (Solo Local Box):

Sidecar Server: Python (FastAPI) su porta 9090.

Funzioni: Gestione Wi-Fi, Aggiornamenti via ZIP, Shutdown sistema.

3. I Moduli Applicativi (Clients)

📱 1. Orderly Pocket (Waiter)

Utente: Camerieri.

Target: Smartphone Android / iOS (o PWA).

Funzionalità Chiave:

Login: Rapido con PIN numerico.

Gestione Sala: Griglia tavoli con stati visivi complessi (Attesa, Cucina, Pronto, Conto).

Menu: Presa comanda con Varianti, Aggiunte (Extra) e Note.

Workflow: Suddivisione per Portate (Entrée, 1ª, 2ª...). Tasto "DAI IL VIA" per sbloccare le uscite.

Pagamenti: Split Bill avanzato (Alla romana, Per piatto con selezione quantità).

Storni: Gestione cancellazioni con causale e PIN sicurezza.

🖥️ 2. Orderly KDS (Kitchen)

Utente: Chef / Cuochi.

Target: Tablet Android / Web (Kiosk Mode).

Funzionalità Chiave:

Kanban Board: Colonne stato (In Arrivo, In Preparazione, Pronto).

Ticket Digitali: Raggruppamento per tavolo o per pietanza. Evidenziazione modifiche.

Notifica Pronti: Segnalazione al cameriere (vibrazione/badge) quando un piatto è pronto al pass.

🖨️ 3. Orderly POS (Cassa)

Utente: Cassiere / Manager.

Target: Windows o Android Nativo (No Web puro).

Motivazione Nativa: Accesso diretto a porte USB/Ethernet/Seriali.

Funzionalità Chiave:

Driver ESC/POS per stampanti termiche.

Apertura cassetto contanti.

Integrazione RT (Registratore Telematico) per scontrino fiscale.

Mappa sala master e chiusura conti.

📊 4. Orderly Admin (Backoffice)

Utente: Titolare.

Target: Web Desktop.

Funzionalità Chiave:

Menu Engineering: Creazione prodotti, prezzi, varianti, allergeni.

Configurazione: Setup IP stampanti, routing di stampa (Bar vs Cucina).

Staff: Gestione utenti, ruoli e PIN.

Analytics: Dashboard andamento vendite.

4. Modello dei Dati (Core Architecture)

L'architettura dati è Session-Based per garantire integrità storica e contabile.

Entità Principali

Restaurant: Configurazione globale (Valuta, Locale, Coperto, Info Fiscali).

Staff: Utenti con Ruoli (Admin, Waiter, Kitchen) e permessi.

TableItem (Tavolo Fisico):

id, name: Statici.

status: Enum (free, seated, ordered, ready, eating).

guests: Numero coperti.

orders: Lista di CartItem attivi.

paidAmount: Totale monetario già versato (acconti).

CartItem (Prodotto Ordinato):

internalId: Univoco per l'istanza.

qty, paidQty: Quantità ordinata vs pagata.

status: Enum (pending -> fired -> cooking -> ready -> served).

course: Portata di appartenenza.

VoidItem (Log Storni): Registro delle cancellazioni per audit.

5. Flussi Operativi e Sincronizzazione

Il sistema utilizza un pattern Optimistic UI: l'interfaccia si aggiorna immediatamente salvando su Hive, poi sincronizza con il Backend in background.

5.1 Flusso Presa Comanda (Waiter -> Kitchen)

Check-in: Cameriere apre tavolo (T5) -> Inserisce coperti.

Ordine: Aggiunge piatti al carrello (divisi per uscite).

Invio: Preme "INVIA".

Salvataggio locale Hive.

Invio API a PocketBase.

Sync: PocketBase notifica il KDS in cucina tramite stream.

5.2 Flusso "Piatto Pronto" (Kitchen -> Waiter)

Cucina: Chef preme "PRONTO" sul KDS.

Server: Aggiorna lo stato item a ready.

Sala: I dispositivi ricevono l'evento SSE.

La card del tavolo mostra la campanella verde.

Il dispositivo vibra.

5.3 Flusso Pagamento (Split & Merge)

Pagamento Parziale (Piatto): Incrementa paidQty dell'item. L'item non viene rimosso finché il tavolo è attivo per mantenere lo storico.

Pagamento Parziale (Romana): Incrementa paidAmount del tavolo.

Saldo: Quando (ValoreOrdini - ValorePagato) <= 0:

Il tavolo torna free.

Gli ordini vengono svuotati (o archiviati in Session storica nel backend).

6. Orderly Box (Specifiche Hardware Locale)

Per i clienti senza internet o che richiedono stabilità massima.

Hardware: Raspberry Pi 4 (4GB RAM) o Pi 5.

Storage: SSD USB (M.2 o SATA). NO MicroSD per il DB.

OS: Linux Headless (Raspberry Pi OS Lite).

Networking:

Collegato via Ethernet a Access Point Wi-Fi dedicato.

IP Statico: 192.168.10.100.

Software:

pocketbase: Backend (Porta 80).

pb_public/: Cartella contenente le Web App (Waiter/Kitchen).

admin_server.py: Gestore sistema (Porta 9090).

7. Struttura del Codice (Folder Structure)

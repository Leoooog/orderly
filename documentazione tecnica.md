# 📘 Orderly: Documentazione Tecnica di Progetto (TDD)

| Meta-Dato           | Valore                                                 |
|:--------------------|:-------------------------------------------------------|
| **Versione Doc**    | 2.0                                                    |
| **Stato Progetto**  | Sviluppo Attivo (Frontend Beta / Integrazione Backend) |
| **Maintainer**      | Team di Sviluppo Orderly                               |
| **Ultima Modifica** | 03/01/2026                                             |

---

## 1. Visione Generale

**Orderly** è un ecosistema software modulare per la gestione completa di ristoranti, pizzerie e bar.
Il sistema è progettato con un'architettura **Ibrida e Agnostica**: lo stesso codice sorgente alimenta sia la versione **SaaS (Cloud)** per locali con connettività stabile, sia la versione **On-Premise (Local Box)** per locali offline o ad alta richiesta di stabilità.

### 🎯 Obiettivi Chiave
1.  **Offline-First:** Continuità operativa totale in assenza di rete grazie alla persistenza locale (Hive).
2.  **Multi-Platform:** Codice condiviso al 98% tra Web (PWA), Android e Windows.
3.  **Role-Based:** 4 interfacce distinte (Sala, Cucina, Cassa, Admin) ottimizzate per l'hardware di destinazione.
4.  **Scalabilità:** Dal piccolo chiosco senza internet alla catena di ristoranti in Cloud.

---

## 2. Architettura del Sistema

Il progetto è strutturato come un **Monorepo Flutter** che condivide la logica di business (`data`, `logic`, `core`) ma compila 4 applicazioni distinte (Target).

### 2.1 Strategia di Deployment (Dual-Mode)

| Caratteristica    | Modalità **SaaS (Cloud)**    | Modalità **Local Box (On-Premise)**  |
|:------------------|:-----------------------------|:-------------------------------------|
| **Server**        | VPS Cloud (es. Hetzner/AWS)  | Raspberry Pi 4/5 (in loco)           |
| **Connettività**  | Richiede Internet stabile    | Rete Wi-Fi locale (LAN) isolata      |
| **Target Client** | Ristoranti con fibra, catene | Locali in zone remote, bunker, sagre |
| **Endpoint**      | `https://api.orderly.cloud`  | `http://192.168.10.100`              |
| **Aggiornamenti** | Automatici (Web)             | Manuali (USB) o Pull (Notturni)      |
|                   |                              |                                      |

```mermaid
graph TD
    subgraph "Frontend Layer (Flutter Monorepo)"
        A[App Waiter<br>(Mobile)] -->|HTTP/SSE| API
        B[App KDS<br>(Tablet)] -->|HTTP/SSE| API
        C[App POS<br>(Windows/Android)] -->|HTTP/SSE| API
        C -->|USB/LAN| Printer[Stampanti Termiche]
        D[Web Admin<br>(Browser)] -->|HTTP| API
    end

    subgraph "Backend Layer (Intercambiabile)"
        API[Interfaccia IOrderlyRepository]
        
        API -.->|Scenario A: SaaS| Cloud[VPS / Cloud<br>PocketBase + S3]
        API -.->|Scenario B: On-Premise| Local[Raspberry Pi 4/5<br>PocketBase Locale]
    end

    subgraph "Local Persistence Layer"
        Hive[(Hive CE NoSQL)]
        A <--> Hive
        B <--> Hive
        C <--> Hive
    end
```
### 2.2 Stack Tecnologico

* **Frontend (App):**
    * **Framework:** Flutter (Dart 3.x).
    * **State Management:** Riverpod 2.0 (`NotifierProvider`, `ConsumerWidget`).
    * **Routing:** GoRouter (Router indipendenti per modulo).
    * **Persistenza Locale:** Hive CE (Community Edition).
    * **Localizzazione:** `flutter_localizations` + file `.arb`.
* **Backend:**
    * **Engine:** **PocketBase** (Go + SQLite). Scelto per la portabilità (singolo eseguibile) e le performance real-time.
    * **Protocollo:** Server-Sent Events (SSE) per aggiornamenti in tempo reale.
* **Management (Solo Local Box):**
    * **Sidecar Server:** Python (FastAPI) su porta 9090.
    * **Funzioni:** Gestione Wi-Fi, Aggiornamenti via ZIP, Shutdown sistema.

---

## 3. Moduli Applicativi (Clients)

L'applicazione è suddivisa in 4 moduli verticali che condividono la logica di business (`/logic`) e i modelli dati (`/data`), ma possiedono UI e Router separati.

### 📱 1. Orderly Pocket (Sala)
* **Target:** Smartphone Android / iOS (PWA supportata).
* **Focus:** Velocità, utilizzo a una mano.
* **Core Features:**
    * Login rapido via PIN.
    * Griglia tavoli con stati semantici (Libero, Attesa, Cucina, Pronto).
    * Presa comanda con Varianti e Note.
    * Gestione Portate ("Fire Course").
    * Split Bill avanzato (Romana/Piatto).

### 🖥️ 2. Orderly KDS (Cucina)
* **Target:** Tablet Android (10"+) / Web Kiosk.
* **Focus:** Leggibilità, Real-time.
* **Core Features:**
    * Kanban Board (In Arrivo -> In Preparazione -> Pass).
    * Raggruppamento intelligente (per Tavolo o per Partita).
    * Feedback aptico/sonoro all'arrivo comande.
    * Segnalazione "Piatto Pronto" alla sala.

### 🖨️ 3. Orderly POS (Cassa)
* **Target:** Windows / Android Nativo.
* **Focus:** Integrazione Hardware.
* **Core Features:**
    * Driver nativi (ESC/POS) per stampanti termiche e fiscali.
    * Gestione cassetto contanti.
    * Mappa sala master.
    * Chiusura fiscale e reportistica.

### 📊 4. Orderly Admin (Backoffice)
* **Target:** Web Desktop.
* **Focus:** Gestione e Analisi.
* **Core Features:**
    * Menu Engineering (Prodotti, Prezzi, Ingredienti, Allergeni).
    * Configurazione Hardware (IP Stampanti, Routing stampe).
    * Gestione Staff e Permessi (RBAC).
    * Analytics e Business Intelligence.

---

## 4. Modello dei Dati (Core Architecture)

L'architettura dati è **Session-Based**. Non esiste il concetto di "Ordine volante", tutto è storicizzato dentro una sessione tavolo.

### Schema Logico (PocketBase Collections)

1.  **`restaurants`**: Configurazione globale (Valuta, Locale, Coperto, Info Fiscali).
2.  **`users` (Staff)**: Utenti con Ruoli (`waiter`, `kitchen`, `admin`, `pos`) e `pin_hash`.
3.  **`tables`**: Rappresentazione fisica dei tavoli (`id`, `name`, `x`, `y`, `status`).
4.  **`table_sessions`**: Storico delle occupazioni.
    * `id`, `table_id`, `start_time`, `end_time`.
    * `guests` (int).
    * `total_amount` (calcolato).
    * `status` (open/closed).
5.  **`orders`**: I singoli item ordinati.
    * `session_id` (Relazione).
    * `product_id`, `name`, `price`.
    * `quantity`, `paid_quantity`.
    * `status` (pending, fired, cooking, ready, served).
    * `course` (enum).
    * `modifiers` (JSON: varianti e note).
6.  **`transactions`**: Pagamenti effettuati.
    * `session_id`.
    * `amount`, `method` (cash/card).
    * `timestamp`.
7.  **`voids`**: Log degli storni per sicurezza.

---

## 5. Flussi Operativi

Il sistema utilizza un pattern **Optimistic UI**: l'interfaccia si aggiorna immediatamente salvando su Hive, poi sincronizza con il Backend in background.

### 5.1 Flusso Presa Comanda (Sala -> Cucina)
1.  **Check-in:** Cameriere apre tavolo (T5) -> Inserisce coperti.
2.  **Ordine:** Aggiunge piatti al carrello (divisi per uscite).
3.  **Invio:** Preme "INVIA".
    * Salvataggio locale Hive (immediato).
    * Invio API a PocketBase (background).
4.  **Sync:** PocketBase notifica il KDS in cucina tramite stream SSE.

### 5.2 Flusso "Piatto Pronto" (Cucina -> Sala)
1.  **Cucina:** Chef preme "PRONTO" sul KDS.
2.  **Server:** Aggiorna lo stato item a `ready`.
3.  **Sala:** I dispositivi ricevono l'evento SSE.
    * La card del tavolo mostra la campanella verde.
    * Il dispositivo vibra.


### 5.3 Flusso Pagamento (Split & Merge)
1.  **Pagamento Parziale (Piatto):** Incrementa `paidQty` dell'item. L'item non viene rimosso finché il tavolo è attivo per mantenere lo storico.
2.  **Pagamento Parziale (Romana):** Incrementa `paidAmount` del tavolo.
3.  **Saldo:** Quando `(ValoreOrdini - ValorePagato) <= 0`:
    * Il tavolo torna `free`.
    * Gli ordini vengono svuotati dalla vista live (archiviati in Session storica nel backend).

---

## 6. Specifiche Hardware "Local Box"

Per le installazioni On-Premise, il sistema viene fornito come appliance "Plug & Play".

| Componente    | Specifica Minima               | Note                                                      |
|:--------------|:-------------------------------|:----------------------------------------------------------|
| **Server**    | Raspberry Pi 4B (4GB/8GB)      | O equivalente Mini-PC (N100).                             |
| **Storage**   | SSD 120GB (USB 3.0/M.2)        | **VIETATO** usare MicroSD per il DB (rischio corruzione). |
| **OS**        | Linux Headless (Debian/DietPi) | Ottimizzato per container o binari Go.                    |
| **Rete**      | Access Point Wi-Fi 6           | Dedicato esclusivamente al sistema Orderly.               |
| **IP Server** | Statico: `192.168.10.100`      | Gateway predefinito per le app.                           |

### Gestione Software Box
Il Raspberry espone due servizi:
1.  **Porta 80 (HTTP):** PocketBase (API + Hosting Web App).
2.  **Porta 9090 (Admin):** Server Python FastAPI per gestione sistema (Config Wi-Fi, Update ZIP, Reboot).

-- =================================================================
-- SCRIPT CONFIGURAZIONE BASE (Staff, Tavoli, Config, Reparti)
-- Eseguire nella console SQL di IntelliJ collegata a data.db
-- =================================================================

-- 1. POPOLAMENTO REPARTI (Necessari per assegnare lo staff)
INSERT INTO departments (id, name, printer_ip, created, updated) VALUES
                                                                     (substr(lower(hex(randomblob(16))), 1, 15), 'Bar', '192.168.1.50', datetime('now'), datetime('now')),
                                                                     (substr(lower(hex(randomblob(16))), 1, 15), 'Cucina', '192.168.1.51', datetime('now'), datetime('now')),
                                                                     (substr(lower(hex(randomblob(16))), 1, 15), 'Pizzeria', '192.168.1.52', datetime('now'), datetime('now'));

-- 2. CONFIGURAZIONE RISTORANTE (Singleton)
INSERT INTO restaurants (id, name, address, vat_number, currency_symbol, created, updated) VALUES
    (
        substr(lower(hex(randomblob(16))), 1, 15),
        'Trattoria Orderly Romana',
        'Via del Corso, 123 - Roma (RM)',
        'IT12345678901',
        '€',
        datetime('now'),
        datetime('now')
    );

-- 3. UTENTI & STAFF
-- Nota: pin_hash per "0000" = 9af15b336e6a9619928537df30b2e6a2376569fcf9d7e773eccede65606529a0
-- Nota: pin_hash per "1234" = 03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4

-- ADMIN (Proprietario)
INSERT INTO users (id, name, email, tokenKey, password, emailVisibility, verified, role, pin_hash, full_name, assigned_departments, created, updated) VALUES
    (
        substr(lower(hex(randomblob(16))), 1, 15),
        '', 'admin@orderly.local', 'tokenkey_admin',
        '$2a$10$PcXS/../hashed_password_example', -- La password va impostata da UI o hashata correttamente
        1, 1,
        'admin',
        '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', -- PIN: 1234
        'Mario Rossi (Titolare)',
        (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments), -- Vede tutto
        datetime('now'), datetime('now')
    );

-- CAMERIERE (Sala)
INSERT INTO users (id, name, email, tokenKey, password, emailVisibility, verified, role, pin_hash, full_name, assigned_departments, created, updated) VALUES
    (
        substr(lower(hex(randomblob(16))), 1, 15),
        '', 'waiter1@orderly.local', 'tokenkey_waiter1',
        '', 1, 1,
        'waiter',
        '9af15b336e6a9619928537df30b2e6a2376569fcf9d7e773eccede65606529a0', -- PIN: 0000
        'Luca Bianchi',
        (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments), -- Può inviare a tutti
        datetime('now'), datetime('now')
    );

-- CHEF (Cucina)
INSERT INTO users (id, name, email, tokenKey, password, emailVisibility, verified, role, pin_hash, full_name, assigned_departments, created, updated) VALUES
    (
        substr(lower(hex(randomblob(16))), 1, 15),
        '', 'chef@orderly.local', 'tokenkey_chef',
        '', 1, 1,
        'kitchen',
        '9af15b336e6a9619928537df30b2e6a2376569fcf9d7e773eccede65606529a0', -- PIN: 0000
        'Chef Alessandro',
        (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments WHERE name = 'Cucina'),
        datetime('now'), datetime('now')
    );

-- PIZZAIOLO (Pizzeria)
INSERT INTO users (id, name, email, tokenKey, password, emailVisibility, verified, role, pin_hash, full_name, assigned_departments, created, updated) VALUES
    (
        substr(lower(hex(randomblob(16))), 1, 15),
        '', 'pizza@orderly.local', 'tokenkey_pizza',
        '', 1, 1,
        'kitchen',
        '9af15b336e6a9619928537df30b2e6a2376569fcf9d7e773eccede65606529a0', -- PIN: 0000
        'Gennaro Esposito',
        (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments WHERE name = 'Pizzeria'),
        datetime('now'), datetime('now')
    );

-- BARISTA (Bar)
INSERT INTO users (id, name, email, tokenKey, password, emailVisibility, verified, role, pin_hash, full_name, assigned_departments, created, updated) VALUES
    (
        substr(lower(hex(randomblob(16))), 1, 15),
        '', 'bar@orderly.local', 'tokenkey_bar',
        '', 1, 1,
        'kitchen',
        '9af15b336e6a9619928537df30b2e6a2376569fcf9d7e773eccede65606529a0', -- PIN: 0000
        'Giulia Verdi',
        (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments WHERE name = 'Bar'),
        datetime('now'), datetime('now')
    );

-- CASSIERE (POS)
INSERT INTO users (id, name, email, tokenKey, password, emailVisibility, verified, role, pin_hash, full_name, assigned_departments, created, updated) VALUES
    (
        substr(lower(hex(randomblob(16))), 1, 15),
        '', 'pos@orderly.local', 'tokenkey_pos',
        '', 1, 1,
        'pos',
        '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', -- PIN: 1234
        'Cassa Principale',
        '[]',
        datetime('now'), datetime('now')
    );

-- 4. PORTATE (COURSES)
-- requires_firing = 1 significa che servono il tasto "VIA"
INSERT INTO courses (id, name, sort_order, requires_firing, created, updated) VALUES
                                                                                  (substr(lower(hex(randomblob(16))), 1, 15), 'Bevande', 5, 0, datetime('now'), datetime('now')),
                                                                                  (substr(lower(hex(randomblob(16))), 1, 15), 'Antipasti', 10, 1, datetime('now'), datetime('now')),
                                                                                  (substr(lower(hex(randomblob(16))), 1, 15), 'Primi', 20, 1, datetime('now'), datetime('now')),
                                                                                  (substr(lower(hex(randomblob(16))), 1, 15), 'Pizze', 25, 1, datetime('now'), datetime('now')),
                                                                                  (substr(lower(hex(randomblob(16))), 1, 15), 'Secondi', 30, 1, datetime('now'), datetime('now')),
                                                                                  (substr(lower(hex(randomblob(16))), 1, 15), 'Contorni', 40, 1, datetime('now'), datetime('now')),
                                                                                  (substr(lower(hex(randomblob(16))), 1, 15), 'Dessert', 50, 1, datetime('now'), datetime('now')),
                                                                                  (substr(lower(hex(randomblob(16))), 1, 15), 'Caffetteria', 60, 0, datetime('now'), datetime('now'));

-- 5. EXTRAS (Aggiunte Comuni)
INSERT INTO extras (id, name, price, is_available, created, updated) VALUES
                                                                         (substr(lower(hex(randomblob(16))), 1, 15), 'Doppia Mozzarella', 1.50, 1, datetime('now'), datetime('now')),
                                                                         (substr(lower(hex(randomblob(16))), 1, 15), 'Mozzarella di Bufala', 2.50, 1, datetime('now'), datetime('now')),
                                                                         (substr(lower(hex(randomblob(16))), 1, 15), 'Senza Glutine', 3.00, 1, datetime('now'), datetime('now')),
                                                                         (substr(lower(hex(randomblob(16))), 1, 15), 'Patatine Fritte (Aggiunta)', 2.00, 1, datetime('now'), datetime('now')),
                                                                         (substr(lower(hex(randomblob(16))), 1, 15), 'Salsa Rosa', 0.50, 1, datetime('now'), datetime('now')),
                                                                         (substr(lower(hex(randomblob(16))), 1, 15), 'Ketchup', 0.00, 1, datetime('now'), datetime('now')),
                                                                         (substr(lower(hex(randomblob(16))), 1, 15), 'Maionese', 0.00, 1, datetime('now'), datetime('now'));

-- 6. TAVOLI (Statici)
INSERT INTO tables (id, name, created, updated) VALUES
                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'T1', datetime('now'), datetime('now')),
                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'T2', datetime('now'), datetime('now')),
                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'T3', datetime('now'), datetime('now')),
                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'T4', datetime('now'), datetime('now')),
                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'T5', datetime('now'), datetime('now')),
                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'T6', datetime('now'), datetime('now')),
                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'T10 (Rotondo)', datetime('now'), datetime('now')),
                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'E1 (Esterno)', datetime('now'), datetime('now')),
                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'E2 (Esterno)', datetime('now'), datetime('now')),
                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'E3 (Esterno)', datetime('now'), datetime('now'));
INSERT INTO allergens (id, name, code, created, updated)
VALUES (substr(lower(hex(randomblob(16))), 1, 15), 'Glutine', 'GLU', datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Crostacei', 'CRO', datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Uova', 'UOV', datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Pesce', 'PES', datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Arachidi', 'ARA', datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Soia', 'SOI', datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Latte', 'LAT', datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Frutta a guscio', 'FRU', datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Sedano', 'SED', datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Senape', 'SEN', datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Semi di sesamo', 'SES', datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Anidride solforosa e solfiti', 'SO2', datetime('now'),
        datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Lupini', 'LUP', datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Molluschi', 'MOL', datetime('now'), datetime('now'));

-- =================================================================
-- POPOLAMENTO INGREDIENTI
-- Nota: is_frozen = 0 (False) di default, 1 (True) per surgelati comuni
-- =================================================================

-- BASI & DISPENSA
INSERT INTO ingredients (id, name, is_frozen, created, updated)
VALUES (substr(lower(hex(randomblob(16))), 1, 15), 'Farina 00', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Farina Integrale', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Semola Rimacinata', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Lievito Madre', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Olio EVO', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Olio Piccante', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Aceto Balsamico', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Sale Fino', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Pepe Nero', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Origano', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Basilico Fresco', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Rosmarino', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Prezzemolo', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Aglio', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Peperoncino Fresco', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Zucchero', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Uova Fresche', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Riso Carnaroli', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Spaghetti', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Penne Rigate', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Gnocchi di Patate', 0, datetime('now'), datetime('now'));

-- LATTICINI & FORMAGGI
INSERT INTO ingredients (id, name, is_frozen, created, updated)
VALUES (substr(lower(hex(randomblob(16))), 1, 15), 'Mozzarella Fiordilatte', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Mozzarella di Bufala', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Provola Affumicata', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Grana Padano', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Parmigiano Reggiano', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Pecorino Romano', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Gorgonzola DOP', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Taleggio', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Ricotta Fresca', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Stracciatella', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Burrata', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Mascarpone', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Panna da Cucina', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Burro', 0, datetime('now'), datetime('now'));

-- SALUMI & CARNI
INSERT INTO ingredients (id, name, is_frozen, created, updated)
VALUES (substr(lower(hex(randomblob(16))), 1, 15), 'Prosciutto Cotto', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Prosciutto Crudo di Parma', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Salame Piccante', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Salame Napoli', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Salsiccia Fresca', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Pancetta', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Guanciale', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Speck Alto Adige', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Bresaola', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Mortadella', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Nduja di Spilinga', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Wurstel', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Macinato di Manzo', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Petto di Pollo', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Filetto di Manzo', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Hamburger', 0, datetime('now'), datetime('now'));

-- VERDURE & ORTAGGI
INSERT INTO ingredients (id, name, is_frozen, created, updated)
VALUES (substr(lower(hex(randomblob(16))), 1, 15), 'Pomodoro San Marzano', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Pomodorini Ciliegino', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Passata di Pomodoro', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Funghi Champignon', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Funghi Porcini', 1, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Carciofini Sottolio', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Olive Nere', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Olive Taggiasche', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Capperi', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Acciughe', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Melanzane Grigliate', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Zucchine Grigliate', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Peperoni Arrostiti', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Friarielli', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Rucola', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Radicchio', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Insalata Iceberg', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Cipolla Rossa di Tropea', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Patate al Forno', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Patatine Fritte', 1, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Spinaci', 1, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Mais', 0, datetime('now'), datetime('now'));

-- PESCE (Spesso surgelato nei ristoranti non di mare)
INSERT INTO ingredients (id, name, is_frozen, created, updated)
VALUES (substr(lower(hex(randomblob(16))), 1, 15), 'Tonno in Olio', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Salmone Affumicato', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Gamberetti', 1, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Cozze', 1, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Vongole', 1, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Calamari', 1, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Polpo', 1, datetime('now'), datetime('now'));

-- FRUTTA & DOLCI
INSERT INTO ingredients (id, name, is_frozen, created, updated)
VALUES (substr(lower(hex(randomblob(16))), 1, 15), 'Limone', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Fragole', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Ananas', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Nutella', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Crema Pasticcera', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Granella di Nocciole', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Pistacchio di Bronte', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Cacao Amaro', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Zucchero a Velo', 0, datetime('now'), datetime('now'));

-- BEVANDE & BAR
INSERT INTO ingredients (id, name, is_frozen, created, updated)
VALUES (substr(lower(hex(randomblob(16))), 1, 15), 'Caffè in Grani', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Latte Intero', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Ghiaccio', 1, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Coca Cola', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Birra alla Spina', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Vino Rosso', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Vino Bianco', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Aperol', 0, datetime('now'), datetime('now')),
       (substr(lower(hex(randomblob(16))), 1, 15), 'Gin', 0, datetime('now'), datetime('now'));



-- =================================================================
-- SCRIPT MENU ROMANO (Senza Immagini)
-- Eseguire nella console SQL di IntelliJ collegata a data.db
-- =================================================================

-- 1. AGGIUNTA INGREDIENTI ROMANI MANCANTI
INSERT INTO ingredients (id, name, is_frozen, created, updated) VALUES
                                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'Guanciale Amatrice', 0, datetime('now'), datetime('now')),
                                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'Pecorino Romano DOP', 0, datetime('now'), datetime('now')),
                                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'Carciofi Romaneschi', 0, datetime('now'), datetime('now')),
                                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'Cicoria', 0, datetime('now'), datetime('now')),
                                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'Coda di Bue', 0, datetime('now'), datetime('now')),
                                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'Abbacchio', 0, datetime('now'), datetime('now')),
                                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'Mentuccia', 0, datetime('now'), datetime('now')),
                                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'Ricotta di Pecora', 0, datetime('now'), datetime('now')),
                                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'Visciole', 0, datetime('now'), datetime('now')),
                                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'Rigatoni', 0, datetime('now'), datetime('now')),
                                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'Bucatini', 0, datetime('now'), datetime('now')),
                                                                    (substr(lower(hex(randomblob(16))), 1, 15), 'Trippa', 0, datetime('now'), datetime('now'));

-- 2. AGGIUNTA CATEGORIE RISTORAZIONE CLASSICA
INSERT INTO categories (id, name, sort_order, created, updated) VALUES
                                                                               (substr(lower(hex(randomblob(16))), 1, 15), 'Antipasti', 10, datetime('now'), datetime('now')),
                                                                               (substr(lower(hex(randomblob(16))), 1, 15), 'Primi Romani', 20, datetime('now'), datetime('now')),
                                                                               (substr(lower(hex(randomblob(16))), 1, 15), 'Secondi della Tradizione', 30, datetime('now'), datetime('now')),
                                                                               (substr(lower(hex(randomblob(16))), 1, 15), 'Contorni', 40, datetime('now'), datetime('now')),
                                                                               (substr(lower(hex(randomblob(16))), 1, 15), 'Dolci Fatti in Casa', 50, datetime('now'), datetime('now'));


-- 3. INSERIMENTO MENU (Query Complesse per Relazioni)
-- Nota: Rimosso campo 'image'




-- --- CARBONARA ---
INSERT INTO menu_items (id, name, description, price, category, produced_by, ingredients, allergens, is_available, created, updated)
VALUES (
           substr(lower(hex(randomblob(16))), 1, 15),
           'Carbonara Imperiale',
           'Spaghetti, tuorlo d''uovo bio, Guanciale croccante, Pecorino Romano DOP e Pepe nero.',
           12.00,
           (SELECT id FROM categories WHERE name = 'Primi Romani' LIMIT 1),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments WHERE name = 'Cucina'),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM ingredients WHERE name IN ('Spaghetti', 'Uova Fresche', 'Guanciale Amatrice', 'Pecorino Romano DOP', 'Pepe Nero')),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM allergens WHERE code IN ('GLU', 'UOV', 'LAT')),
           1,
           datetime('now'), datetime('now')
       );

-- --- AMATRICIANA ---
INSERT INTO menu_items (id, name, description, price, category, produced_by, ingredients, allergens, is_available, created, updated)
VALUES (
           substr(lower(hex(randomblob(16))), 1, 15),
           'Amatriciana Verace',
           'Bucatini, Pomodoro San Marzano, Guanciale, Pecorino e un tocco di peperoncino.',
           11.50,
           (SELECT id FROM categories WHERE name = 'Primi Romani' LIMIT 1),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments WHERE name = 'Cucina'),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM ingredients WHERE name IN ('Bucatini', 'Pomodoro San Marzano', 'Guanciale Amatrice', 'Pecorino Romano DOP', 'Pepe Nero', 'Peperoncino Fresco')),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM allergens WHERE code IN ('GLU', 'LAT')),
           1,
           datetime('now'), datetime('now')
       );

-- --- CACIO E PEPE ---
INSERT INTO menu_items (id, name, description, price, category,  produced_by, ingredients, allergens, is_available, created, updated)
VALUES (
           substr(lower(hex(randomblob(16))), 1, 15),
           'Tonnarelli Cacio e Pepe',
           'Crema di Pecorino Romano DOP, pepe nero tostato al momento e acqua di cottura.',
           10.50,
           (SELECT id FROM categories WHERE name = 'Primi Romani' LIMIT 1),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments WHERE name = 'Cucina'),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM ingredients WHERE name IN ('Spaghetti', 'Pecorino Romano DOP', 'Pepe Nero')),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM allergens WHERE code IN ('GLU', 'LAT')),
           1,
           datetime('now'), datetime('now')
       );

-- --- SALTIMBOCCA ---
INSERT INTO menu_items (id, name, description, price, category,  produced_by, ingredients, allergens, is_available, created, updated)
VALUES (
           substr(lower(hex(randomblob(16))), 1, 15),
           'Saltimbocca alla Romana',
           'Fettine di vitello con Prosciutto Crudo e Salvia, sfumate al vino bianco.',
           16.00,
           (SELECT id FROM categories WHERE name = 'Secondi della Tradizione' LIMIT 1),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments WHERE name = 'Cucina'),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM ingredients WHERE name IN ('Burro', 'Prosciutto Crudo di Parma', 'Vino Bianco')),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM allergens WHERE code IN ('LAT', 'SO2')),
           1,
           datetime('now'), datetime('now')
       );

-- --- CODA ALLA VACCINARA ---
INSERT INTO menu_items (id, name, description, price, category,  produced_by, ingredients, allergens, is_available, created, updated)
VALUES (
           substr(lower(hex(randomblob(16))), 1, 15),
           'Coda alla Vaccinara',
           'Coda di bue stufata lentamente con sedano, pomodoro, pinoli e uvetta.',
           18.00,
           (SELECT id FROM categories WHERE name = 'Secondi della Tradizione' LIMIT 1),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments WHERE name = 'Cucina'),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM ingredients WHERE name IN ('Coda di Bue', 'Sedano', 'Pomodoro San Marzano', 'Vino Rosso', 'Cacao Amaro')),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM allergens WHERE code IN ('SED', 'SO2')),
           1,
           datetime('now'), datetime('now')
       );

-- --- CARCIOFO ALLA GIUDIA ---
INSERT INTO menu_items (id, name, description, price, category, produced_by, ingredients, allergens, is_available, created, updated)
VALUES (
           substr(lower(hex(randomblob(16))), 1, 15),
           'Carciofo alla Giudia',
           'Carciofo romanesco fritto intero, croccante e dorato.',
           7.00,
           (SELECT id FROM categories WHERE name = 'Antipasti' LIMIT 1),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments WHERE name = 'Cucina'),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM ingredients WHERE name IN ('Carciofi Romaneschi', 'Olio EVO', 'Limone')),
           '[]',
           1,
           datetime('now'), datetime('now')
       );

-- --- SUPPLI ---
INSERT INTO menu_items (id, name, description, price, category,  produced_by, ingredients, allergens, is_available, created, updated)
VALUES (
           substr(lower(hex(randomblob(16))), 1, 15),
           'Supplì al Telefono',
           'Riso al pomodoro con cuore di mozzarella filante.',
           3.00,
           (SELECT id FROM categories WHERE name = 'Antipasti' LIMIT 1),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments WHERE name = 'Cucina'),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM ingredients WHERE name IN ('Riso Carnaroli', 'Pomodoro San Marzano', 'Mozzarella Fiordilatte', 'Uova Fresche', 'Pangrattato')),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM allergens WHERE code IN ('GLU', 'UOV', 'LAT')),
           1,
           datetime('now'), datetime('now')
       );

-- --- CICORIA ---
INSERT INTO menu_items (id, name, description, price, category,  produced_by, ingredients, allergens, is_available, created, updated)
VALUES (
           substr(lower(hex(randomblob(16))), 1, 15),
           'Cicoria Ripassata',
           'Cicoria di campo ripassata in padella con aglio, olio e peperoncino.',
           6.00,
           (SELECT id FROM categories WHERE name = 'Contorni' LIMIT 1),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments WHERE name = 'Cucina'),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM ingredients WHERE name IN ('Cicoria', 'Aglio', 'Olio EVO', 'Peperoncino Fresco')),
           '[]',
           1,
           datetime('now'), datetime('now')
       );

-- --- MARITOZZO ---
INSERT INTO menu_items (id, name, description, price, category, produced_by, ingredients, allergens, is_available, created, updated)
VALUES (
           substr(lower(hex(randomblob(16))), 1, 15),
           'Maritozzo con Panna',
           'Soffice brioche romana farcita con panna fresca montata al momento.',
           5.00,
           (SELECT id FROM categories WHERE name = 'Dolci Fatti in Casa' LIMIT 1),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM departments WHERE name = 'Cucina'),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM ingredients WHERE name IN ('Farina 00', 'Uova Fresche', 'Zucchero', 'Latte Intero', 'Panna da Cucina')),
           (SELECT '[' || group_concat('"' || id || '"', ',') || ']' FROM allergens WHERE code IN ('GLU', 'UOV', 'LAT')),
           1,
           datetime('now'), datetime('now')
       );
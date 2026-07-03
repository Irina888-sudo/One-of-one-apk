USE oneofone;

-- 1. Assurer qu'il y a un client et un employé
INSERT IGNORE INTO client (id, nom, email, statut) VALUES (1, 'Client Test', 'test@test.com', 'ACTIF');
INSERT IGNORE INTO employe (id, nom, role, statut) VALUES (1, 'Employe Test', 'LIVREUR', 'ACTIF');

-- 2. Commandes pour 2026
-- Jan
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-01-', UUID()), 1, 'LIVREE', 15200.50, '2026-01-15 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-01-', UUID()), 1, 'LIVREE', 12300.00, '2026-01-20 10:00:00');
-- Feb
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-02-', UUID()), 1, 'LIVREE', 18400.00, '2026-02-10 10:00:00');
-- Mar
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-03-', UUID()), 1, 'LIVREE', 16500.00, '2026-03-05 10:00:00');
-- Apr
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-04-', UUID()), 1, 'LIVREE', 22100.00, '2026-04-12 10:00:00');
-- May
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-05-', UUID()), 1, 'LIVREE', 21000.00, '2026-05-18 10:00:00');
-- Jun (Mois en cours de 2026-06)
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-06-', UUID()), 1, 'LIVREE', 25600.00, '2026-06-10 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-06-', UUID()), 1, 'LIVREE', 14200.00, '2026-06-15 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-06-', UUID()), 1, 'LIVREE', 18050.00, '2026-06-20 10:00:00');
-- Jul
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-07-', UUID()), 1, 'LIVREE', 28000.00, '2026-07-10 10:00:00');
-- Aug
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-08-', UUID()), 1, 'LIVREE', 24000.00, '2026-08-10 10:00:00');
-- Sep
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-09-', UUID()), 1, 'LIVREE', 29000.00, '2026-09-10 10:00:00');
-- Oct
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-10-', UUID()), 1, 'LIVREE', 31000.00, '2026-10-10 10:00:00');
-- Nov
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-11-', UUID()), 1, 'LIVREE', 35000.00, '2026-11-10 10:00:00');
-- Dec
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (CONCAT('CMD-26-12-', UUID()), 1, 'LIVREE', 42000.00, '2026-12-10 10:00:00');


-- 3. Finances (Dépenses)
INSERT INTO finance (description, type, montant, date_transaction) VALUES ('Achat matiere', 'DEPENSE', 8000.00, '2026-01-05');
INSERT INTO finance (description, type, montant, date_transaction) VALUES ('Achat matiere', 'DEPENSE', 9500.00, '2026-02-05');
INSERT INTO finance (description, type, montant, date_transaction) VALUES ('Achat matiere', 'DEPENSE', 8200.00, '2026-03-05');
INSERT INTO finance (description, type, montant, date_transaction) VALUES ('Achat matiere', 'DEPENSE', 11000.00, '2026-04-05');
INSERT INTO finance (description, type, montant, date_transaction) VALUES ('Achat matiere', 'DEPENSE', 10500.00, '2026-05-05');
INSERT INTO finance (description, type, montant, date_transaction) VALUES ('Achat matiere', 'DEPENSE', 12000.00, '2026-06-05');
INSERT INTO finance (description, type, montant, date_transaction) VALUES ('Frais divers', 'DEPENSE', 2000.50, '2026-06-15');
INSERT INTO finance (description, type, montant, date_transaction) VALUES ('Achat matiere', 'DEPENSE', 14000.00, '2026-07-05');
INSERT INTO finance (description, type, montant, date_transaction) VALUES ('Achat matiere', 'DEPENSE', 12500.00, '2026-08-05');
INSERT INTO finance (description, type, montant, date_transaction) VALUES ('Achat matiere', 'DEPENSE', 15000.00, '2026-09-05');
INSERT INTO finance (description, type, montant, date_transaction) VALUES ('Achat matiere', 'DEPENSE', 16000.00, '2026-10-05');
INSERT INTO finance (description, type, montant, date_transaction) VALUES ('Achat matiere', 'DEPENSE', 18000.00, '2026-11-05');
INSERT INTO finance (description, type, montant, date_transaction) VALUES ('Achat matiere', 'DEPENSE', 22000.00, '2026-12-05');


-- 4. Salaires (Dépenses)
INSERT IGNORE INTO salaire (employe_id, mois, salaire_brut, statut) VALUES (1, '2026-01-28', 2500.00, 'PAYE');
INSERT IGNORE INTO salaire (employe_id, mois, salaire_brut, statut) VALUES (1, '2026-02-28', 2500.00, 'PAYE');
INSERT IGNORE INTO salaire (employe_id, mois, salaire_brut, statut) VALUES (1, '2026-03-28', 2500.00, 'PAYE');
INSERT IGNORE INTO salaire (employe_id, mois, salaire_brut, statut) VALUES (1, '2026-04-28', 2500.00, 'PAYE');
INSERT IGNORE INTO salaire (employe_id, mois, salaire_brut, statut) VALUES (1, '2026-05-28', 2500.00, 'PAYE');
INSERT IGNORE INTO salaire (employe_id, mois, salaire_brut, statut) VALUES (1, '2026-06-28', 2500.00, 'PAYE');
INSERT IGNORE INTO salaire (employe_id, mois, salaire_brut, statut) VALUES (1, '2026-07-28', 2500.00, 'PAYE');
INSERT IGNORE INTO salaire (employe_id, mois, salaire_brut, statut) VALUES (1, '2026-08-28', 2500.00, 'PAYE');
INSERT IGNORE INTO salaire (employe_id, mois, salaire_brut, statut) VALUES (1, '2026-09-28', 2500.00, 'PAYE');
INSERT IGNORE INTO salaire (employe_id, mois, salaire_brut, statut) VALUES (1, '2026-10-28', 2500.00, 'PAYE');
INSERT IGNORE INTO salaire (employe_id, mois, salaire_brut, statut) VALUES (1, '2026-11-28', 2500.00, 'PAYE');
INSERT IGNORE INTO salaire (employe_id, mois, salaire_brut, statut) VALUES (1, '2026-12-28', 2500.00, 'PAYE');


-- 5. Matières (Stock)
INSERT IGNORE INTO matiere (id, nom, quantite, unite) VALUES (1, 'Coton', 4500, 'kg');
INSERT IGNORE INTO matiere (id, nom, quantite, unite) VALUES (2, 'Soie', 1200, 'm');
INSERT IGNORE INTO matiere (id, nom, quantite, unite) VALUES (3, 'Boutons', 6702, 'unite');
-- Met à jour si elles existaient déjà
UPDATE matiere SET quantite = 4500 WHERE id = 1;
UPDATE matiere SET quantite = 1200 WHERE id = 2;
UPDATE matiere SET quantite = 6702 WHERE id = 3;

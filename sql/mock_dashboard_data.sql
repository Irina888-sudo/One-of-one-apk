USE oneofone;


INSERT IGNORE INTO client (id, nom, email, statut) VALUES (1, 'Client Test', 'test@test.com', 'ACTIF');
INSERT IGNORE INTO employe (id, nom, role, statut) VALUES (1, 'Employe Test', 'LIVREUR', 'ACTIF');


INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2601-0001', 1, 'LIVREE', 15200.50, '2026-01-15 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2601-0002', 1, 'LIVREE', 12300.00, '2026-01-20 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2602-0003', 1, 'LIVREE', 18400.00, '2026-02-10 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2603-0004', 1, 'LIVREE', 16500.00, '2026-03-05 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2604-0005', 1, 'LIVREE', 22100.00, '2026-04-12 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2605-0006', 1, 'LIVREE', 21000.00, '2026-05-18 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2606-0007', 1, 'LIVREE', 25600.00, '2026-06-10 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2606-0008', 1, 'LIVREE', 14200.00, '2026-06-15 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2606-0009', 1, 'LIVREE', 18050.00, '2026-06-20 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2607-0010', 1, 'LIVREE', 28000.00, '2026-07-10 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2608-0011', 1, 'LIVREE', 24000.00, '2026-08-10 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2609-0012', 1, 'LIVREE', 29000.00, '2026-09-10 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2610-0013', 1, 'LIVREE', 31000.00, '2026-10-10 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2611-0014', 1, 'LIVREE', 35000.00, '2026-11-10 10:00:00');
INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES ('CMD-2612-0015', 1, 'LIVREE', 42000.00, '2026-12-10 10:00:00');



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



INSERT IGNORE INTO matiere (id, nom, quantite, unite) VALUES (1, 'Coton', 4500, 'kg');
INSERT IGNORE INTO matiere (id, nom, quantite, unite) VALUES (2, 'Soie', 1200, 'm');
INSERT IGNORE INTO matiere (id, nom, quantite, unite) VALUES (3, 'Boutons', 6702, 'unite');

UPDATE matiere SET quantite = 4500 WHERE id = 1;
UPDATE matiere SET quantite = 1200 WHERE id = 2;
UPDATE matiere SET quantite = 6702 WHERE id = 3;

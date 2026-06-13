CREATE DATABASE oneofone;
USE oneofone;


--- ─── 1. UTILISATEURS (Auth) ───────────────────────────────
CREATE TABLE utilisateur (
id          INT PRIMARY KEY AUTO_INCREMENT,
email       VARCHAR(100) UNIQUE NOT NULL,
password    VARCHAR(255) NOT NULL,
role        ENUM('ADMIN','COMPTABLE') NOT NULL,
actif       BOOLEAN DEFAULT TRUE,
created_at  DATETIME DEFAULT NOW()
);

-- ─── 1. EMPLOYÉS ──────────────────────────────────────────────────────────────
CREATE TABLE employe (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    utilisateur_id  INT UNIQUE,                         
    nom             VARCHAR(100) NOT NULL,
    email           VARCHAR(100),
    telephone       VARCHAR(20),
    role            VARCHAR(50),
    salaire_brut    DECIMAL(10,2) DEFAULT 0.00,
    statut          ENUM('ACTIF','INACTIF') DEFAULT 'ACTIF',
    date_embauche   DATE DEFAULT (CURRENT_DATE)
);

-- ─── 2. CONGÉS ────────────────────────────────────────────────────────────────
CREATE TABLE conge (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    employe_id  INT,                                    
    date_debut  DATE NOT NULL,
    date_fin    DATE NOT NULL,
    nb_jours    INT
                GENERATED ALWAYS AS
                (DATEDIFF(date_fin, date_debut) + 1) STORED,
    motif       VARCHAR(200),
    statut      ENUM('EN_ATTENTE','VALIDE','REFUSE') DEFAULT 'EN_ATTENTE'
);

-- ─── 3. SALAIRES ──────────────────────────────────────────────────────────────
CREATE TABLE salaire (
    id            INT PRIMARY KEY AUTO_INCREMENT,
    employe_id    INT,                                 
    mois          DATE NOT NULL,                        
    salaire_brut  DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    jours_absents INT DEFAULT 0,
    deduction     DECIMAL(10,2)
                  GENERATED ALWAYS AS
                  (ROUND(salaire_brut / 30 * jours_absents, 2)) STORED,
    salaire_net   DECIMAL(10,2)
                  GENERATED ALWAYS AS
                  (ROUND(salaire_brut - (salaire_brut / 30 * jours_absents), 2)) STORED,
    statut        ENUM('ATTENTE','PAYE') DEFAULT 'ATTENTE',
    UNIQUE KEY uq_employe_mois (employe_id, mois)
);


-- ─── 5. MATIÈRES (Stock) ──────────────────────────────────
CREATE TABLE matiere (
id              INT PRIMARY KEY AUTO_INCREMENT,
nom             VARCHAR(100) NOT NULL,

quantite        DECIMAL(10,2) NOT NULL DEFAULT 0,
unite           VARCHAR(20),

valeur_unitaire DECIMAL(10,2) DEFAULT 0


);

-- ─── 6. COLLECTIONS ───────────────────────────────────────
CREATE TABLE collection (
id INT PRIMARY KEY AUTO_INCREMENT,
nom VARCHAR(100) NOT NULL,
date_debut DATE,
date_fin DATE,
statut ENUM('ACTIVE','ARCHIVEE') DEFAULT 'ACTIVE'
);

-- ─── 7. PRODUITS ──────────────────────────────────────────
CREATE TABLE produit (
id INT PRIMARY KEY AUTO_INCREMENT,
nom VARCHAR(100) NOT NULL,

categorie VARCHAR(50),
taille VARCHAR(20),
couleur VARCHAR(30),
prix DECIMAL(10,2),
image VARCHAR(255),

statut ENUM('DISPONIBLE','VENDU')
DEFAULT 'DISPONIBLE',

collection_id INT NULL,

CONSTRAINT fk_produit_collection
FOREIGN KEY (collection_id)
REFERENCES collection(id)
);

-- ─── 8. CLIENTS ───────────────────────────────────────────
CREATE TABLE client (
id          INT PRIMARY KEY AUTO_INCREMENT,
nom         VARCHAR(100) NOT NULL,
email       VARCHAR(100),
telephone   VARCHAR(20),
adresse     TEXT,
statut      ENUM('ACTIF','BLOQUE') DEFAULT 'ACTIF',
motif_blocage VARCHAR(200),
created_at  DATETIME DEFAULT NOW()
);

-- ─── COMMANDES ────────────────────────────────────────────
CREATE TABLE commande (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    numero          VARCHAR(20) UNIQUE NOT NULL,
    client_id       INT NOT NULL,

    statut ENUM(
        'ATTENTE',
        'PRODUCTION',
       
        'LIVREE',
        'ANNULEE'
    ) DEFAULT 'ATTENTE',

    montant_total   DECIMAL(10,2) DEFAULT 0,
    date_commande   DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (client_id)
        REFERENCES client(id)
);


-- ─── LIGNES COMMANDE ──────────────────────────────────────
CREATE TABLE ligne_commande (
    id              INT PRIMARY KEY AUTO_INCREMENT,

    commande_id     INT NOT NULL,
    produit_id      INT NOT NULL,

    quantite        INT NOT NULL DEFAULT 1,
    prix_unitaire   DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (commande_id)
        REFERENCES commande(id),

    FOREIGN KEY (produit_id)
        REFERENCES produit(id)
);


-- ─── LIVRAISONS ───────────────────────────────────────────
CREATE TABLE livraison (
    id              INT PRIMARY KEY AUTO_INCREMENT,

    numero          VARCHAR(20) UNIQUE NOT NULL,

    commande_id     INT UNIQUE NOT NULL,

    employe_id      INT NULL,

    livreur         VARCHAR(100),
    lieu            VARCHAR(100),

    frais           DECIMAL(10,2) DEFAULT 0,

    statut ENUM(
        'ATTENTE',
        'EN_COURS',
        'LIVRE'
    ) DEFAULT 'ATTENTE',

    date_livraison  DATE,

    FOREIGN KEY (commande_id)
        REFERENCES commande(id),

    FOREIGN KEY (employe_id)
        REFERENCES employe(id)
);



-- ─── 12. FINANCES ─────────────────────────────────────────
CREATE TABLE finance (
id               INT PRIMARY KEY AUTO_INCREMENT,
description      VARCHAR(200) NOT NULL,
type             ENUM('RECETTE','DEPENSE') NOT NULL,
montant          DECIMAL(10,2) NOT NULL,
date_transaction DATE NOT NULL,
commande_id      INT,
FOREIGN KEY (commande_id) REFERENCES commande(id)
);





-- ══════════════════════════════════════════════════════════
-- VIEWS
-- ══════════════════════════════════════════════════════════

-- VIEW 1 : Commandes avec nom client + montant calculé
CREATE VIEW vue_commandes AS
SELECT c.id, c.numero, c.statut, c.date_commande,
cl.nom AS client_nom, cl.email AS client_email,
COALESCE(SUM(lc.quantite * lc.prix_unitaire), 0) AS montant_total
FROM commande c
JOIN client cl ON c.client_id = cl.id
LEFT JOIN ligne_commande lc ON lc.commande_id = c.id
GROUP BY c.id, c.numero, c.statut, c.date_commande,
cl.nom, cl.email;

-- VIEW 2 : Stock avec alertes
CREATE VIEW vue_stock_alertes AS
SELECT m.id, m.nom, m.quantite, m.unite, m.valeur_unitaire,
CASE
WHEN m.quantite = 0                       THEN 'RUPTURE'
WHEN m.quantite <= 5                      THEN 'CRITIQUE'
WHEN m.quantite <= 10                     THEN 'BAS'
ELSE 'OK'
END AS statut_stock
FROM matiere m;

-- VIEW 3 : Salaires avec nom employé
CREATE VIEW vue_salaires AS
SELECT s.id, s.mois, s.salaire_brut, s.jours_absents,
s.deduction, s.salaire_net, s.statut,
e.nom AS employe_nom, e.role AS employe_role
FROM salaire s
JOIN employe e ON s.employe_id = e.id;

-- VIEW 4 : Livraisons avec commande + livreur
CREATE VIEW vue_livraisons AS
SELECT l.id, l.numero, l.lieu, l.frais, l.statut, l.date_livraison,
c.numero AS commande_numero,
COALESCE(e.nom, l.livreur) AS livreur_nom
FROM livraison l
JOIN commande c ON l.commande_id = c.id
LEFT JOIN employe e ON l.employe_id = e.id;

-- VIEW 5 : Finances résumé par mois
CREATE VIEW vue_finances_resume AS
SELECT DATE_FORMAT(date_transaction, '%Y-%m') AS mois,
SUM(CASE WHEN type = 'RECETTE' THEN montant ELSE 0 END) AS total_recettes,
SUM(CASE WHEN type = 'DEPENSE' THEN montant ELSE 0 END) AS total_depenses,
SUM(CASE WHEN type = 'RECETTE' THEN montant ELSE -montant END) AS benefice_net
FROM finance
GROUP BY DATE_FORMAT(date_transaction, '%Y-%m');

-- VIEW 6 : Clients avec nb commandes
CREATE VIEW vue_clients AS
SELECT cl.id, cl.nom, cl.email, cl.telephone, cl.adresse, cl.statut,
COUNT(c.id) AS nb_commandes,
MAX(c.date_commande) AS derniere_commande
FROM client cl
LEFT JOIN commande c ON c.client_id = cl.id
GROUP BY cl.id, cl.nom, cl.email, cl.telephone, cl.adresse, cl.statut;

-- VIEW 7 : Produits avec collection
CREATE VIEW vue_produits AS
SELECT p.id, p.nom, p.categorie, p.taille, p.couleur,
p.prix, p.statut, p.image, col.nom AS collection_nom
FROM produit p
LEFT JOIN collection col ON p.collection_id = col.id;

-- VIEW 8 : Employés avec compte utilisateur
CREATE VIEW vue_employes AS
SELECT e.id, e.nom, e.email, e.telephone, e.role,
e.salaire_brut, e.statut, e.date_embauche,
u.email AS email_login, u.role AS role_app
FROM employe e
LEFT JOIN utilisateur u ON e.utilisateur_id = u.id;



-- VIEW 10 : Dashboard KPI
CREATE VIEW vue_dashboard_kpi AS
SELECT
(SELECT COALESCE(SUM(montant), 0)
FROM finance
WHERE type = 'RECETTE'
AND MONTH(date_transaction) = MONTH(NOW())
AND YEAR(date_transaction)  = YEAR(NOW())) AS recettes_mois,

(SELECT COUNT(*)
FROM commande
WHERE DATE(date_commande) = CURDATE()) AS commandes_jour,

(SELECT COALESCE(SUM(montant), 0)
FROM finance
WHERE type = 'RECETTE'
AND MONTH(date_transaction) = MONTH(NOW())
AND YEAR(date_transaction)  = YEAR(NOW()))
-
(SELECT COALESCE(SUM(montant), 0)
FROM finance
WHERE type = 'DEPENSE'
AND MONTH(date_transaction) = MONTH(NOW())
AND YEAR(date_transaction)  = YEAR(NOW())) AS benefice_net,

(SELECT COUNT(*)
FROM matiere
WHERE quantite <= 5) AS alertes_stock,

(SELECT COUNT(*) FROM produit) AS total_produits,

(SELECT COUNT(*)
FROM salaire
WHERE statut = 'ATTENTE'
AND MONTH(mois) = MONTH(NOW())
AND YEAR(mois)  = YEAR(NOW())) AS salaires_attente;


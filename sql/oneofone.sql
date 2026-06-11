CREATE DATABASE oneofone;
USE oneofone;


-- ─── 1. UTILISATEURS (Auth) ───────────────────────────────
CREATE TABLE utilisateur (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    email       VARCHAR(100) UNIQUE NOT NULL,
    password    VARCHAR(255) NOT NULL,        -- mot de passe hashé (SHA-256)
    role        ENUM('ADMIN','COMPTABLE','EMPLOYE') NOT NULL,
    actif       BOOLEAN DEFAULT TRUE,
    created_at  DATETIME DEFAULT NOW()
);

-- ─── 2. EMPLOYÉS (lié à utilisateur) ──────────────────────
CREATE TABLE employe (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    utilisateur_id  INT UNIQUE,               -- ← CORRECTION : login employé possible
    nom             VARCHAR(100) NOT NULL,
    email           VARCHAR(100),
    telephone       VARCHAR(20),
    role            VARCHAR(50),
    salaire_brut    DECIMAL(10,2),
    statut          ENUM('ACTIF','INACTIF') DEFAULT 'ACTIF',
    date_embauche   DATE,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(id)
);

-- ─── 3. CONGÉS ─────────────────────────────────────────────
CREATE TABLE conge (                          -- ← CORRECTION : table manquante
    id              INT PRIMARY KEY AUTO_INCREMENT,
    employe_id      INT NOT NULL,
    date_debut      DATE NOT NULL,
    date_fin        DATE NOT NULL,
    nb_jours        INT NOT NULL,
    motif           VARCHAR(200),
    statut          ENUM('EN_ATTENTE','VALIDE','REFUSE') DEFAULT 'EN_ATTENTE',
    FOREIGN KEY (employe_id) REFERENCES employe(id)
);

-- ─── 4. FOURNISSEURS ───────────────────────────────────────
CREATE TABLE fournisseur (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    nom         VARCHAR(100) NOT NULL,
    telephone   VARCHAR(20),
    email       VARCHAR(100),
    adresse     TEXT
);

-- ─── 5. MATIÈRES (Stock) ───────────────────────────────────
CREATE TABLE matiere (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    nom             VARCHAR(100) NOT NULL,
    reference       VARCHAR(50) UNIQUE,
    quantite        DECIMAL(10,2) NOT NULL DEFAULT 0,
    unite           VARCHAR(20),
    seuil_alerte    DECIMAL(10,2) DEFAULT 0,
    valeur_unitaire DECIMAL(10,2) DEFAULT 0,
    fournisseur_id  INT,                      -- ← CORRECTION : lien fournisseur
    FOREIGN KEY (fournisseur_id) REFERENCES fournisseur(id)
);

-- ─── 6. COLLECTIONS ────────────────────────────────────────
CREATE TABLE collection (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    nom         VARCHAR(100) NOT NULL,
    date_debut  DATE,
    date_fin    DATE,
    statut      ENUM('ACTIVE','ARCHIVEE') DEFAULT 'ACTIVE'
);

-- ─── 7. PRODUITS ────────────────────────────────────────────
CREATE TABLE produit (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    nom             VARCHAR(100) NOT NULL,
    sku             VARCHAR(50) UNIQUE,       -- ex: OOO-24-001
    categorie       VARCHAR(50),
    taille          VARCHAR(20),
    couleur         VARCHAR(30),
    prix            DECIMAL(10,2),
    statut          ENUM('DISPONIBLE','VENDU') DEFAULT 'DISPONIBLE',
    collection_id   INT,
    FOREIGN KEY (collection_id) REFERENCES collection(id)
);

-- ─── 8. CLIENTS ─────────────────────────────────────────────
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

-- ─── 9. COMMANDES ───────────────────────────────────────────
CREATE TABLE commande (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    numero          VARCHAR(20) UNIQUE,       -- ex: OO-2026-9842
    client_id       INT NOT NULL,
    statut          ENUM('ATTENTE','PRODUCTION','PRETE','LIVREE','ANNULEE') DEFAULT 'ATTENTE',
    montant_total   DECIMAL(10,2) DEFAULT 0,  -- calculé depuis lignes_commande
    date_commande   DATETIME DEFAULT NOW(),
    FOREIGN KEY (client_id) REFERENCES client(id)
);

-- ─── 10. LIGNES COMMANDE ────────────────────────────────────
CREATE TABLE ligne_commande (                 -- ← CORRECTION : multi-produits/commande
    id              INT PRIMARY KEY AUTO_INCREMENT,
    commande_id     INT NOT NULL,
    produit_id      INT NOT NULL,
    quantite        INT NOT NULL DEFAULT 1,
    prix_unitaire   DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (commande_id) REFERENCES commande(id),
    FOREIGN KEY (produit_id) REFERENCES produit(id)
);

-- ─── 11. LIVRAISONS ─────────────────────────────────────────
CREATE TABLE livraison (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    numero          VARCHAR(20) UNIQUE,       -- ex: LV-9842
    commande_id     INT NOT NULL,
    employe_id      INT,                      -- ← CORRECTION : livreur interne
    livreur_externe VARCHAR(100),             -- livreur externe (si employe_id NULL)
    lieu            VARCHAR(100),
    frais           DECIMAL(10,2) DEFAULT 0,
    statut          ENUM('ATTENTE','EN_COURS','LIVRE') DEFAULT 'ATTENTE',
    date_livraison  DATE,
    FOREIGN KEY (commande_id) REFERENCES commande(id),
    FOREIGN KEY (employe_id) REFERENCES employe(id)
);

-- ─── 12. FINANCES ───────────────────────────────────────────
CREATE TABLE finance (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    description     VARCHAR(200) NOT NULL,
    type            ENUM('RECETTE','DEPENSE') NOT NULL,
    sous_type       ENUM('FIXE','VARIABLE') DEFAULT 'VARIABLE',
    montant         DECIMAL(10,2) NOT NULL,
    date_transaction DATE NOT NULL,
    livraison_id    INT,                      -- lien auto si recette depuis livraison
    FOREIGN KEY (livraison_id) REFERENCES livraison(id)
);

-- ─── 13. SALAIRES ───────────────────────────────────────────
CREATE TABLE salaire (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    employe_id      INT NOT NULL,
    mois            DATE NOT NULL,            -- ex: 2026-06-01
    salaire_brut    DECIMAL(10,2) NOT NULL,
    jours_absents   INT DEFAULT 0,
    deduction       DECIMAL(10,2)             -- calculé : brut/30 × jours_absents
                    GENERATED ALWAYS AS (ROUND(salaire_brut/30*jours_absents,2)) STORED,
    salaire_net     DECIMAL(10,2)             -- calculé : brut - déduction
                    GENERATED ALWAYS AS (ROUND(salaire_brut - (salaire_brut/30*jours_absents),2)) STORED,
    statut          ENUM('ATTENTE','PAYE') DEFAULT 'ATTENTE',
    FOREIGN KEY (employe_id) REFERENCES employe(id)
);

-- ─── 14. NOTIFICATIONS ──────────────────────────────────────
CREATE TABLE notification (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    type            ENUM('CRITIQUE','ATTENTION','INFO','IA') NOT NULL,
    message         TEXT NOT NULL,
    destinataire_id INT,                      -- ← CORRECTION : qui reçoit
    lu              BOOLEAN DEFAULT FALSE,
    date_creation   DATETIME DEFAULT NOW(),
    FOREIGN KEY (destinataire_id) REFERENCES utilisateur(id)
);

-- ══════════════════════════════════════════════════════════
-- VIEWS (10 views pour simplifier les requêtes dans les JSP)
-- ══════════════════════════════════════════════════════════

-- VIEW 1 : Commandes avec nom client + montant calculé
CREATE VIEW vue_commandes AS
SELECT c.id, c.numero, c.statut, c.date_commande,
       cl.nom AS client_nom, cl.email AS client_email,
       COALESCE(SUM(lc.quantite * lc.prix_unitaire), 0) AS montant_total
FROM commande c
JOIN client cl ON c.client_id = cl.id
LEFT JOIN ligne_commande lc ON lc.commande_id = c.id
GROUP BY c.id;

-- VIEW 2 : Stock avec alertes
CREATE VIEW vue_stock_alertes AS
SELECT m.id, m.nom, m.reference, m.quantite, m.unite,
       m.seuil_alerte, m.valeur_unitaire,
       f.nom AS fournisseur_nom,
       CASE
           WHEN m.quantite = 0 THEN 'RUPTURE'
           WHEN m.quantite <= m.seuil_alerte THEN 'CRITIQUE'
           WHEN m.quantite <= m.seuil_alerte * 1.5 THEN 'BAS'
           ELSE 'OK'
       END AS statut_stock
FROM matiere m
LEFT JOIN fournisseur f ON m.fournisseur_id = f.id;

-- VIEW 3 : Salaires avec nom employé + jours congé du mois
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
       COALESCE(e.nom, l.livreur_externe) AS livreur_nom
FROM livraison l
JOIN commande c ON l.commande_id = c.id
LEFT JOIN employe e ON l.employe_id = e.id;

-- VIEW 5 : Tableau de bord finances (recettes vs dépenses par mois)
CREATE VIEW vue_finances_resume AS
SELECT DATE_FORMAT(date_transaction,'%Y-%m') AS mois,
       SUM(CASE WHEN type='RECETTE' THEN montant ELSE 0 END) AS total_recettes,
       SUM(CASE WHEN type='DEPENSE' THEN montant ELSE 0 END) AS total_depenses,
       SUM(CASE WHEN type='RECETTE' THEN montant ELSE -montant END) AS benefice_net
FROM finance
GROUP BY DATE_FORMAT(date_transaction,'%Y-%m');

-- VIEW 6 : Clients avec nb commandes + dernière commande
CREATE VIEW vue_clients AS
SELECT cl.id, cl.nom, cl.email, cl.telephone, cl.adresse, cl.statut,
       COUNT(c.id) AS nb_commandes,
       MAX(c.date_commande) AS derniere_commande
FROM client cl
LEFT JOIN commande c ON c.client_id = cl.id
GROUP BY cl.id;

-- VIEW 7 : Produits avec collection + statut vendus
CREATE VIEW vue_produits AS
SELECT p.id, p.nom, p.sku, p.categorie, p.taille, p.couleur,
       p.prix, p.statut, col.nom AS collection_nom
FROM produit p
LEFT JOIN collection col ON p.collection_id = col.id;

-- VIEW 8 : Employés avec utilisateur (login possible)
CREATE VIEW vue_employes AS
SELECT e.id, e.nom, e.email, e.telephone, e.role,
       e.salaire_brut, e.statut, e.date_embauche,
       u.email AS email_login, u.role AS role_app
FROM employe e
LEFT JOIN utilisateur u ON e.utilisateur_id = u.id;

-- VIEW 9 : Notifications non lues par utilisateur
CREATE VIEW vue_notifications_nonlues AS
SELECT n.id, n.type, n.message, n.date_creation,
       u.email AS destinataire_email
FROM notification n
JOIN utilisateur u ON n.destinataire_id = u.id
WHERE n.lu = FALSE
ORDER BY n.date_creation DESC;

-- VIEW 10 : Dashboard KPI (pour dashboard-admin.jsp)
CREATE VIEW vue_dashboard_kpi AS
SELECT
    (SELECT COALESCE(SUM(montant),0) FROM finance
     WHERE type='RECETTE' AND MONTH(date_transaction)=MONTH(NOW())) AS recettes_mois,
    (SELECT COUNT(*) FROM commande
     WHERE DATE(date_commande)=CURDATE()) AS commandes_jour,
    (SELECT COALESCE(SUM(montant),0) FROM finance
     WHERE type='RECETTE' AND MONTH(date_transaction)=MONTH(NOW()))
    - (SELECT COALESCE(SUM(montant),0) FROM finance
       WHERE type='DEPENSE' AND MONTH(date_transaction)=MONTH(NOW())) AS benefice_net,
    (SELECT COUNT(*) FROM matiere WHERE quantite<=seuil_alerte) AS alertes_stock,
    (SELECT COUNT(*) FROM produit) AS total_produits,
    (SELECT COUNT(*) FROM salaire WHERE statut='ATTENTE'
     AND MONTH(mois)=MONTH(NOW())) AS salaires_attente;
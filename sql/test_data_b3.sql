

USE oneofone;


CREATE TABLE IF NOT EXISTS utilisateur (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    actif BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS client (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(150) NOT NULL,
    email VARCHAR(150),
    telephone VARCHAR(50),
    adresse VARCHAR(255),
    statut VARCHAR(20) NOT NULL DEFAULT 'ACTIF',
    motif_blocage VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS matiere (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(150) NOT NULL,
    description VARCHAR(255),
    quantite INT NOT NULL DEFAULT 0,
    unite VARCHAR(50),
    statut VARCHAR(20) NOT NULL DEFAULT 'ACTIF',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



INSERT IGNORE INTO utilisateur (id, email, password, role, actif) VALUES
(1, 'admin@oneofone.fr', SHA2('admin123', 256), 'ADMIN', TRUE);

INSERT INTO client (nom, email, telephone, adresse, statut) VALUES
('Jean-Baptiste Durand',  'durand.jb@email.com',    '06 12 34 56 78', '12 Rue de la Paix, 75002 Paris',            'ACTIF'),
('Marie Laurent',         'marie.l@domain.fr',       '07 98 76 54 32', '45 Avenue Foch, 69006 Lyon',                'ACTIF'),
('Pierre Roche',          'proche@outlook.com',       '06 45 12 98 67', '8 Bis Quai des Orfèvres, 33000 Bordeaux',  'ACTIF'),
('Sophie Lemercier',      'sophie.lem@gmail.com',    '01 44 22 11 00', '21 Rue du Palais, 06000 Nice',              'ACTIF'),
('Alice Fontaine',        'alice.f@email.com',        '06 77 88 99 00', '3 Place Bellecour, 69002 Lyon',             'BLOQUE'),
('Marc Aubert',           'marc.a@pro.fr',            '07 11 22 33 44', '15 Rue Nationale, 59000 Lille',             'ACTIF'),
('Emma Bernard',          'emma.b@gmail.com',         '06 55 44 33 22', '7 Allée des Roses, 31000 Toulouse',         'ACTIF'),
('Lucas Martin',          'lucas.m@studio.com',       '06 99 88 77 66', '22 Rue des Arts, 44000 Nantes',             'ACTIF'),
('Chloé Girard',          'chloe.g@mail.fr',          '07 33 44 55 66', '9 Boulevard Haussmann, 75009 Paris',        'BLOQUE'),
('Thomas Petit',          'thomas.p@email.com',       '06 22 11 00 99', '4 Rue Victor Hugo, 13001 Marseille',        'ACTIF'),
('Inès Morel',            'ines.m@domain.fr',         '07 66 55 44 33', '18 Avenue de la Gare, 67000 Strasbourg',   'ACTIF'),
('Antoine Leroy',         'antoine.l@outlook.com',    '06 44 55 66 77', '30 Rue du Commerce, 75015 Paris',           'ACTIF');


SELECT 'Clients insérés :' AS info, COUNT(*) AS nb FROM client;

CREATE INDEX idx_employe_statut ON employe(statut);

CREATE INDEX idx_conge_statut ON conge(statut);
CREATE INDEX idx_conge_dates ON conge(date_debut, date_fin);

CREATE INDEX idx_salaire_statut_mois ON salaire(statut, mois);

CREATE INDEX idx_matiere_quantite ON matiere(quantite);

CREATE INDEX idx_collection_statut ON collection(statut);

CREATE INDEX idx_produit_statut ON produit(statut);
CREATE INDEX idx_produit_categorie ON produit(categorie);
CREATE INDEX idx_produit_categorie_statut ON produit(categorie, statut);

CREATE INDEX idx_client_statut ON client(statut);
CREATE INDEX idx_client_email ON client(email);

CREATE INDEX idx_commande_statut ON commande(statut);
CREATE INDEX idx_commande_date ON commande(date_commande);
CREATE INDEX idx_commande_statut_date ON commande(statut, date_commande);

CREATE INDEX idx_lc_commande_produit ON ligne_commande(commande_id, produit_id);

CREATE INDEX idx_livraison_statut ON livraison(statut);
CREATE INDEX idx_livraison_date ON livraison(date_livraison);

CREATE INDEX idx_finance_type_date ON finance(type, date_transaction);
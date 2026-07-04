package dao;

import model.Produit;
import model.Matiere;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProduitDAO {

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return DriverManager.getConnection("jdbc:mysql://localhost:3306/oneofone", "root", "");
    }

    // ── Mapper ─────────────────────────────────────────────
    private Produit map(ResultSet rs) throws SQLException {
        Produit p = new Produit();
        p.setId(rs.getInt("id"));
        p.setNom(rs.getString("nom"));
        p.setCategorie(rs.getString("categorie"));
        p.setTaille(rs.getString("taille"));
        p.setCouleur(rs.getString("couleur"));
        p.setPrix(rs.getDouble("prix"));
        p.setStatut(rs.getString("statut"));
        int colId = rs.getInt("collection_id");
        p.setCollectionId(rs.wasNull() ? null : colId);
        p.setCollectionNom(rs.getString("collection_nom"));
        p.setImage(rs.getString("image"));
        return p;
    }

    private static final String BASE_SELECT = "SELECT p.*, c.nom AS collection_nom " +
            "FROM produit p LEFT JOIN collection c ON p.collection_id = c.id ";

    // ── Lister avec filtres (maquette : categorie, statut, collection, taille,
    // couleur, recherche) ──
    public List<Produit> lister(String recherche, String categorie,
            String statut, String collectionId,
            String taille, String couleur) throws SQLException {
        List<Produit> liste = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT + "WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (recherche != null && !recherche.trim().isEmpty()) {
            sql.append("AND p.nom LIKE ? ");
            params.add("%" + recherche.trim() + "%");
        }
        if (categorie != null && !categorie.trim().isEmpty()) {
            sql.append("AND p.categorie = ? ");
            params.add(categorie);
        }
        if (statut != null && !statut.trim().isEmpty()) {
            sql.append("AND p.statut = ? ");
            params.add(statut);
        }
        if (collectionId != null && !collectionId.trim().isEmpty()) {
            sql.append("AND p.collection_id = ? ");
            params.add(Integer.parseInt(collectionId));
        }
        if (taille != null && !taille.trim().isEmpty()) {
            sql.append("AND p.taille = ? ");
            params.add(taille);
        }
        if (couleur != null && !couleur.trim().isEmpty()) {
            sql.append("AND p.couleur = ? ");
            params.add(couleur);
        }
        sql.append("ORDER BY p.id DESC");

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next())
                liste.add(map(rs));
        }
        return liste;
    }

    // ── Trouver par ID ─────────────────────────────────────
    public Produit trouverParId(int id) throws SQLException {
        String sql = BASE_SELECT + "WHERE p.id = ?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return map(rs);
        }
        return null;
    }

    // ── Ajouter ────────────────────────────────────────────
    public void ajouter(Produit p) throws SQLException {
        ajouter(p, null, null);
    }

    public void ajouter(Produit p, List<Integer> matiereIds, List<Double> quantites) throws SQLException {
        String sqlProduit = "INSERT INTO produit (nom, categorie, taille, couleur, prix, statut, collection_id, image) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlPM = "INSERT INTO produit_matiere (produit_id, matiere_id, quantite) VALUES (?, ?, ?)";
        String sqlSelectMatiere = "SELECT nom, quantite FROM matiere WHERE id = ? FOR UPDATE";
        String sqlUpdateMatiere = "UPDATE matiere SET quantite = quantite - ? WHERE id = ?";
        
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            int prodId;
            try (PreparedStatement ps = conn.prepareStatement(sqlProduit, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, p.getNom());
                ps.setString(2, p.getCategorie());
                ps.setString(3, p.getTaille());
                ps.setString(4, p.getCouleur());
                ps.setDouble(5, p.getPrix());
                ps.setString(6, p.getStatut() != null ? p.getStatut() : "DISPONIBLE");
                if (p.getCollectionId() != null)
                    ps.setInt(7, p.getCollectionId());
                else
                    ps.setNull(7, Types.INTEGER);
                ps.setString(8, p.getImage());
                ps.executeUpdate();
                
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        prodId = rs.getInt(1);
                        p.setId(prodId);
                    } else {
                        throw new SQLException("Échec de la création du produit, aucun ID généré.");
                    }
                }
            }
            
            if (matiereIds != null && quantites != null) {
                for (int i = 0; i < matiereIds.size(); i++) {
                    int matId = matiereIds.get(i);
                    double qtyNeeded = quantites.get(i);
                    if (qtyNeeded <= 0) continue;
                    
                    // Check stock with lock
                    try (PreparedStatement psSelect = conn.prepareStatement(sqlSelectMatiere)) {
                        psSelect.setInt(1, matId);
                        try (ResultSet rs = psSelect.executeQuery()) {
                            if (rs.next()) {
                                String nomMat = rs.getString("nom");
                                double currentQty = rs.getDouble("quantite");
                                if (currentQty < qtyNeeded) {
                                    throw new SQLException("Stock insuffisant pour la matière \"" + nomMat + 
                                        "\" (disponible: " + currentQty + ", demandé: " + qtyNeeded + ")");
                                }
                            } else {
                                throw new SQLException("Matière avec l'ID " + matId + " introuvable.");
                            }
                        }
                    }
                    
                    // Decrement stock
                    try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdateMatiere)) {
                        psUpdate.setDouble(1, qtyNeeded);
                        psUpdate.setInt(2, matId);
                        psUpdate.executeUpdate();
                    }
                    
                    // Insert association
                    try (PreparedStatement psPM = conn.prepareStatement(sqlPM)) {
                        psPM.setInt(1, prodId);
                        psPM.setInt(2, matId);
                        psPM.setDouble(3, qtyNeeded);
                        psPM.executeUpdate();
                    }
                }
            }
            
            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { /* ignore */ }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { /* ignore */ }
            }
        }
    }

    // ── Modifier ───────────────────────────────────────────
    public void modifier(Produit p) throws SQLException {
        String sql = "UPDATE produit SET nom=?, categorie=?, taille=?, couleur=?, prix=?, statut=?, collection_id=?, image=? " +
                "WHERE id=?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getNom());
            ps.setString(2, p.getCategorie());
            ps.setString(3, p.getTaille());
            ps.setString(4, p.getCouleur());
            ps.setDouble(5, p.getPrix());
            ps.setString(6, p.getStatut());
            if (p.getCollectionId() != null)
                ps.setInt(7, p.getCollectionId());
            else
                ps.setNull(7, Types.INTEGER);
            ps.setString(8, p.getImage());
            ps.setInt(9, p.getId());
            ps.executeUpdate();
        }
    }

    // ── Supprimer ──────────────────────────────────────────
    public void supprimer(int id) throws SQLException {
        String sql = "DELETE FROM produit WHERE id = ?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ── Listes distinctes pour les filtres ─────────────────
    public List<String> getCategories() throws SQLException {
        return getDistinct("SELECT DISTINCT categorie FROM produit WHERE categorie IS NOT NULL ORDER BY categorie");
    }

    public List<String> getTailles() throws SQLException {
        return getDistinct("SELECT DISTINCT taille FROM produit WHERE taille IS NOT NULL ORDER BY taille");
    }

    public List<String> getCouleurs() throws SQLException {
        return getDistinct("SELECT DISTINCT couleur FROM produit WHERE couleur IS NOT NULL ORDER BY couleur");
    }

    private List<String> getDistinct(String sql) throws SQLException {
        List<String> result = new ArrayList<>();
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                result.add(rs.getString(1));
        }
        return result;
    }

    // ── Compteurs KPI ──────────────────────────────────────
    public int compterTotal() throws SQLException {
        return compterParStatut(null);
    }

    public int compterParStatut(String statut) throws SQLException {
        String sql = statut == null
                ? "SELECT COUNT(*) FROM produit"
                : "SELECT COUNT(*) FROM produit WHERE statut = ?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            if (statut != null)
                ps.setString(1, statut);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getInt(1);
        }
        return 0;
    }

    public List<Matiere> getMatieresParProduit(int produitId) throws SQLException {
        List<Matiere> liste = new ArrayList<>();
        String sql = "SELECT m.id, m.nom, pm.quantite, m.unite, m.valeur_unitaire " +
                     "FROM produit_matiere pm " +
                     "JOIN matiere m ON pm.matiere_id = m.id " +
                     "WHERE pm.produit_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, produitId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Matiere m = new Matiere();
                    m.setId(rs.getInt("id"));
                    m.setNom(rs.getString("nom"));
                    m.setQuantite(rs.getDouble("quantite")); // Quantity used
                    m.setUnite(rs.getString("unite"));
                    m.setValeurUnitaire(rs.getDouble("valeur_unitaire"));
                    liste.add(m);
                }
            }
        }
        return liste;
    }
}

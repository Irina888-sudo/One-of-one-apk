package dao;

import model.Produit;

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

        if (recherche != null && !recherche.isBlank()) {
            sql.append("AND p.nom LIKE ? ");
            params.add("%" + recherche.trim() + "%");
        }
        if (categorie != null && !categorie.isBlank()) {
            sql.append("AND p.categorie = ? ");
            params.add(categorie);
        }
        if (statut != null && !statut.isBlank()) {
            sql.append("AND p.statut = ? ");
            params.add(statut);
        }
        if (collectionId != null && !collectionId.isBlank()) {
            sql.append("AND p.collection_id = ? ");
            params.add(Integer.parseInt(collectionId));
        }
        if (taille != null && !taille.isBlank()) {
            sql.append("AND p.taille = ? ");
            params.add(taille);
        }
        if (couleur != null && !couleur.isBlank()) {
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
        String sql = "INSERT INTO produit (nom, categorie, taille, couleur, prix, statut, collection_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
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
            ps.executeUpdate();
        }
    }

    // ── Modifier ───────────────────────────────────────────
    public void modifier(Produit p) throws SQLException {
        String sql = "UPDATE produit SET nom=?, categorie=?, taille=?, couleur=?, prix=?, statut=?, collection_id=? " +
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
            ps.setInt(8, p.getId());
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
}

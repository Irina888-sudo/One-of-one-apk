package dao;

import model.Matiere;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;

public class MatiereDAO {

    private Matiere construireMatiere(ResultSet rs) throws SQLException {
        Matiere m = new Matiere();
        m.setId(rs.getInt("id"));
        m.setNom(rs.getString("nom"));
        m.setQuantite(rs.getInt("quantite"));
        m.setUnite(rs.getString("unite"));

        ResultSetMetaData meta = rs.getMetaData();
        boolean hasDescription = false;
        boolean hasStatut = false;
        boolean hasCreatedAt = false;

        for (int i = 1; i <= meta.getColumnCount(); i++) {
            String columnName = meta.getColumnLabel(i);
            if ("description".equalsIgnoreCase(columnName)) {
                hasDescription = true;
            } else if ("statut".equalsIgnoreCase(columnName)) {
                hasStatut = true;
            } else if ("created_at".equalsIgnoreCase(columnName)) {
                hasCreatedAt = true;
            }
        }

        m.setDescription(hasDescription ? rs.getString("description") : "");
        m.setStatut(hasStatut ? rs.getString("statut") : "ACTIF");
        m.setCreatedAt(hasCreatedAt ? rs.getString("created_at") : null);
        return m;
    }

    private boolean hasColumn(Connection conn, String columnName) throws SQLException {
        String sql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'matiere' AND COLUMN_NAME = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, columnName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public ArrayList<Matiere> lister() {
        return listerTous();
    }

    public ArrayList<Matiere> listerTous() {
        ArrayList<Matiere> liste = new ArrayList<Matiere>();
        String sql = "SELECT * FROM matiere ORDER BY nom ASC";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                liste.add(construireMatiere(rs));
            }

            rs.close();
            ps.close();
            conn.close();
        } catch (SQLException e) {
            System.err.println("Erreur MatiereDAO.listerTous() : " + e.getMessage());
        }

        return liste;
    }

    public ArrayList<Matiere> listerParStatut(String statut) {
        ArrayList<Matiere> liste = new ArrayList<Matiere>();

        try (Connection conn = DBConnection.getConnection()) {
            boolean hasStatut = hasColumn(conn, "statut");
            String sql;

            if (hasStatut) {
                sql = "SELECT * FROM matiere WHERE statut = ? ORDER BY nom ASC";
            } else {
                sql = "SELECT * FROM matiere ORDER BY nom ASC";
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (hasStatut) {
                    ps.setString(1, statut);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        liste.add(construireMatiere(rs));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Erreur MatiereDAO.listerParStatut() : " + e.getMessage());
        }

        return liste;
    }

    public ArrayList<Matiere> rechercher(String texte) {
        ArrayList<Matiere> liste = new ArrayList<Matiere>();

        try (Connection conn = DBConnection.getConnection()) {
            boolean hasDescription = hasColumn(conn, "description");
            String sql;

            if (hasDescription) {
                sql = "SELECT * FROM matiere WHERE nom LIKE ? OR description LIKE ? ORDER BY nom ASC";
            } else {
                sql = "SELECT * FROM matiere WHERE nom LIKE ? ORDER BY nom ASC";
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                String recherche = "%" + texte.trim() + "%";
                ps.setString(1, recherche);
                if (hasDescription) {
                    ps.setString(2, recherche);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        liste.add(construireMatiere(rs));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Erreur MatiereDAO.rechercher() : " + e.getMessage());
        }

        return liste;
    }

    public Matiere trouverParId(int id) {
        Matiere matiere = null;
        String sql = "SELECT * FROM matiere WHERE id = ?";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                matiere = construireMatiere(rs);
            }

            rs.close();
            ps.close();
            conn.close();
        } catch (SQLException e) {
            System.err.println("Erreur MatiereDAO.trouverParId() : " + e.getMessage());
        }

        return matiere;
    }

    public boolean ajouter(Matiere matiere) {
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasDescription = hasColumn(conn, "description");
            boolean hasStatut = hasColumn(conn, "statut");

            String sql;
            if (hasDescription && hasStatut) {
                sql = "INSERT INTO matiere (nom, description, quantite, unite, statut) VALUES (?, ?, ?, ?, ?)";
            } else {
                sql = "INSERT INTO matiere (nom, quantite, unite) VALUES (?, ?, ?)";
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, matiere.getNom());
                if (hasDescription && hasStatut) {
                    ps.setString(2, matiere.getDescription());
                    ps.setInt(3, matiere.getQuantite());
                    ps.setString(4, matiere.getUnite());
                    ps.setString(5, matiere.getStatut() != null ? matiere.getStatut() : "ACTIF");
                } else {
                    ps.setInt(2, matiere.getQuantite());
                    ps.setString(3, matiere.getUnite());
                }

                int lignes = ps.executeUpdate();
                return lignes > 0;
            }
        } catch (SQLException e) {
            System.err.println("Erreur MatiereDAO.ajouter() : " + e.getMessage());
            return false;
        }
    }

    public boolean modifier(Matiere matiere) {
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasDescription = hasColumn(conn, "description");
            boolean hasStatut = hasColumn(conn, "statut");

            String sql;
            if (hasDescription && hasStatut) {
                sql = "UPDATE matiere SET nom=?, description=?, quantite=?, unite=?, statut=? WHERE id=?";
            } else {
                sql = "UPDATE matiere SET nom=?, quantite=?, unite=? WHERE id=?";
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, matiere.getNom());
                if (hasDescription && hasStatut) {
                    ps.setString(2, matiere.getDescription());
                    ps.setInt(3, matiere.getQuantite());
                    ps.setString(4, matiere.getUnite());
                    ps.setString(5, matiere.getStatut() != null ? matiere.getStatut() : "ACTIF");
                    ps.setInt(6, matiere.getId());
                } else {
                    ps.setInt(2, matiere.getQuantite());
                    ps.setString(3, matiere.getUnite());
                    ps.setInt(4, matiere.getId());
                }

                int lignes = ps.executeUpdate();
                return lignes > 0;
            }
        } catch (SQLException e) {
            System.err.println("Erreur MatiereDAO.modifier() : " + e.getMessage());
            return false;
        }
    }

    public boolean supprimer(int id) {
        String sql = "DELETE FROM matiere WHERE id = ?";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            int lignes = ps.executeUpdate();

            ps.close();
            conn.close();
            return lignes > 0;
        } catch (SQLException e) {
            System.err.println("Erreur MatiereDAO.supprimer() : " + e.getMessage());
            return false;
        }
    }
}

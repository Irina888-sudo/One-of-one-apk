package dao;

import model.Matiere;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class MatiereDAO {

    private Matiere construireMatiere(ResultSet rs) throws SQLException {
        Matiere m = new Matiere();
        m.setId(rs.getInt("id"));
        m.setNom(rs.getString("nom"));
        m.setDescription(rs.getString("description"));
        m.setQuantite(rs.getInt("quantite"));
        m.setUnite(rs.getString("unite"));
        m.setStatut(rs.getString("statut"));
        m.setCreatedAt(rs.getString("created_at"));
        return m;
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
        String sql = "SELECT * FROM matiere WHERE statut = ? ORDER BY nom ASC";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, statut);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                liste.add(construireMatiere(rs));
            }

            rs.close();
            ps.close();
            conn.close();
        } catch (SQLException e) {
            System.err.println("Erreur MatiereDAO.listerParStatut() : " + e.getMessage());
        }

        return liste;
    }

    public ArrayList<Matiere> rechercher(String texte) {
        ArrayList<Matiere> liste = new ArrayList<Matiere>();
        String sql = "SELECT * FROM matiere WHERE nom LIKE ? OR description LIKE ? ORDER BY nom ASC";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            String recherche = "%" + texte.trim() + "%";
            ps.setString(1, recherche);
            ps.setString(2, recherche);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                liste.add(construireMatiere(rs));
            }

            rs.close();
            ps.close();
            conn.close();
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
        String sql = "INSERT INTO matiere (nom, description, quantite, unite, statut) VALUES (?, ?, ?, ?, 'ACTIF')";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, matiere.getNom());
            ps.setString(2, matiere.getDescription());
            ps.setInt(3, matiere.getQuantite());
            ps.setString(4, matiere.getUnite());
            int lignes = ps.executeUpdate();

            ps.close();
            conn.close();
            return lignes > 0;
        } catch (SQLException e) {
            System.err.println("Erreur MatiereDAO.ajouter() : " + e.getMessage());
            return false;
        }
    }

    public boolean modifier(Matiere matiere) {
        String sql = "UPDATE matiere SET nom=?, description=?, quantite=?, unite=?, statut=? WHERE id=?";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, matiere.getNom());
            ps.setString(2, matiere.getDescription());
            ps.setInt(3, matiere.getQuantite());
            ps.setString(4, matiere.getUnite());
            ps.setString(5, matiere.getStatut());
            ps.setInt(6, matiere.getId());
            int lignes = ps.executeUpdate();

            ps.close();
            conn.close();
            return lignes > 0;
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

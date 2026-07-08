package dao;

import model.Utilisateur;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UtilisateurDAO {

    public Utilisateur authentifier(String email, String password) {
        String sql = "SELECT id, email, role, actif FROM utilisateur WHERE email = ? AND password = SHA2(?, 256) AND actif = TRUE";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Utilisateur utilisateur = new Utilisateur();
                    utilisateur.setId(rs.getInt("id"));
                    utilisateur.setEmail(rs.getString("email"));
                    utilisateur.setRole(rs.getString("role"));
                    utilisateur.setActif(rs.getBoolean("actif"));
                    return utilisateur;
                }
            }
        } catch (SQLException e) {
            System.err.println("Erreur UtilisateurDAO.authentifier() : " + e.getMessage());
        }

        return null;
    }
}

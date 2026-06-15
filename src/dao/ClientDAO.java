package dao;

import model.Client;
import util.DBConnection;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

/**
 * ClientDAO — Data Access Object pour la table `client`.
 *
 * Contient toutes les opérations BDD :
 *   - listerTous()          → récupérer tous les clients (tri alphabétique)
 *   - listerParStatut()     → filtrer par ACTIF ou BLOQUE
 *   - trouverParId()        → récupérer un seul client
 *   - ajouter()             → INSERT
 *   - modifier()            → UPDATE
 *   - supprimer()           → DELETE
 *
 * RÈGLE : pas de HashMap ni de List non castée → on utilise ArrayList<Client>.
 */
public class ClientDAO {

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return DriverManager.getConnection("jdbc:mysql://localhost:3306/oneofone", "root", "");
    }

    // ─────────────────────────────────────────────────────────────────────
    // Méthode privée utilitaire : convertit une ligne ResultSet → objet Client
    // Evite de dupliquer le même code dans chaque méthode
    // ─────────────────────────────────────────────────────────────────────
    private Client construireClient(ResultSet rs) throws SQLException {
        Client c = new Client();
        c.setId(rs.getInt("id"));
        c.setNom(rs.getString("nom"));
        c.setEmail(rs.getString("email"));
        c.setTelephone(rs.getString("telephone"));
        c.setAdresse(rs.getString("adresse"));
        c.setStatut(rs.getString("statut"));
        c.setMotifBlocage(rs.getString("motif_blocage"));
        c.setCreatedAt(rs.getString("created_at"));
        return c;
    }

    // ─────────────────────────────────────────────────────────────────────
    // LISTER TOUS LES CLIENTS (tri alphabétique sur le nom)
    // ─────────────────────────────────────────────────────────────────────
    public ArrayList<Client> listerTous() {
        ArrayList<Client> liste = new ArrayList<Client>();
        String sql = "SELECT * FROM client ORDER BY nom ASC";

        try {
            Connection conn = this.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                liste.add(construireClient(rs));
            }

            rs.close();
            ps.close();
            conn.close();

        } catch (SQLException e) {
            System.err.println("Erreur ClientDAO.listerTous() : " + e.getMessage());
        }

        return liste;
    }

    // ─────────────────────────────────────────────────────────────────────
    // LISTER PAR STATUT : "ACTIF" ou "BLOQUE"
    // ─────────────────────────────────────────────────────────────────────
    public ArrayList<Client> listerParStatut(String statut) {
        ArrayList<Client> liste = new ArrayList<Client>();
        String sql = "SELECT * FROM client WHERE statut = ? ORDER BY nom ASC";

        try {
            Connection conn = this.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, statut);  // évite les injections SQL
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                liste.add(construireClient(rs));
            }

            rs.close();
            ps.close();
            conn.close();

        } catch (SQLException e) {
            System.err.println("Erreur ClientDAO.listerParStatut() : " + e.getMessage());
        }

        return liste;
    }

    // ─────────────────────────────────────────────────────────────────────
    // TROUVER UN CLIENT PAR SON ID
    // Retourne null si non trouvé
    // ─────────────────────────────────────────────────────────────────────
    public Client trouverParId(int id) {
        Client client = null;
        String sql = "SELECT * FROM client WHERE id = ?";

        try {
            Connection conn = this.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                client = construireClient(rs);
            }

            rs.close();
            ps.close();
            conn.close();

        } catch (SQLException e) {
            System.err.println("Erreur ClientDAO.trouverParId() : " + e.getMessage());
        }

        return client;
    }

    // ─────────────────────────────────────────────────────────────────────
    // AJOUTER UN NOUVEAU CLIENT (INSERT)
    // Retourne true si l'insertion a réussi, false sinon
    // ─────────────────────────────────────────────────────────────────────
    public boolean ajouter(Client client) {
        String sql = "INSERT INTO client (nom, email, telephone, adresse, statut) VALUES (?, ?, ?, ?, 'ACTIF')";

        try {
            Connection conn = this.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, client.getNom());
            ps.setString(2, client.getEmail());
            ps.setString(3, client.getTelephone());
            ps.setString(4, client.getAdresse());

            int lignesAffectees = ps.executeUpdate();

            ps.close();
            conn.close();

            return lignesAffectees > 0;  // true si au moins 1 ligne insérée

        } catch (SQLException e) {
            System.err.println("Erreur ClientDAO.ajouter() : " + e.getMessage());
            return false;
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // MODIFIER UN CLIENT EXISTANT (UPDATE)
    // ─────────────────────────────────────────────────────────────────────
    public boolean modifier(Client client) {
        String sql = "UPDATE client SET nom=?, email=?, telephone=?, adresse=? WHERE id=?";

        try {
            Connection conn = this.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, client.getNom());
            ps.setString(2, client.getEmail());
            ps.setString(3, client.getTelephone());
            ps.setString(4, client.getAdresse());
            ps.setInt(5, client.getId());

            int lignesAffectees = ps.executeUpdate();

            ps.close();
            conn.close();

            return lignesAffectees > 0;

        } catch (SQLException e) {
            System.err.println("Erreur ClientDAO.modifier() : " + e.getMessage());
            return false;
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // SUPPRIMER UN CLIENT (DELETE)
    // ─────────────────────────────────────────────────────────────────────
    public boolean supprimer(int id) {
        String sql = "DELETE FROM client WHERE id = ?";

        try {
            Connection conn = this.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            int lignesAffectees = ps.executeUpdate();

            ps.close();
            conn.close();

            return lignesAffectees > 0;

        } catch (SQLException e) {
            System.err.println("Erreur ClientDAO.supprimer() : " + e.getMessage());
            return false;
        }
    }
}

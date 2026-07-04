package dao;

import model.Commande;
import model.LigneCommande;
import model.Client;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommandeDAO {

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return DriverManager.getConnection("jdbc:mysql://localhost:3306/oneofone", "root", "");
    }

    private Commande mapVue(ResultSet rs) throws SQLException {
        Commande c = new Commande();
        c.setId(rs.getInt("id"));
        c.setNumero(rs.getString("numero"));
        c.setClientNom(rs.getString("client_nom"));
        c.setClientEmail(rs.getString("client_email"));
        c.setMontantTotal(rs.getDouble("montant_total"));
        c.setDateCommande(rs.getTimestamp("date_commande"));
        c.setStatut(rs.getString("statut"));
        c.setProduits(rs.getString("produits"));
        return c;
    }

    public List<Commande> lister(String recherche, String statut, String clientId) throws SQLException {
        List<Commande> liste = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT c.id, c.numero, cl.nom AS client_nom, cl.email AS client_email, c.montant_total, c.date_commande, c.statut, " +
            "(SELECT GROUP_CONCAT(CONCAT(p.nom, ' (x', lc.quantite, ')') SEPARATOR ', ') " +
            " FROM ligne_commande lc " +
            " JOIN produit p ON lc.produit_id = p.id " +
            " WHERE lc.commande_id = c.id) AS produits " +
            "FROM commande c " +
            "JOIN client cl ON c.client_id = cl.id " +
            "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (recherche != null && !recherche.trim().isEmpty()) {
            sql.append("AND (c.numero LIKE ? OR cl.nom LIKE ? OR cl.email LIKE ?) ");
            String term = "%" + recherche.trim() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }

        if (statut != null && !statut.trim().isEmpty()) {
            sql.append("AND c.statut = ? ");
            params.add(statut);
        }

        if (clientId != null && !clientId.trim().isEmpty()) {
            sql.append("AND c.client_id = ? ");
            params.add(Integer.parseInt(clientId));
        }

        sql.append("ORDER BY c.date_commande DESC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    liste.add(mapVue(rs));
                }
            }
        }
        return liste;
    }

    public Commande trouverParId(int id) throws SQLException {
        String sql = "SELECT c.id, c.numero, c.client_id, c.statut, c.montant_total, c.date_commande, " +
                     "cl.nom AS client_nom, cl.email AS client_email " +
                     "FROM commande c " +
                     "JOIN client cl ON c.client_id = cl.id " +
                     "WHERE c.id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Commande c = new Commande();
                    c.setId(rs.getInt("id"));
                    c.setNumero(rs.getString("numero"));
                    c.setClientId(rs.getInt("client_id"));
                    c.setClientNom(rs.getString("client_nom"));
                    c.setClientEmail(rs.getString("client_email"));
                    c.setStatut(rs.getString("statut"));
                    c.setMontantTotal(rs.getDouble("montant_total"));
                    c.setDateCommande(rs.getTimestamp("date_commande"));
                    c.setLignes(trouverLignes(conn, id));
                    return c;
                }
            }
        }
        return null;
    }

    private List<LigneCommande> trouverLignes(Connection conn, int commandeId) throws SQLException {
        List<LigneCommande> lignes = new ArrayList<>();
        String sql = "SELECT lc.id, lc.commande_id, lc.produit_id, p.nom AS produit_nom, lc.quantite, lc.prix_unitaire " +
                     "FROM ligne_commande lc " +
                     "JOIN produit p ON lc.produit_id = p.id " +
                     "WHERE lc.commande_id = ? " +
                     "ORDER BY lc.id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commandeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LigneCommande ligne = new LigneCommande();
                    ligne.setId(rs.getInt("id"));
                    ligne.setCommandeId(rs.getInt("commande_id"));
                    ligne.setProduitId(rs.getInt("produit_id"));
                    ligne.setProduitNom(rs.getString("produit_nom"));
                    ligne.setQuantite(rs.getInt("quantite"));
                    ligne.setPrixUnitaire(rs.getDouble("prix_unitaire"));
                    lignes.add(ligne);
                }
            }
        }
        return lignes;
    }

    public List<Client> getClients() throws SQLException {
        List<Client> clients = new ArrayList<>();
        String sql = "SELECT id, nom, email, telephone, adresse FROM client ORDER BY nom ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Client client = new Client();
                client.setId(rs.getInt("id"));
                client.setNom(rs.getString("nom"));
                client.setEmail(rs.getString("email"));
                client.setTelephone(rs.getString("telephone"));
                client.setAdresse(rs.getString("adresse"));
                clients.add(client);
            }
        }
        return clients;
    }

    public void ajouter(Commande commande) throws SQLException {
        if (commande.getLignes() == null || commande.getLignes().isEmpty()) {
            throw new SQLException("La commande doit contenir au moins une ligne de produit.");
        }

        String insertCommande = "INSERT INTO commande (numero, client_id, statut, montant_total, date_commande) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(insertCommande, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, commande.getNumero());
                ps.setInt(2, commande.getClientId());
                ps.setString(3, commande.getStatut() != null ? commande.getStatut() : "ATTENTE");
                double total = commande.calculerMontantTotal();
                ps.setDouble(4, total);
                ps.setTimestamp(5, commande.getDateCommande());
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        commande.setId(keys.getInt(1));
                    }
                }
            }
            insererLignes(conn, commande);
            conn.commit();
        }
    }

    public void modifier(Commande commande) throws SQLException {
        if (commande.getLignes() == null || commande.getLignes().isEmpty()) {
            throw new SQLException("La commande doit contenir au moins une ligne de produit.");
        }

        String updateCommande = "UPDATE commande SET numero = ?, client_id = ?, statut = ?, montant_total = ?, date_commande = ? WHERE id = ?";
        String deleteLignes = "DELETE FROM ligne_commande WHERE commande_id = ?";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(updateCommande)) {
                ps.setString(1, commande.getNumero());
                ps.setInt(2, commande.getClientId());
                ps.setString(3, commande.getStatut() != null ? commande.getStatut() : "ATTENTE");
                double total = commande.calculerMontantTotal();
                ps.setDouble(4, total);
                ps.setTimestamp(5, commande.getDateCommande());
                ps.setInt(6, commande.getId());
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(deleteLignes)) {
                ps.setInt(1, commande.getId());
                ps.executeUpdate();
            }
            insererLignes(conn, commande);
            conn.commit();
        }
    }

    public void supprimer(int id) throws SQLException {
        String deleteLignes = "DELETE FROM ligne_commande WHERE commande_id = ?";
        String deleteCommande = "DELETE FROM commande WHERE id = ?";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(deleteLignes)) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(deleteCommande)) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }
            conn.commit();
        }
    }

    private void insererLignes(Connection conn, Commande commande) throws SQLException {
        String insertLigne = "INSERT INTO ligne_commande (commande_id, produit_id, quantite, prix_unitaire) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertLigne)) {
            for (LigneCommande ligne : commande.getLignes()) {
                ps.setInt(1, commande.getId());
                ps.setInt(2, ligne.getProduitId());
                ps.setInt(3, ligne.getQuantite());
                ps.setDouble(4, ligne.getPrixUnitaire());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }
}

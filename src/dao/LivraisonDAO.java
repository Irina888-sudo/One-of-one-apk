package dao;

import model.Livraison;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LivraisonDAO {

    public List<Livraison> getAllLivraisons() {

        List<Livraison> list = new ArrayList<>();

        String sql = "SELECT * FROM livraison";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Livraison l = new Livraison();

                l.setId(rs.getInt("id"));
                l.setNumero(rs.getString("numero"));
                l.setCommandeId(rs.getInt("commande_id"));

                //employe_id peut être NULL
                int empId = rs.getInt("employe_id");
                if (rs.wasNull()) {
                    l.setEmployeId(null);
                } else {
                    l.setEmployeId(empId);
                }

                l.setLivreur(rs.getString("livreur"));
                l.setLieu(rs.getString("lieu"));
                l.setFrais(rs.getDouble("frais"));
                l.setStatut(rs.getString("statut"));
                l.setDateLivraison(rs.getDate("date_livraison"));

                list.add(l);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    public List<String> getAllLieux() {

    List<String> lieux = new ArrayList<>();

    try {
        Connection conn = DBConnection.getConnection();

        String sql = "SELECT DISTINCT lieu FROM livraison WHERE lieu IS NOT NULL";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            lieux.add(rs.getString("lieu"));
        }

        conn.close();

    } catch (Exception e) {
        e.printStackTrace();
    }

    return lieux;
}
    public List<String> getAllLivreurs() {

    List<String> livreurs = new ArrayList<>();

    try {
        Connection conn = DBConnection.getConnection();

        String sql = "SELECT DISTINCT livreur " +
                     "FROM livraison " +
                     "WHERE livreur IS NOT NULL " +
                     "ORDER BY livreur";

        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            livreurs.add(rs.getString("livreur"));
        }

        rs.close();
        ps.close();
        conn.close();

    } catch (Exception e) {
        e.printStackTrace();
    }

    return livreurs;
}
public Livraison getById(int id) {

    Livraison l = null;

    try {
        Connection conn = DBConnection.getConnection();

        String sql = "SELECT * FROM livraison WHERE id = ?";

        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setInt(1, id);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {

            l = new Livraison();

            l.setId(rs.getInt("id"));
            l.setNumero(rs.getString("numero"));
            l.setCommandeId(rs.getInt("commande_id"));
            l.setEmployeId(rs.getInt("employe_id"));
            l.setLivreur(rs.getString("livreur"));
            l.setLieu(rs.getString("lieu"));
            l.setFrais(rs.getDouble("frais"));
            l.setStatut(rs.getString("statut"));
            l.setDateLivraison(rs.getDate("date_livraison"));
        }

        rs.close();
        ps.close();
        conn.close();

    } catch (Exception e) {
        e.printStackTrace();
    }

    return l;
}
public void insert(Livraison l) {

    try {
        Connection conn = DBConnection.getConnection();

        String numero = l.getNumero();
        if (numero == null || numero.trim().isEmpty()) {
            numero = "LIV-" + System.currentTimeMillis();
        }

        String statut = l.getStatut();
        if (statut == null || statut.trim().isEmpty()) {
            statut = "ATTENTE";
        } else if ("LIVRE".equalsIgnoreCase(statut)) {
            statut = "LIVREE";
        }

        String sql = "INSERT INTO livraison (numero, commande_id, employe_id, livreur, lieu, frais, statut, date_livraison) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_DATE)";

        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, numero);
        ps.setInt(2, l.getCommandeId());

        if (l.getEmployeId() == null) {
            ps.setNull(3, java.sql.Types.INTEGER);
        } else {
            ps.setInt(3, l.getEmployeId());
        }

        ps.setString(4, l.getLivreur());
        ps.setString(5, l.getLieu());
        ps.setDouble(6, l.getFrais());
        ps.setString(7, statut);

        ps.executeUpdate();

        ps.close();
        conn.close();

    } catch (Exception e) {
        e.printStackTrace();
    }
}
public void update(Livraison l) {

    try {
        Connection conn = DBConnection.getConnection();

        String statut = l.getStatut();
        if (statut == null || statut.trim().isEmpty()) {
            statut = "ATTENTE";
        } else if ("LIVRE".equalsIgnoreCase(statut)) {
            statut = "LIVREE";
        }

        String sql = "UPDATE livraison SET " +
                     "numero = ?, " +
                     "commande_id = ?, " +
                     "employe_id = ?, " +
                     "livreur = ?, " +
                     "lieu = ?, " +
                     "frais = ?, " +
                     "statut = ?, " +
                     "date_livraison = ? " +
                     "WHERE id = ?";

        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, l.getNumero() != null ? l.getNumero() : "LIV-" + System.currentTimeMillis());
        ps.setInt(2, l.getCommandeId());

        if (l.getEmployeId() == null) {
            ps.setNull(3, java.sql.Types.INTEGER);
        } else {
            ps.setInt(3, l.getEmployeId());
        }

        ps.setString(4, l.getLivreur());
        ps.setString(5, l.getLieu());
        ps.setDouble(6, l.getFrais());
        ps.setString(7, statut);
        ps.setDate(8, l.getDateLivraison());

        ps.setInt(9, l.getId());

        ps.executeUpdate();

        ps.close();
        conn.close();

    } catch (Exception e) {
        e.printStackTrace();
    }
}
public void delete(int id) {

    try {
        CorbeilleDAO corbeilleDAO = new CorbeilleDAO();
        corbeilleDAO.archiverLivraison(id);
    } catch (Exception e) {
        e.printStackTrace();
    }
}
}

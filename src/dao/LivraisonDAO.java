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

                // ⚠️ employe_id peut être NULL
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
                l.setDateLivraison(String.valueOf(rs.getDate("date_livraison")));

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
}

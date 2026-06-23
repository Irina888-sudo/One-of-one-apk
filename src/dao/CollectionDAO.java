package dao;

import model.Collection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CollectionDAO {

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return DriverManager.getConnection("jdbc:mysql://localhost:3306/oneofone", "root", "");
    }

    public List<Collection> listerActives() throws SQLException {
        List<Collection> liste = new ArrayList<>();
        String sql = "SELECT id, nom FROM collection WHERE statut = 'ACTIVE' ORDER BY nom";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Collection c = new Collection();
                c.setId(rs.getInt("id"));
                c.setNom(rs.getString("nom"));
                liste.add(c);
            }
        }
        return liste;
    }
}

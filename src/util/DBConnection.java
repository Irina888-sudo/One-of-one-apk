package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    static {
        try {
            // Pour MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("Driver MySQL chargé avec succès !");
        } catch (ClassNotFoundException e) {
            System.err.println("ERREUR: Driver MySQL non trouvé !");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        String url = "jdbc:mysql://localhost:3306/oneofone?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
        String user = "root";
        String password = "";
        
        return DriverManager.getConnection(url, user, password);
    }

    public static void main(String[] args) {
        try {
            Connection conn = getConnection();
            System.out.println("Connexion réussie !");
            conn.close();
        } catch (Exception e) {
            System.out.println("Erreur de connexion !");
            e.printStackTrace();
        }
    }
}
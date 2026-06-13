package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    public static void main(String[] args) {

        String url = "jdbc:mysql://localhost:3306/oneofone";
        String user = "root";
        String password = "";

        try {

            Connection conn = DriverManager.getConnection(
                    url,
                    user,
                    password);

            System.out.println("Connexion réussie !");
            conn.close();

        } catch (Exception e) {
            System.out.println("Erreur de connexion !");
            e.printStackTrace();
        }
    }
}

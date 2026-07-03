package util;
import java.sql.*;
public class DBConnectionRajo{
    private static final String URL      = "jdbc:mysql://localhost:3306/oneofone?useSSL=false&serverTimezone=UTC";
    private static final String USER     = "root";
    private static final String PASSWORD = "";
    public static Connection getConnection() throws SQLException {
        try { Class.forName("com.mysql.cj.jdbc.Driver"); } catch (ClassNotFoundException e) { throw new SQLException(e.getMessage()); }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}

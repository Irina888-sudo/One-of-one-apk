package dao;

import model.Employe;
import util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmployeDAO {
    

    public boolean addEmploye(Employe employe) {
        String sql = "INSERT INTO employe (utilisateur_id, nom, email, telephone, role, salaire_brut, statut, date_embauche) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            
            pstmt.setObject(1, employe.getUtilisateurId());
            pstmt.setString(2, employe.getNom());
            pstmt.setString(3, employe.getEmail());
            pstmt.setString(4, employe.getTelephone());
            pstmt.setString(5, employe.getRole());
            pstmt.setBigDecimal(6, employe.getSalaireBrut());
            pstmt.setString(7, employe.getStatut());
            pstmt.setDate(8, employe.getDateEmbauche());
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    employe.setId(rs.getInt(1));
                }
                return true;
            }
            return false;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    // recuperer employes et filtre 
public List<Employe> getAllEmployes(String statut, String role, String dateDebut, String dateFin, 
                                     String search, String sortBy, String sortOrder, 
                                     int offset, int recordsPerPage) {
    List<Employe> employes = new ArrayList<>();
    StringBuilder sql = new StringBuilder("SELECT * FROM employe WHERE 1=1");
    List<Object> params = new ArrayList<>();
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    // filtres
    if (statut != null && !statut.isEmpty() && !statut.equals("TOUS")) {
        sql.append(" AND statut = ?");
        params.add(statut);
    }
    
    if (role != null && !role.isEmpty() && !role.equals("TOUS")) {
        sql.append(" AND role = ?");
        params.add(role);
    }
    
    if (dateDebut != null && !dateDebut.isEmpty()) {
        sql.append(" AND date_embauche >= ?");
        params.add(Date.valueOf(dateDebut));
    }
    
    if (dateFin != null && !dateFin.isEmpty()) {
        sql.append(" AND date_embauche <= ?");
        params.add(Date.valueOf(dateFin));
    }
    
    if (search != null && !search.isEmpty()) {
        sql.append(" AND (nom LIKE ? OR email LIKE ?)");
        params.add("%" + search + "%");
        params.add("%" + search + "%");
    }
    
    // Tri dynamique
    String orderBy = "id"; // par défaut
    String order = "ASC"; // par défaut
    
    if (sortBy != null && !sortBy.isEmpty()) {
        switch(sortBy) {
            case "id":
                orderBy = "id";
                break;
            case "nom":
                orderBy = "nom";
                break;
            case "date":
                orderBy = "date_embauche";
                break;
            default:
                orderBy = "id";
        }
    }
    
    if (sortOrder != null && !sortOrder.isEmpty()) {
        order = sortOrder.equals("DESC") ? "DESC" : "ASC";
    }
    
    sql.append(" ORDER BY ").append(orderBy).append(" ").append(order);
    sql.append(" LIMIT ? OFFSET ?");
    
    try {
        conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement(sql.toString());
        
        int index = 1;
        for (Object param : params) {
            if (param instanceof String) {
                pstmt.setString(index++, (String) param);
            } else if (param instanceof Date) {
                pstmt.setDate(index++, (Date) param);
            }
        }
        
        pstmt.setInt(index++, recordsPerPage);
        pstmt.setInt(index, offset);
        
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            employes.add(extractEmployeFromResultSet(rs));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    return employes;
}


public List<Employe> getAllEmployes(String statut, String role, String dateDebut, String dateFin, 
                                     String search, int offset, int recordsPerPage) {
    return getAllEmployes(statut, role, dateDebut, dateFin, search, "id", "ASC", offset, recordsPerPage);
}

    public int getTotalEmployes(String statut, String role, String dateDebut, String dateFin, String search) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM employe WHERE 1=1");
        List<Object> params = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        if (statut != null && !statut.isEmpty() && !statut.equals("TOUS")) {
            sql.append(" AND statut = ?");
            params.add(statut);
        }
        
        if (role != null && !role.isEmpty() && !role.equals("TOUS")) {
            sql.append(" AND role = ?");
            params.add(role);
        }
        
        if (dateDebut != null && !dateDebut.isEmpty()) {
            sql.append(" AND date_embauche >= ?");
            params.add(Date.valueOf(dateDebut));
        }
        
        if (dateFin != null && !dateFin.isEmpty()) {
            sql.append(" AND date_embauche <= ?");
            params.add(Date.valueOf(dateFin));
        }
        
        if (search != null && !search.isEmpty()) {
            sql.append(" AND (nom LIKE ? OR email LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            
            int index = 1;
            for (Object param : params) {
                if (param instanceof String) {
                    pstmt.setString(index++, (String) param);
                } else if (param instanceof Date) {
                    pstmt.setDate(index++, (Date) param);
                }
            }
            
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return 0;
    }
    

    public Employe getEmployeById(int id) {
        String sql = "SELECT * FROM employe WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return extractEmployeFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return null;
    }
    
    public boolean updateEmploye(Employe employe) {
        String sql = "UPDATE employe SET utilisateur_id=?, nom=?, email=?, telephone=?, role=?, salaire_brut=?, statut=?, date_embauche=? WHERE id=?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setObject(1, employe.getUtilisateurId());
            pstmt.setString(2, employe.getNom());
            pstmt.setString(3, employe.getEmail());
            pstmt.setString(4, employe.getTelephone());
            pstmt.setString(5, employe.getRole());
            pstmt.setBigDecimal(6, employe.getSalaireBrut());
            pstmt.setString(7, employe.getStatut());
            pstmt.setDate(8, employe.getDateEmbauche());
            pstmt.setInt(9, employe.getId());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    public boolean deleteEmployeLogique(int id) {
        String sql = "UPDATE employe SET statut = 'INACTIF' WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    public boolean isEmailExists(String email, int excludeId) {
        String sql = "SELECT COUNT(*) FROM employe WHERE email = ? AND id != ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            pstmt.setInt(2, excludeId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return false;
    }
    
    public List<String> getAllRoles() {
        List<String> roles = new ArrayList<>();
        roles.add("TOUS");
        String sql = "SELECT DISTINCT role FROM employe WHERE role IS NOT NULL ORDER BY role";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            
            while (rs.next()) {
                roles.add(rs.getString("role"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return roles;
    }
    
    private Employe extractEmployeFromResultSet(ResultSet rs) throws SQLException {
        Employe employe = new Employe();
        employe.setId(rs.getInt("id"));
        int utilisateurId = rs.getInt("utilisateur_id");
        employe.setUtilisateurId(rs.wasNull() ? null : utilisateurId);
        employe.setNom(rs.getString("nom"));
        employe.setEmail(rs.getString("email"));
        employe.setTelephone(rs.getString("telephone"));
        employe.setRole(rs.getString("role"));
        employe.setSalaireBrut(rs.getBigDecimal("salaire_brut"));
        employe.setStatut(rs.getString("statut"));
        employe.setDateEmbauche(rs.getDate("date_embauche"));
        return employe;
    }
}
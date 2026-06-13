package dao;

import model.Salaire;
import model.Employe;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SalaireDAO {
    private final Connection connection;
    public SalaireDAO(Connection connection) { this.connection = connection; }

    // Convenience no-arg constructor for JSPs that instantiate DAO directly
    public SalaireDAO() { this.connection = null; }

    public Salaire findById(int id) throws SQLException { throw new UnsupportedOperationException("Not implemented yet"); }
    public boolean delete(int id) throws SQLException { throw new UnsupportedOperationException("Not implemented yet"); }

    public boolean updateStatut(int salaireId, String statut) throws SQLException {
        String sql = "UPDATE salaire SET statut = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, statut);
            pstmt.setInt(2, salaireId);
            return pstmt.executeUpdate() > 0;
        }
    }

    public List<Salaire> findAll() throws SQLException {
        List<Salaire> result = new ArrayList<>();
        String sql = "SELECT * FROM salaire ORDER BY mois DESC, id DESC";

        // If a connection was supplied in constructor, use it; otherwise open a new one
        boolean externalConn = this.connection != null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = externalConn ? this.connection : DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Salaire s = new Salaire();
                s.setId(rs.getInt("id"));
                s.setEmployeId(rs.getInt("employe_id"));
                java.sql.Date moisDate = rs.getDate("mois");
                if (moisDate != null) s.setMois(moisDate.toLocalDate());
                s.setSalaireBrut(rs.getBigDecimal("salaire_brut"));
                s.setStatut(rs.getString("statut"));
                try { s.setSalaireNet(rs.getBigDecimal("salaire_net")); } catch (Exception ignored) {}
                try { s.setJoursConges(rs.getInt("jours_conges")); } catch (Exception ignored) {}
                result.add(s);
            }
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            if (!externalConn) {
                try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
            }
        }

        return result;
    }

    public List<Salaire> getAllSalaires() throws SQLException {
        return findAll();
    }

    public Salaire findByEmployeAndMonth(int employeId, java.time.LocalDate month) throws SQLException {
        String sql = "SELECT * FROM salaire WHERE employe_id = ? AND YEAR(mois) = ? AND MONTH(mois) = ? LIMIT 1";
        boolean externalConn = this.connection != null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = externalConn ? this.connection : DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, employeId);
            pstmt.setInt(2, month.getYear());
            pstmt.setInt(3, month.getMonthValue());
            rs = pstmt.executeQuery();
            if (rs.next()) {
                Salaire s = new Salaire();
                s.setId(rs.getInt("id"));
                s.setEmployeId(rs.getInt("employe_id"));
                java.sql.Date moisDate = rs.getDate("mois");
                if (moisDate != null) s.setMois(moisDate.toLocalDate());
                s.setSalaireBrut(rs.getBigDecimal("salaire_brut"));
                s.setStatut(rs.getString("statut"));
                try { s.setSalaireNet(rs.getBigDecimal("salaire_net")); } catch (Exception ignored) {}
                try { s.setJoursConges(rs.getInt("jours_conges")); } catch (Exception ignored) {}
                return s;
            }
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
            if (!externalConn) {
                try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
            }
        }
        return null;
    }

    public Salaire create(Salaire s) throws SQLException {
        String sql = "INSERT INTO salaire (employe_id, mois, salaire_brut, salaire_net, jours_conges, statut) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            pstmt.setInt(1, s.getEmployeId());
            pstmt.setDate(2, java.sql.Date.valueOf(s.getMois()));
            pstmt.setBigDecimal(3, s.getSalaireBrut());
            // If salaire_net is not provided, default it to salaire_brut
            java.math.BigDecimal salaireNetToSet = s.getSalaireNet() != null ? s.getSalaireNet() : (s.getSalaireBrut() != null ? s.getSalaireBrut() : java.math.BigDecimal.ZERO);
            if (salaireNetToSet != null) pstmt.setBigDecimal(4, salaireNetToSet); else pstmt.setNull(4, java.sql.Types.DECIMAL);
            if (s.getJoursConges() != null) pstmt.setInt(5, s.getJoursConges()); else pstmt.setInt(5, 0);
            pstmt.setString(6, s.getStatut());
            int affected = pstmt.executeUpdate();
            if (affected > 0) {
                ResultSet keys = pstmt.getGeneratedKeys();
                if (keys.next()) s.setId(keys.getInt(1));
                return s;
            }
        }
        return null;
    }

    public boolean update(Salaire s) throws SQLException {
        String sql = "UPDATE salaire SET salaire_brut = ?, salaire_net = ?, jours_conges = ?, statut = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setBigDecimal(1, s.getSalaireBrut());
            if (s.getSalaireNet() != null) pstmt.setBigDecimal(2, s.getSalaireNet()); else pstmt.setNull(2, java.sql.Types.DECIMAL);
            pstmt.setInt(3, s.getJoursConges() != null ? s.getJoursConges() : 0);
            pstmt.setString(4, s.getStatut());
            pstmt.setInt(5, s.getId());
            return pstmt.executeUpdate() > 0;
        }
    }

    public void applyLeaveToSalary(int employeId, java.time.LocalDate month, int additionalJoursConges, boolean isPaid) throws SQLException {
        // If paid leave, no impact
        if (isPaid) return;

        Salaire s = findByEmployeAndMonth(employeId, month);
        // get employe salaire_brut if needed
        model.Employe e = null;
        try { e = new dao.EmployeDAO().getEmployeById(employeId); } catch (Exception ignored) {}
        java.math.BigDecimal salaireBrut = s != null && s.getSalaireBrut() != null ? s.getSalaireBrut() : (e != null ? e.getSalaireBrut() : java.math.BigDecimal.ZERO);

        int existingJours = s != null && s.getJoursConges() != null ? s.getJoursConges() : 0;
        int totalJours = existingJours + additionalJoursConges;

        // 22 working days per month
        java.math.BigDecimal deduction = java.math.BigDecimal.ZERO;
        if (salaireBrut != null) {
            java.math.BigDecimal jours = new java.math.BigDecimal(totalJours);
            java.math.BigDecimal factor = jours.divide(new java.math.BigDecimal(22), 6, java.math.RoundingMode.HALF_UP);
            deduction = salaireBrut.multiply(factor).setScale(2, java.math.RoundingMode.HALF_UP);
        }

        java.math.BigDecimal salaireNet = salaireBrut.subtract(deduction).setScale(2, java.math.RoundingMode.HALF_UP);

        if (s == null) {
            Salaire newS = new Salaire();
            newS.setEmployeId(employeId);
            newS.setMois(month);
            newS.setSalaireBrut(salaireBrut);
            newS.setJoursConges(totalJours);
            newS.setSalaireNet(salaireNet);
            newS.setStatut("ATTENTE");
            create(newS);
        } else {
            s.setJoursConges(totalJours);
            s.setSalaireNet(salaireNet);
            s.setSalaireBrut(salaireBrut);
            update(s);
        }
    }

    
     
    public void updateSalaryForMonthWithTotalLeave(int employeId, java.time.LocalDate month, int totalJours, boolean isPaid) throws SQLException {
        if (isPaid) return;

        Salaire s = findByEmployeAndMonth(employeId, month);
        model.Employe e = null;
        try { e = new dao.EmployeDAO().getEmployeById(employeId); } catch (Exception ignored) {}
        java.math.BigDecimal salaireBrut = s != null && s.getSalaireBrut() != null ? s.getSalaireBrut() : (e != null ? e.getSalaireBrut() : java.math.BigDecimal.ZERO);

        java.math.BigDecimal deduction = java.math.BigDecimal.ZERO;
        if (salaireBrut != null) {
            java.math.BigDecimal jours = new java.math.BigDecimal(totalJours);
            java.math.BigDecimal factor = jours.divide(new java.math.BigDecimal(22), 6, java.math.RoundingMode.HALF_UP);
            deduction = salaireBrut.multiply(factor).setScale(2, java.math.RoundingMode.HALF_UP);
        }

        java.math.BigDecimal salaireNet = salaireBrut.subtract(deduction).setScale(2, java.math.RoundingMode.HALF_UP);

        if (s == null) {
            Salaire newS = new Salaire();
            newS.setEmployeId(employeId);
            newS.setMois(month);
            newS.setSalaireBrut(salaireBrut);
            newS.setJoursConges(totalJours);
            newS.setSalaireNet(salaireNet);
            newS.setStatut("ATTENTE");
            create(newS);
        } else {
            s.setJoursConges(totalJours);
            s.setSalaireNet(salaireNet);
            s.setSalaireBrut(salaireBrut);
            update(s);
        }
    }
}

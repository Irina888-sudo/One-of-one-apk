package dao;

import model.Conge;
import util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;


public class CongeDAO {
    public boolean addConge(Conge conge) throws SQLException {
        // The DB schema defines `nb_jours` as a GENERATED column (DATEDIFF + 1). Do not write to it.
        // Use INSERT matching existing schema: (employe_id, date_debut, date_fin, motif, statut)
        String sql = "INSERT INTO conge (employe_id, date_debut, date_fin, motif, statut) VALUES (?, ?, ?, ?, ?)";
        Connection conn = DBConnection.getConnection();
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, conge.getEmployeId());
            pstmt.setDate(2, conge.getDateDebut());
            pstmt.setDate(3, conge.getDateFin());
            pstmt.setString(4, conge.getMotif());
            pstmt.setString(5, conge.getStatut());
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        }
    }

    public List<Conge> getCongesByEmployeId(int employeId) {
        List<Conge> conges = new ArrayList<>();
        String sql = "SELECT * FROM conge WHERE employe_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, employeId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Conge conge = new Conge();
                conge.setId(rs.getInt("id"));
                conge.setEmployeId(rs.getInt("employe_id"));
                conge.setDateDebut(rs.getDate("date_debut"));
                conge.setDateFin(rs.getDate("date_fin"));
                // DB column is `nb_jours` (generated) in the provided schema
                conge.setNbrJours(rs.getInt("nb_jours"));
                conge.setMotif(rs.getString("motif"));
                // type_conge may not exist in older schema; try-catch avoids failure
                try { conge.setTypeConge(rs.getString("type_conge")); } catch (SQLException ignored) {}
                conge.setStatut(rs.getString("statut"));
                conges.add(conge);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return conges;
    }

    public boolean updateConge(Conge conge) throws SQLException {
        // nb_jours is GENERATED; do not update it. Keep update to mutable columns only.
        String sql = "UPDATE conge SET date_debut = ?, date_fin = ?, motif = ?, statut = ? WHERE id = ?";
        Connection conn = DBConnection.getConnection();
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setDate(1, conge.getDateDebut());
            pstmt.setDate(2, conge.getDateFin());
            pstmt.setString(3, conge.getMotif());
            pstmt.setString(4, conge.getStatut());
            pstmt.setInt(5, conge.getId());
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        }
    }

    public Conge getCongeById(int id) {
        String sql = "SELECT * FROM conge WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                Conge conge = new Conge();
                conge.setId(rs.getInt("id"));
                conge.setEmployeId(rs.getInt("employe_id"));
                conge.setDateDebut(rs.getDate("date_debut"));
                conge.setDateFin(rs.getDate("date_fin"));
                conge.setNbrJours(rs.getInt("nb_jours"));
                conge.setMotif(rs.getString("motif"));
                try { conge.setTypeConge(rs.getString("type_conge")); } catch (SQLException ignored) {}
                conge.setStatut(rs.getString("statut"));
                return conge;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
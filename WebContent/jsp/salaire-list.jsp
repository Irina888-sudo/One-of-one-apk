<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal, model.Salaire, dao.SalaireDAO, dao.EmployeDAO, util.DBConnection" %>
<%@ page import="java.sql.Date, java.sql.Connection" %>
<%@ page import="java.time.LocalDate" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Salaires - OneOfOne</title>
    <link rel="stylesheet" href="../css/salaire.css">
</head>
<body>
<div class="container">
    <h1>Liste des Salaires</h1>
    
    <% 
        List<Salaire> salaires = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            SalaireDAO salaireDAO = new SalaireDAO(conn);
            try {
                salaires = salaireDAO.getAllSalaires();
            } catch (Exception e) {
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    %>
    
    <table>
        <thead>
            <tr>
            
                <th>Nom Employé</th>
                <th>Role</th>
                <th>Mois</th>
                <th>Salaire Brut</th>
                <th>Salaire Net</th>
                <th>Actions</th>
                <th>Statut</th>
                <th>Conge</th>
            </tr>
        </thead>
        <tbody>
            <% if (salaires == null || salaires.isEmpty()) { %>
                <tr class="empty-row">
                    <td colspan="8" style="text-align:center; padding:40px;">Aucun salaire trouvé.</td>
                </tr>
            <% } else {
                   for (Salaire salaire : salaires) {
            %>
            <tr>
                <td><%= (salaire.getEmployeId() != null ? (EmployeDAO.getNomEmployeById(salaire.getEmployeId()) != null ? EmployeDAO.getNomEmployeById(salaire.getEmployeId()) : "-") : "-") %></td>
                <td><%= (salaire.getEmployeId() != null ? (EmployeDAO.getRoleById(salaire.getEmployeId()) != null ? EmployeDAO.getRoleById(salaire.getEmployeId()) : "-") : "-") %></td>
                <td><%= (salaire.getMois() != null ? Salaire.formatMois(salaire.getMois()) : "-") %></td>
                <td><%= (salaire.getSalaireBrut() != null ? String.format("%,.2f", salaire.getSalaireBrut()) + " €" : "-") %></td>
                <td><%= (salaire.getSalaireNet() != null ? String.format("%,.2f", salaire.getSalaireNet()) + " €" : "-" ) %></td>
                <td>
                    <a href="salaire-form.jsp?id=<%= salaire.getId() %>" class="btn">Modifier</a>
                </td>
                <td>
                    <%= salaire.getStatut() != null ? salaire.getStatut() : "-" %>
                    <br/>
                    <a href="salaire-status.jsp?id=<%= salaire.getId() %>&statut=PAYE" class="btn" style="margin-top:6px; display:inline-block;">Marquer PAYE</a>
                    <a href="salaire-status.jsp?id=<%= salaire.getId() %>&statut=ATTENTE" class="btn" style="margin-top:6px; display:inline-block;">Marquer ATTENTE</a>
                </td>
                <td>
                    <a href="conge-form.jsp?id=<%= salaire.getEmployeId() %>" class="btn">Demander un Congé</a>
                    <br/>
                    <%-- show conge dates for same month --%>
                    <%
                        try {
                            java.time.LocalDate mois = salaire.getMois() != null ? salaire.getMois() : java.time.LocalDate.now().withDayOfMonth(1);
                            java.util.List<model.Conge> conges = new dao.CongeDAO().getCongesByEmployeId(salaire.getEmployeId());
                            StringBuilder sb = new StringBuilder();
                            for (model.Conge c : conges) {
                                if (c.getDateDebut() != null) {
                                    java.time.LocalDate ddeb = c.getDateDebut().toLocalDate();
                                    java.time.LocalDate dfin = c.getDateFin() != null ? c.getDateFin().toLocalDate() : ddeb;
                                    if (ddeb.getYear() == mois.getYear() && ddeb.getMonthValue() == mois.getMonthValue()) {
                                        if (sb.length() > 0) sb.append("; ");
                                        sb.append(ddeb.toString()).append(" → ").append(dfin.toString());
                                    }
                                }
                            }
                            String congeDates = sb.length() > 0 ? sb.toString() : "-";
                    %>
                    <div style="font-size:0.9em; margin-top:6px;">Congés: <%= congeDates %></div>
                    <% } catch (Exception ignored) { %>
                        <div style="font-size:0.9em; margin-top:6px;">Congés: -</div>
                    <% } %>
                </td>
            </tr>
            <%   }
               }
            %>
        </tbody>
    </table>
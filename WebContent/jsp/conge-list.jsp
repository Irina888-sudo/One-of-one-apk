<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, dao.CongeDAO, model.Conge, dao.EmployeDAO" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liste des Congés - OneOfOne</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<div class="container">
    <h1>Liste des Congés</h1>
    <div class="nav-links">
        <a href="employe-list.jsp">Retour à la liste des employés</a>
    </div>

    <%
        List<Conge> conges = new ArrayList<>();
        try {
            // get all employees (max 1000) then gather conges per employe
            java.util.List<model.Employe> employes = new dao.EmployeDAO().getAllEmployes(null, null, null, null, null, 0, 1000);
            if (employes != null) {
                for (model.Employe emp : employes) {
                    try {
                        List<Conge> c = new CongeDAO().getCongesByEmployeId(emp.getId());
                        if (c != null && !c.isEmpty()) conges.addAll(c);
                    } catch (Exception ignored) {}
                }
            }
        } catch (Exception ignored) {}
    %>

    <table>
        <thead>
            <tr>
                <th>Employé</th>
                <th>Date début</th>
                <th>Date fin</th>
                <th>Nombre de jours</th>
                <th>Type</th>
                <th>Motif</th>
                <th>Statut</th>
            </tr>
        </thead>
        <tbody>
        <% if (conges == null || conges.isEmpty()) { %>
            <tr class="empty-row"><td colspan="7" style="text-align:center; padding:40px;">Aucun congé trouvé.</td></tr>
        <% } else {
               for (Conge c : conges) {
        %>
            <tr>
                <td><%= c.getEmployeId() != null ? dao.EmployeDAO.getNomEmployeById(c.getEmployeId()) : "-" %></td>
                <td><%= c.getDateDebut() != null ? c.getDateDebut() : "-" %></td>
                <td><%= c.getDateFin() != null ? c.getDateFin() : "-" %></td>
                <td><%= c.getNbrJours() != null ? c.getNbrJours() : "-" %></td>
                <td><%= c.getTypeConge() != null ? c.getTypeConge() : "-" %></td>
                <td><%= c.getMotif() != null ? c.getMotif() : "-" %></td>
                <td><%= c.getStatut() != null ? c.getStatut() : "-" %></td>
            </tr>
        <%   }
           }
        %>
        </tbody>
    </table>
</div>
</body>
</html>

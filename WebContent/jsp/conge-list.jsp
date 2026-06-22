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
    <div style="margin-bottom:10px;">
        <button onclick="history.back()" class="btn">Retour</button>
        <h1 style="display:inline-block; margin-left:10px;">Liste des Congés</h1>
    </div>

    <%
    int pageNumber = 1; int size = 10;
    try { if (request.getParameter("page") != null) pageNumber = Integer.parseInt(request.getParameter("page")); } catch(Exception ignored){}
    try { if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size")); } catch(Exception ignored){}
    if (pageNumber < 1) pageNumber = 1; if (size < 1) size = 10;
    int offset = (pageNumber - 1) * size;

        List<Conge> conges = new ArrayList<>();
        int total = 0;
        try {
            CongeDAO dao = new CongeDAO();
            conges = dao.getAllConges(offset, size);
            total = dao.getTotalConges();
        } catch (Exception e) {
            e.printStackTrace();
        }
        request.setAttribute("conge_total", total);
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
    <% int totalPages = (int)Math.ceil((double) total / size);
       if (totalPages > 1) { %>
        <div class="pagination">
            <% if (pageNumber > 1) { %>
                <a href="?page=<%= pageNumber - 1 %>&size=<%= size %>">&laquo; Précédent</a>
            <% } %>

            <% int startPage = Math.max(1, pageNumber - 2);
               int endPage = Math.min(totalPages, pageNumber + 2);
               if (startPage > 1) { %>
                <a href="?page=1&size=<%= size %>">1</a>
                <% if (startPage > 2) { %><span>...</span><% } %>
            <% }
               for (int i = startPage; i <= endPage; i++) {
                   if (i == pageNumber) { %>
                       <span class="active"><%= i %></span>
                   <% } else { %>
                       <a href="?page=<%= i %>&size=<%= size %>"><%= i %></a>
                   <% }
               }
               if (endPage < totalPages) {
                   if (endPage < totalPages - 1) { %><span>...</span><% }
            %>
                <a href="?page=<%= totalPages %>&size=<%= size %>"><%= totalPages %></a>
            <% } %>

            <% if (pageNumber < totalPages) { %>
                <a href="?page=<%= pageNumber + 1 %>&size=<%= size %>">Suivant &raquo;</a>
            <% } %>
        </div>
    <% } %>
</div>
</body>
</html>

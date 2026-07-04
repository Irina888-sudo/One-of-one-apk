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
    
<form method="get" action="salaire-list.jsp" class="filter-bar" style="margin:15px 0; display:flex; gap:10px; align-items:center;">
    <input type="text" id="searchInput" name="search" 
           value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>"
           placeholder="Rechercher un employé..." autocomplete="off"
           style="padding:8px; border:1px solid #ccc; border-radius:4px;">
    <div id="suggestions" style="position:relative;"></div>

    <select name="statut" style="padding:8px; border-radius:4px;">
        <option value="">Tous les statuts</option>
        <option value="ATTENTE" <%= "ATTENTE".equals(request.getParameter("statut")) ? "selected" : "" %>>En attente</option>
        <option value="PAYE" <%= "PAYE".equals(request.getParameter("statut")) ? "selected" : "" %>>Payé</option>
    </select>

    <button type="submit" class="btn">Filtrer</button>
    <a href="salaire-list.jsp" class="btn">Réinitialiser</a>
</form>
    
    <% 
        List<Salaire> salaires = new ArrayList<>();
        Connection conn = null;
        String errorMessage = null;
        // Pagination params
        int pageNumber = 1;
        int size = 10;
        try {
            String pageParam = request.getParameter("page");
            String sizeParam = request.getParameter("size");
            if (pageParam != null && !pageParam.trim().isEmpty()) pageNumber = Integer.parseInt(pageParam);
            if (sizeParam != null && !sizeParam.trim().isEmpty()) size = Integer.parseInt(sizeParam);
            if (pageNumber < 1) pageNumber = 1;
            if (size < 1) size = 10;
        } catch (Exception ignore) {}

        int offset = (pageNumber - 1) * size;

        try {
            conn = DBConnection.getConnection();
            SalaireDAO salaireDAO = new SalaireDAO(conn);
            try {
                salaires = salaireDAO.getAllSalaires(offset, size);
            } catch (Exception e) {
                errorMessage = "Erreur en récupérant les salaires: " + e.getMessage();
                e.printStackTrace();
            }
            // total count for pagination
            int total = 0;
            try { total = salaireDAO.getTotalSalaires(); } catch (Exception ignored) {}
            request.setAttribute("salaire_total", total);
        } catch (Exception e) {
            errorMessage = "Erreur de connexion à la base: " + e.getMessage();
            e.printStackTrace();
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    %>

    <% if (errorMessage != null) { %>
        <div class="alert alert-error" style="margin:10px; padding:10px;"> <strong>Erreur :</strong> <%= errorMessage %> </div>
    <% } %>
    
    

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
            </tr>
        </thead>
        <tbody>
            <% if (salaires == null || salaires.isEmpty()) { %>
                <tr class="empty-row">
                    <td colspan="7" style="text-align:center; padding:40px;">Aucun salaire trouvé.</td>
                </tr>
            <% } else {
                   // Make PAYE salaries appear first in the list for emphasis
                   salaires.sort((a, b) -> {
                       String sa = a.getStatut() == null ? "" : a.getStatut();
                       String sb = b.getStatut() == null ? "" : b.getStatut();
                       if (sa.equals("PAYE") && !sb.equals("PAYE")) return -1;
                       if (!sa.equals("PAYE") && sb.equals("PAYE")) return 1;
                       // fallback keep original order by month desc then id desc
                       java.time.LocalDate ma = a.getMois() != null ? a.getMois() : java.time.LocalDate.MIN;
                       java.time.LocalDate mb = b.getMois() != null ? b.getMois() : java.time.LocalDate.MIN;
                       int cmp = mb.compareTo(ma);
                       if (cmp != 0) return cmp;
                       return Integer.compare(b.getId(), a.getId());
                   });

                   for (Salaire salaire : salaires) {
            %>
            <tr class="<%= "PAYE".equals(salaire.getStatut()) ? "paid-row" : "" %>">
                <td><%= (salaire.getEmployeId() != null ? (EmployeDAO.getNomEmployeById(salaire.getEmployeId()) != null ? EmployeDAO.getNomEmployeById(salaire.getEmployeId()) : "-") : "-") %></td>
                <td><%= (salaire.getEmployeId() != null ? (EmployeDAO.getRoleById(salaire.getEmployeId()) != null ? EmployeDAO.getRoleById(salaire.getEmployeId()) : "-") : "-") %></td>
                <td><%= (salaire.getMois() != null ? Salaire.formatMois(salaire.getMois()) : "-") %></td>
                <td><%= (salaire.getSalaireBrut() != null ? String.format("%,.2f", salaire.getSalaireBrut()) + " Ariary" : "-") %></td>
                <td><%= (salaire.getSalaireNet() != null ? String.format("%,.2f", salaire.getSalaireNet()) + " Ariary" : "-" ) %></td>
                <td>
                    <a href="salaire-form.jsp?id=<%= salaire.getId() %>" class="btn">Modifier</a>
                </td>
                <td>
                    <% String statut = salaire.getStatut() != null ? salaire.getStatut() : "-"; %>
                    <span class="<%= "PAYE".equals(statut) ? "badge-paid" : "badge-wait" %>"><%= statut %></span>
                    <br/>
                    <a href="salaire-status.jsp?id=<%= salaire.getId() %>&statut=PAYE" class="btn" style="margin-top:6px; display:inline-block;">Marquer PAYE</a>
                    <a href="salaire-status.jsp?id=<%= salaire.getId() %>&statut=ATTENTE" class="btn" style="margin-top:6px; display:inline-block;">Marquer ATTENTE</a>
                    <% if ("PAYE".equals(statut)) { %>
                        <br/>
                        <a href="facture.jsp?id=<%= salaire.getId() %>" class="btn" target="_blank" style="margin-top:6px; display:inline-block;">📄 Facture</a>
                        <a href="salaire-export-csv.jsp?id=<%= salaire.getId() %>" class="btn" style="margin-top:6px; display:inline-block;">📊 Exporter CSV</a>
                    <% } %>
                </td>
            </tr>
            <%   }
               }
            %>
        </tbody>
    </table>

    <%-- Pagination controls --%>
    <%
        int total = request.getAttribute("salaire_total") != null ? (Integer) request.getAttribute("salaire_total") : 0;
        int totalPages = (int) Math.ceil((double) total / size);
    %>
    <% if (totalPages > 1) { %>
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
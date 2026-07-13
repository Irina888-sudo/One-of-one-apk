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
    <link rel="stylesheet" href="../../css/salaires/salaires.css">
</head>
<body style="display: flex; margin: 0; min-height: 100vh;">

<%@ include file="/jsp/nav/navbar.jsp" %>
<div style="flex: 1; display: flex; flex-direction: column;">
<%@ include file="/jsp/nav/header.jsp" %>

<div class="container">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <h1>Liste des Salaires</h1>
        <a href="salaire-form.jsp" class="btn" style="background-color: #3ecfb2; color: white; padding: 10px 20px; border-radius: 5px; text-decoration: none; font-weight: 600;">+ Nouveau Paiement</a>
    </div>
    
    <% 
        List<Salaire> salaires = new ArrayList<>();
        Connection conn = null;
        String errorMessage = null;
        String search = request.getParameter("search");
        String statutFilter = request.getParameter("statut");
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
                List<Salaire> allSalaires = salaireDAO.getAllSalaires();
                List<Salaire> filteredSalaires = new ArrayList<>();
                for (Salaire salaire : allSalaires) {
                    String employeNom = salaire.getEmployeId() != null ? (EmployeDAO.getNomEmployeById(salaire.getEmployeId()) != null ? EmployeDAO.getNomEmployeById(salaire.getEmployeId()) : "") : "";
                    String role = salaire.getEmployeId() != null ? (EmployeDAO.getRoleById(salaire.getEmployeId()) != null ? EmployeDAO.getRoleById(salaire.getEmployeId()) : "") : "";
                    String moisText = salaire.getMois() != null ? Salaire.formatMois(salaire.getMois()) : "";
                    String statutValue = salaire.getStatut() != null ? salaire.getStatut() : "";
                    boolean matchesSearch = (search == null || search.isBlank()) ||
                        employeNom.toLowerCase().contains(search.toLowerCase()) ||
                        role.toLowerCase().contains(search.toLowerCase()) ||
                        moisText.toLowerCase().contains(search.toLowerCase()) ||
                        statutValue.toLowerCase().contains(search.toLowerCase());
                    boolean matchesStatut = (statutFilter == null || statutFilter.isBlank()) || statutValue.equalsIgnoreCase(statutFilter);
                    if (matchesSearch && matchesStatut) {
                        filteredSalaires.add(salaire);
                    }
                }
                filteredSalaires.sort((a, b) -> {
                    String sa = a.getStatut() == null ? "" : a.getStatut();
                    String sb = b.getStatut() == null ? "" : b.getStatut();
                    if (sa.equals("PAYE") && !sb.equals("PAYE")) return -1;
                    if (!sa.equals("PAYE") && sb.equals("PAYE")) return 1;
                    java.time.LocalDate ma = a.getMois() != null ? a.getMois() : java.time.LocalDate.MIN;
                    java.time.LocalDate mb = b.getMois() != null ? b.getMois() : java.time.LocalDate.MIN;
                    int cmp = mb.compareTo(ma);
                    if (cmp != 0) return cmp;
                    return Integer.compare(b.getId(), a.getId());
                });
                int total = filteredSalaires.size();
                request.setAttribute("salaire_total", total);
                for (int i = offset; i < Math.min(offset + size, filteredSalaires.size()); i++) {
                    salaires.add(filteredSalaires.get(i));
                }
            } catch (Exception e) {
                errorMessage = "Erreur en recuperant les salaires: " + e.getMessage();
                e.printStackTrace();
            }
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

    <form method="get" style="display:flex; gap:10px; align-items:center; flex-wrap:wrap; margin:10px 0 20px;">
        <input type="text" name="search" placeholder="Nom, rôle, mois, statut..." value="<%= search != null ? search : "" %>" style="padding:10px 12px; border:1px solid #d0d7de; border-radius:8px; min-width:240px;">
        <select name="statut" style="padding:10px 12px; border:1px solid #d0d7de; border-radius:8px;">
            <option value="" <%= (statutFilter == null || statutFilter.isBlank()) ? "selected" : "" %>>Tous les statuts</option>
            <option value="PAYE" <%= "PAYE".equals(statutFilter) ? "selected" : "" %>>PAYE</option>
            <option value="ATTENTE" <%= "ATTENTE".equals(statutFilter) ? "selected" : "" %>>ATTENTE</option>
        </select>
        <button type="submit" class="btn" style="background-color:#3ecfb2; color:white; padding:10px 16px; border:none; border-radius:8px;">Rechercher</button>
        <a href="salaire-list.jsp" class="btn" style="background-color:#6b7280; color:white; padding:10px 16px; border-radius:8px; text-decoration:none;">Reinitialiser</a>
    </form>

    <table>
        <thead>
            <tr>
            
                <th>Nom Employe</th>
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
                    <td colspan="7" style="text-align:center; padding:40px;">Aucun salaire trouve.</td>
                </tr>
            <% } else {
                   for (Salaire salaire : salaires) {
            %>
            <tr class="<%= "PAYE".equals(salaire.getStatut()) ? "paid-row" : "" %>">
                <td><%= (salaire.getEmployeId() != null ? (EmployeDAO.getNomEmployeById(salaire.getEmployeId()) != null ? EmployeDAO.getNomEmployeById(salaire.getEmployeId()) : "-") : "-") %></td>
                <td><%= (salaire.getEmployeId() != null ? (EmployeDAO.getRoleById(salaire.getEmployeId()) != null ? EmployeDAO.getRoleById(salaire.getEmployeId()) : "-") : "-") %></td>
                <td><%= (salaire.getMois() != null ? Salaire.formatMois(salaire.getMois()) : "-") %></td>
                <td><%= (salaire.getSalaireBrut() != null ? String.format("%,.2f", salaire.getSalaireBrut()) + " Ariary" : "-") %></td>
                <td><%= (salaire.getSalaireNet() != null ? String.format("%,.2f", salaire.getSalaireNet()) + " Ariary" : "-" ) %></td>
                <td>
                    <div class="actions">
                        <a href="salaire-form.jsp?id=<%= salaire.getId() %>" class="icon-btn" data-tip="Modifier" aria-label="Modifier">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M11 5H6a2 2 0 00-2 2v9a2 2 0 002 2h9a2 2 0 002-2v-5m-1.414-9.586a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                        </a>
                        <a href="salaire-status.jsp?id=<%= salaire.getId() %>&statut=PAYE" class="icon-btn" data-tip="Marquer PAYE" aria-label="Marquer PAYE">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                        </a>
                        <a href="salaire-status.jsp?id=<%= salaire.getId() %>&statut=ATTENTE" class="icon-btn" data-tip="Marquer ATTENTE" aria-label="Marquer ATTENTE">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        </a>
                        <% if ("PAYE".equals(salaire.getStatut())) { %>
                            <a href="facture.jsp?id=<%= salaire.getId() %>" class="icon-btn" data-tip="Facture" aria-label="Facture">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 4H7a2 2 0 01-2-2V6a2 2 0 012-2h7l5 5v11a2 2 0 01-2 2z"/></svg>
                            </a>
                        <% } %>
                        <a href="salaire-export-csv.jsp?id=<%= salaire.getId() %>" class="icon-btn" data-tip="Exporter CSV" aria-label="Exporter CSV">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M4 16v2a2 2 0 002 2h12a2 2 0 002-2v-2M7 10l5 5 5-5M12 15V3"/></svg>
                        </a>
                        <button type="button" onclick="envoyerEmailSalaire(<%= salaire.getId() %>, '<%= EmployeDAO.getNomEmployeById(salaire.getEmployeId()) %>')" class="icon-btn" data-tip="Envoyer Email" aria-label="Envoyer Email">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M3 8l9 6 9-6M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
                        </button>
                    </div>
                </td>
                <td>
                    <% String statut = salaire.getStatut() != null ? salaire.getStatut() : "-"; %>
                    <span class="<%= "PAYE".equals(statut) ? "badge-paid" : "badge-wait" %>"><%= statut %></span>
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
                <a href="?page=<%= pageNumber - 1 %>&size=<%= size %>">&laquo; Precedent</a>
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
</div>
</body>
<script>
function envoyerEmailSalaire(salaireId, employeName) {
    fetch('send-email.jsp?id=' + salaireId, {
        method: 'GET'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('Succes: ' + data.message);
        } else {
            alert('Erreur: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Erreur:', error);
        alert('Erreur lors de l\'envoi de l\'email');
    });
}
</script>
</html>
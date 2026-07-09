<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal, model.Salaire, dao.SalaireDAO, dao.EmployeDAO, util.DBConnection" %>
<%@ page import="java.sql.Connection" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Salaires - OneOfOne</title>
    <link rel="stylesheet" href="../css/salaires.css">
</head>
<body style="display: flex; margin: 0; min-height: 100vh;">

<%@ include file="nav/navbar.jsp" %>
<div style="flex: 1; display: flex; flex-direction: column;">
<%@ include file="nav/header.jsp" %>

<div class="container">
    <div class="header-row">
        <div>
            <h1>Liste des Salaires</h1>
            <p class="subtitle">OneOfOne - Gestion RH</p>
        </div>
        <a href="salaire-form.jsp" class="btn-add">
            <svg viewBox="0 0 24 24">
                <line x1="12" y1="5" x2="12" y2="19"/>
                <line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
            Nouveau Paiement
        </a>
    </div>
    
    <%
        List<Salaire> salaires = new ArrayList<>();
        Connection conn = null;
        String errorMessage = null;
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
        <div class="alert alert-error"><strong>Erreur :</strong> <%= errorMessage %></div>
    <% } %>

    <!-- Stats Row -->
    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-label">Total Salaires</div>
            <div class="stat-value"><%= salaires != null ? salaires.size() : 0 %></div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Payés</div>
            <div class="stat-value">
                <span class="highlight">
                    <% 
                        int payeCount = 0;
                        if (salaires != null) {
                            for (Salaire s : salaires) {
                                if ("PAYE".equals(s.getStatut())) payeCount++;
                            }
                        }
                        out.print(payeCount);
                    %>
                </span>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-label">En Attente</div>
            <div class="stat-value" style="color: #b97b00;">
                <% 
                    int waitCount = 0;
                    if (salaires != null) {
                        for (Salaire s : salaires) {
                            if (!"PAYE".equals(s.getStatut())) waitCount++;
                        }
                    }
                    out.print(waitCount);
                %>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Total Brut</div>
            <div class="stat-value">
                <span class="highlight">
                    <% 
                        BigDecimal totalBrut = BigDecimal.ZERO;
                        if (salaires != null) {
                            for (Salaire s : salaires) {
                                if (s.getSalaireBrut() != null) totalBrut = totalBrut.add(s.getSalaireBrut());
                            }
                        }
                        out.print(String.format("%,.0f Ar", totalBrut));
                    %>
                </span>
            </div>
        </div>
    </div>

    <!-- ==========================================================
         TABLEAU À LIGNES SÉPARÉES
    ========================================================== -->
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>Employé</th>
                    <th>Rôle</th>
                    <th>Mois</th>
                    <th>Salaire Brut</th>
                    <th>Salaire Net</th>
                    <th>Statut</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (salaires == null || salaires.isEmpty()) { %>
                    <tr>
                        <td colspan="7" style="text-align:center; padding:40px; color:#888;">
                            Aucun salaire trouvé.
                        </td>
                    </tr>
                <% } else {
                       salaires.sort((a, b) -> {
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

                       for (Salaire salaire : salaires) {
                           String statut = salaire.getStatut() != null ? salaire.getStatut() : "-";
                           String nomEmploye = salaire.getEmployeId() != null ? 
                               (EmployeDAO.getNomEmployeById(salaire.getEmployeId()) != null ? 
                                EmployeDAO.getNomEmployeById(salaire.getEmployeId()) : "-") : "-";
                           String role = salaire.getEmployeId() != null ? 
                               (EmployeDAO.getRoleById(salaire.getEmployeId()) != null ? 
                                EmployeDAO.getRoleById(salaire.getEmployeId()) : "-") : "-";
                %>
                    <tr class="<%= "PAYE".equals(statut) ? "paid-row" : "" %>">
                        <td><strong><%= nomEmploye %></strong></td>
                        <td><%= role %></td>
                        <td><%= salaire.getMois() != null ? Salaire.formatMois(salaire.getMois()) : "-" %></td>
                        <td><%= salaire.getSalaireBrut() != null ? String.format("%,.0f Ar", salaire.getSalaireBrut()) : "-" %></td>
                        <td><%= salaire.getSalaireNet() != null ? String.format("%,.0f Ar", salaire.getSalaireNet()) : "-" %></td>
                        <td>
                            <span class="badge <%= "PAYE".equals(statut) ? "badge-paid" : "badge-wait" %>">
                                <span class="dot"></span>
                                <%= statut %>
                            </span>
                        </td>
                        <td>
                            <div class="actions-group">
                                <a href="salaire-form.jsp?id=<%= salaire.getId() %>" class="action-icon action-edit" title="Modifier">
                                    <svg viewBox="0 0 24 24">
                                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                                    </svg>
                                </a>
                                <a href="salaire-status.jsp?id=<%= salaire.getId() %>&statut=PAYE" class="action-icon action-pay" title="Marquer PAYE">
                                    <svg viewBox="0 0 24 24">
                                        <path d="M12 2v20M2 12h20"/>
                                        <circle cx="12" cy="12" r="10"/>
                                    </svg>
                                </a>
                                <a href="salaire-status.jsp?id=<%= salaire.getId() %>&statut=ATTENTE" class="action-icon action-pay" title="Marquer ATTENTE">
                                    <svg viewBox="0 0 24 24">
                                        <circle cx="12" cy="12" r="10"/>
                                        <line x1="12" y1="8" x2="12" y2="12"/>
                                        <line x1="12" y1="16" x2="12.01" y2="16"/>
                                    </svg>
                                </a>
                                <% if ("PAYE".equals(statut)) { %>
                                    <a href="facture.jsp?id=<%= salaire.getId() %>" class="action-icon action-invoice" title="Facture">
                                        <svg viewBox="0 0 24 24">
                                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                                            <polyline points="14 2 14 8 20 8"/>
                                            <line x1="16" y1="13" x2="8" y2="13"/>
                                            <line x1="16" y1="17" x2="8" y2="17"/>
                                        </svg>
                                    </a>
                                <% } %>
                                <a href="salaire-export-csv.jsp?id=<%= salaire.getId() %>" class="action-icon action-export" title="Exporter CSV">
                                    <svg viewBox="0 0 24 24">
                                        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                                        <polyline points="7 10 12 15 17 10"/>
                                        <line x1="12" y1="15" x2="12" y2="3"/>
                                    </svg>
                                </a>
                                <button onclick="envoyerEmailSalaire(<%= salaire.getId() %>, '<%= nomEmploye %>')" class="action-icon action-email" title="Envoyer Email">
                                    <svg viewBox="0 0 24 24">
                                        <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                                        <polyline points="22,6 12,13 2,6"/>
                                    </svg>
                                </button>
                            </div>
                        </td>
                    </tr>
                <%   }
                   }
                %>
            </tbody>
        </table>
    </div>

    <%-- Pagination --%>
    <%
        int total = request.getAttribute("salaire_total") != null ? (Integer) request.getAttribute("salaire_total") : 0;
        int totalPages = (int) Math.ceil((double) total / size);
    %>
    <% if (totalPages > 1) { %>
        <div class="pagination">
            <span class="info"><%= (pageNumber - 1) * size + 1 %> à <%= Math.min(pageNumber * size, total) %> sur <%= total %></span>
            <div class="pages">
                <% if (pageNumber > 1) { %>
                    <a href="?page=<%= pageNumber - 1 %>&size=<%= size %>">&laquo;</a>
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
                    <a href="?page=<%= pageNumber + 1 %>&size=<%= size %>">&raquo;</a>
                <% } %>
            </div>
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
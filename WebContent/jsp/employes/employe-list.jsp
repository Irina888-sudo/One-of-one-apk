<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/jsp/auth/check-auth.jsp" %>
<%@ page import="java.util.*, java.math.BigDecimal, model.Employe, model.Salaire, dao.EmployeDAO, dao.SalaireDAO" %>
<%@ page import="java.sql.Date" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Employes - OneOfOne</title>
    <link rel="stylesheet" href="../../css/employes/employes.css">
</head>
<body style="display: flex; margin: 0; min-height: 100vh;">
    <%@ include file="/jsp/nav/navbar.jsp" %>
    <div style="flex: 1; display: flex; flex-direction: column;">
        <%@ include file="/jsp/nav/header.jsp" %>
<%
    EmployeDAO employeDAO = new EmployeDAO();
    SalaireDAO salaireDAO = new SalaireDAO();
    
    String statut = request.getParameter("statut");
    String role = request.getParameter("role");
    String dateDebut = request.getParameter("dateDebut");
    String dateFin = request.getParameter("dateFin");
    String search = request.getParameter("search");
    
    // Parametres de tri
    String sortBy = request.getParameter("sortBy");
    String sortOrder = request.getParameter("sortOrder");
    
    if (sortBy == null || sortBy.isEmpty()) sortBy = "id";
    if (sortOrder == null || sortOrder.isEmpty()) sortOrder = "ASC";
    
    String basePath = request.getContextPath() + "/jsp/";
    
    int pageNumber = 1;
    int recordsPerPage = 10;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.trim().isEmpty()) {
        try {
            pageNumber = Integer.parseInt(pageParam);
        } catch (NumberFormatException e) {
            pageNumber = 1;
        }
    }
    
    int offset = (pageNumber - 1) * recordsPerPage;
    
    // Recuperation des donnees avec tri
    List<Employe> employes = employeDAO.getAllEmployes(statut, role, dateDebut, dateFin, search, 
                                                        sortBy, sortOrder, offset, recordsPerPage);
    int totalEmployes = employeDAO.getTotalEmployes(statut, role, dateDebut, dateFin, search);
    int totalPages = (int) Math.ceil((double) totalEmployes / recordsPerPage);
    
    List<String> roles = employeDAO.getAllRoles();
    
    String successMessage = request.getParameter("success");
    String errorMessage = request.getParameter("error");
    
    // Construction de l'URL de base pour les liens
    String queryParams = "";
    if (statut != null && !statut.isEmpty()) queryParams += "&statut=" + statut;
    if (role != null && !role.isEmpty() && !role.equals("TOUS")) queryParams += "&role=" + role;
    if (dateDebut != null && !dateDebut.isEmpty()) queryParams += "&dateDebut=" + dateDebut;
    if (dateFin != null && !dateFin.isEmpty()) queryParams += "&dateFin=" + dateFin;
    if (search != null && !search.isEmpty()) queryParams += "&search=" + java.net.URLEncoder.encode(search, "UTF-8");
    if (sortBy != null && !sortBy.isEmpty()) queryParams += "&sortBy=" + sortBy;
    if (sortOrder != null && !sortOrder.isEmpty()) queryParams += "&sortOrder=" + sortOrder;
%>

<div class="container">
    <div class="header">
        <h1> Gestion des Employes</h1>
        <p>OneOfOne - Application de gestion RH</p>
    </div>
    
    <div class="nav">
        <div class="nav-links">
            <a href="employe-form.jsp" class="btn btn-primary">+ Nouvel Employe</a>
        </div>
        <div>
            Total : <strong><%= totalEmployes %></strong> employe(s)
        </div>
    </div>
    
    <!-- Messages d'alerte -->
    <% if (successMessage != null && !successMessage.isEmpty()) { %>
        <div class="alert alert-success">
             <%= successMessage %>
        </div>
    <% } %>
    
    <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
        <div class="alert alert-error">
            Erreur : <%= errorMessage %>
        </div>
    <% } %>
    
    <!-- Filtres et recherche -->
    <div class="filters">
        <form method="get" action="employe-list.jsp" class="filter-form">
            <div class="filter-group">
                <label>Statut</label>
                <select name="statut">
                    <option value="">Tous</option>
                    <option value="ACTIF" <%= "ACTIF".equals(statut) ? "selected" : "" %>>ACTIF</option>
                    <option value="INACTIF" <%= "INACTIF".equals(statut) ? "selected" : "" %>>INACTIF</option>
                </select>
            </div>
            
            <div class="filter-group">
                <label>Role</label>
                <select name="role">
                    <option value="">Tous</option>
                    <% for(String r : roles) { 
                        if(!r.equals("TOUS")) {
                    %>
                        <option value="<%= r %>" <%= r.equals(role) ? "selected" : "" %>><%= r %></option>
                    <% } } %>
                </select>
            </div>
            
            <div class="filter-group">
                <label>Date embauche (debut)</label>
                <input type="date" name="dateDebut" value="<%= dateDebut != null ? dateDebut : "" %>">
            </div>
            
            <div class="filter-group">
                <label>Date embauche (fin)</label>
                <input type="date" name="dateFin" value="<%= dateFin != null ? dateFin : "" %>">
            </div>
            
            
            <!-- NOUVEAU : Selecteur de tri -->
            <div class="filter-group">
                <label>Trier par</label>
                <select name="sortBy" onchange="this.form.submit()">
                    <option value="id" <%= "id".equals(sortBy) ? "selected" : "" %>>ID</option>
                    <option value="nom" <%= "nom".equals(sortBy) ? "selected" : "" %>>Nom (A-Z)</option>
                    <option value="date" <%= "date".equals(sortBy) ? "selected" : "" %>>Date d'embauche</option>
                </select>
            </div>
            
            <div class="filter-group">
                <label>Ordre</label>
                <select name="sortOrder" onchange="this.form.submit()">
                    <option value="ASC" <%= "ASC".equals(sortOrder) ? "selected" : "" %>>Croissant </option>
                    <option value="DESC" <%= "DESC".equals(sortOrder) ? "selected" : "" %>>Decroissant </option>
                </select>
            </div>
            
            <div class="filter-actions">
                <button type="submit" class="btn btn-primary">Appliquer</button>
                <a href="employe-list.jsp" class="btn btn-warning">Reinitialiser</a>
            </div>
        </form>
    </div>
    
    <!-- Affichage du tri actif -->
    <div class="sort-info" style="padding: 10px 30px; background: #e3f2fd; margin: 10px 0; border-radius: 5px;">
        <strong> Tri actif :</strong> 
        <% 
            String sortLabel = "";
            switch(sortBy) {
                case "id": sortLabel = "ID"; break;
                case "nom": sortLabel = "Nom"; break;
                case "date": sortLabel = "Date d'embauche"; break;
            }
        %>
        Par <%= sortLabel %> 
        <%= "ASC".equals(sortOrder) ? "Croissant ↑" : "Decroissant ↓" %>
    </div>
    
    <!-- Liste des employes -->
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nom</th>
                    <th>Email</th>
                    <th>Telephone</th>
                    <th>Role</th>
                    <th>Salaire Brut</th>
                    <th>Statut</th>
                    <th>Date d'embauche</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (employes.isEmpty()) { %>
                    <tr class="empty-row">
                        <td colspan="9" style="text-align: center; padding: 40px;">
                             Aucun employe trouve
                        </td>
                    </tr>
                <% } else { %>
                    <% for(Employe e : employes) { %>
                        <tr>
                            <td><%= e.getId() %></td>
                            <td><strong><%= e.getNom() %></strong></td>
                            <td><%= e.getEmail() != null ? e.getEmail() : "-" %></td>
                            <td><%= e.getTelephone() != null ? e.getTelephone() : "-" %></td>
                            <td><%= e.getRole() != null ? e.getRole() : "-" %></td>
                            <td><%= String.format("%,.2f", e.getSalaireBrut()) %> Ariary</td>
                            <td>
                                <% if ("ACTIF".equals(e.getStatut())) { %>
                                    <span class="badge badge-success">ACTIF</span>
                                <% } else { %>
                                    <span class="badge badge-danger">INACTIF</span>
                                <% } %>
                            </td>
                            <td><%= e.getDateEmbauche() != null ? e.getDateEmbauche() : "-" %></td>
                            <td class="actions">
                                <a href="employe-form.jsp?id=<%= e.getId() %>" class="btn-icon edit" title="Modifier">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                </a>
                                <%
                                    Salaire latestSalaire = null;
                                    try {
                                        latestSalaire = salaireDAO.findLatestByEmployeId(e.getId());
                                    } catch (Exception ex) {
                                        latestSalaire = null;
                                    }
                                %>
                                <a href="employe-delete.jsp?id=<%= e.getId() %>" class="btn-icon del" 
                                   title="Desactiver" onclick="return confirm('Etes-vous sur de vouloir desactiver cet employe ?')">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 20.5a6.5 6.5 0 0113 0"/>
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19 8l-4 4m0 0l4 4M15 12h-9"/>
                                    </svg>
                                </a>
                            </td>
                        </tr>
                    <% } %>
                <% } %>
            </tbody>
        </table>
    </div>
    
    <!-- Pagination -->
    <% if (totalPages > 1) { %>
        <div class="pagination">
            <% if (pageNumber > 1) { %>
                <a href="?page=<%= pageNumber - 1 %><%= queryParams %>">&laquo; Precedent</a>
            <% } %>
            
            <% 
            int startPage = Math.max(1, pageNumber - 2);
            int endPage = Math.min(totalPages, pageNumber + 2);
            
            if (startPage > 1) { %>
                <a href="?page=1<%= queryParams %>">1</a>
                <% if (startPage > 2) { %>
                    <span>...</span>
                <% } %>
            <% } %>
            
            <% for(int i = startPage; i <= endPage; i++) { %>
                <% if (i == pageNumber) { %>
                    <span class="active"><%= i %></span>
                <% } else { %>
                    <a href="?page=<%= i %><%= queryParams %>"><%= i %></a>
                <% } %>
            <% } %>
            
            <% if (endPage < totalPages) { %>
                <% if (endPage < totalPages - 1) { %>
                    <span>...</span>
                <% } %>
                <a href="?page=<%= totalPages %><%= queryParams %>"><%= totalPages %></a>
            <% } %>
            
            <% if (pageNumber < totalPages) { %>
                <a href="?page=<%= pageNumber + 1 %><%= queryParams %>">Suivant &raquo;</a>
            <% } %>
        </div>
    <% } %>
</div>

<script>
   
    document.querySelectorAll('select').forEach(select => {
        select.addEventListener('change', () => {
            document.querySelector('form').submit();
        });
    });
</script>
    </div>
</body>
</html>

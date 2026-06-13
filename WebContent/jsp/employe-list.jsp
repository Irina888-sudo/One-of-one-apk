<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal, model.Employe, dao.EmployeDAO" %>
<%@ page import="java.sql.Date" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Employés - OneOfOne</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<%
    EmployeDAO employeDAO = new EmployeDAO();
    
    String statut = request.getParameter("statut");
    String role = request.getParameter("role");
    String dateDebut = request.getParameter("dateDebut");
    String dateFin = request.getParameter("dateFin");
    String search = request.getParameter("search");
    
    // Paramètres de tri
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
    
    // Récupération des données avec tri
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
        <h1> Gestion des Employés</h1>
        <p>OneOfOne - Application de gestion RH</p>
    </div>
    
    <div class="nav">
        <div class="nav-links">
            <a href="<%= basePath %>employe-list.jsp"> Accueil</a>
            <a href="<%= basePath %>employe-form.jsp"> Nouvel Employé</a>
        </div>
        <div>
            Total : <strong><%= totalEmployes %></strong> employé(s)
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
        <form method="get" action="<%= basePath %>employe-list.jsp" class="filter-form">
            <div class="filter-group">
                <label>Statut</label>
                <select name="statut">
                    <option value="">Tous</option>
                    <option value="ACTIF" <%= "ACTIF".equals(statut) ? "selected" : "" %>>ACTIF</option>
                    <option value="INACTIF" <%= "INACTIF".equals(statut) ? "selected" : "" %>>INACTIF</option>
                </select>
            </div>
            
            <div class="filter-group">
                <label>Rôle</label>
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
                <label>Date embauche (début)</label>
                <input type="date" name="dateDebut" value="<%= dateDebut != null ? dateDebut : "" %>">
            </div>
            
            <div class="filter-group">
                <label>Date embauche (fin)</label>
                <input type="date" name="dateFin" value="<%= dateFin != null ? dateFin : "" %>">
            </div>
            
            <div class="filter-group">
                <label>Recherche</label>
                <input type="text" name="search" placeholder="Nom ou email..." value="<%= search != null ? search : "" %>">
            </div>
            
            <!-- NOUVEAU : Sélecteur de tri -->
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
                    <option value="DESC" <%= "DESC".equals(sortOrder) ? "selected" : "" %>>Décroissant </option>
                </select>
            </div>
            
            <div class="filter-group">
                <label>&nbsp;</label>
                <button type="submit" class="btn btn-primary"> Filtrer</button>
            </div>
            
            <div class="filter-group">
                <label>&nbsp;</label>
                <a href="<%= basePath %>employe-list.jsp" class="btn btn-warning"> Réinitialiser</a>
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
        <%= "ASC".equals(sortOrder) ? "Croissant ↑" : "Décroissant ↓" %>
    </div>
    
    <!-- Liste des employés -->
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nom</th>
                    <th>Email</th>
                    <th>Téléphone</th>
                    <th>Rôle</th>
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
                             Aucun employé trouvé
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
                            <td><%= String.format("%,.2f", e.getSalaireBrut()) %> €</td>
                            <td>
                                <% if ("ACTIF".equals(e.getStatut())) { %>
                                    <span class="badge badge-success">ACTIF</span>
                                <% } else { %>
                                    <span class="badge badge-danger">INACTIF</span>
                                <% } %>
                            </td>
                            <td><%= e.getDateEmbauche() != null ? e.getDateEmbauche() : "-" %></td>
                            <td class="actions">
                                <a href="<%= basePath %>employe-form.jsp?id=<%= e.getId() %>" class="btn btn-primary btn-small"> Modifier</a>
                                <a href="<%= basePath %>employe-delete.jsp?id=<%= e.getId() %>" class="btn btn-danger btn-small" 
                                   onclick="return confirm('Êtes-vous sûr de vouloir désactiver cet employé ?')"> Désactiver</a>
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
                <a href="?page=<%= pageNumber - 1 %><%= queryParams %>">&laquo; Précédent</a>
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
    // Auto-submit quand les selects changent
    document.querySelectorAll('select').forEach(select => {
        select.addEventListener('change', () => {
            document.querySelector('form').submit();
        });
    });
</script>
</body>
</html>
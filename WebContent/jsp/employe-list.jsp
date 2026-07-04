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
    
    List<Employe> employes = employeDAO.getAllEmployes(statut, role, dateDebut, dateFin, search, 
                                                        sortBy, sortOrder, offset, recordsPerPage);
    int totalEmployes = employeDAO.getTotalEmployes(statut, role, dateDebut, dateFin, search);
    int totalPages = (int) Math.ceil((double) totalEmployes / recordsPerPage);
    
    List<String> roles = employeDAO.getAllRoles();
    
    String successMessage = request.getParameter("success");
    String errorMessage = request.getParameter("error");
    
    String queryParams = "";
    if (statut != null && !statut.isEmpty()) queryParams += "&statut=" + statut;
    if (role != null && !role.isEmpty() && !role.equals("TOUS")) queryParams += "&role=" + role;
    if (dateDebut != null && !dateDebut.isEmpty()) queryParams += "&dateDebut=" + dateDebut;
    if (dateFin != null && !dateFin.isEmpty()) queryParams += "&dateFin=" + dateFin;
    if (search != null && !search.isEmpty()) queryParams += "&search=" + java.net.URLEncoder.encode(search, "UTF-8");
    if (sortBy != null && !sortBy.isEmpty()) queryParams += "&sortBy=" + sortBy;
    if (sortOrder != null && !sortOrder.isEmpty()) queryParams += "&sortOrder=" + sortOrder;
    
    String suggestionsPath = request.getContextPath() + "/jsp/suggestions.jsp";
%>

<div class="container">
    <div class="header">
        <h1>Gestion des Employés</h1>
        <p>OneOfOne - Application de gestion RH</p>
    </div>
    
    <div class="nav">
        <div class="nav-links">
            <a href="<%= basePath %>employe-list.jsp">Accueil</a>
            <a href="<%= basePath %>employe-form.jsp">Nouvel Employé</a>
        </div>
        <div>
            Total : <strong><%= totalEmployes %></strong> employé(s)
        </div>
    </div>
    
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
    

    <div class="filters">
        <form method="get" action="<%= basePath %>employe-list.jsp" class="filter-form" id="filterForm">
            <div class="filter-group">
                <label for="statutSelect">Statut</label>
                <select name="statut" id="statutSelect">
                    <option value="">Tous</option>
                    <option value="ACTIF" <%= "ACTIF".equals(statut) ? "selected" : "" %>>ACTIF</option>
                    <option value="INACTIF" <%= "INACTIF".equals(statut) ? "selected" : "" %>>INACTIF</option>
                </select>
            </div>
            
            <div class="filter-group">
                <label for="roleSelect">Rôle</label>
                <select name="role" id="roleSelect">
                    <option value="">Tous</option>
                    <% for(String r : roles) { 
                        if(!r.equals("TOUS")) {
                    %>
                        <option value="<%= r %>" <%= r.equals(role) ? "selected" : "" %>><%= r %></option>
                    <% } } %>
                </select>
            </div>
            
            <div class="filter-group">
                <label for="dateDebut">Date embauche (début)</label>
                <input type="date" name="dateDebut" id="dateDebut" value="<%= dateDebut != null ? dateDebut : "" %>">
            </div>
            
            <div class="filter-group">
                <label for="dateFin">Date embauche (fin)</label>
                <input type="date" name="dateFin" id="dateFin" value="<%= dateFin != null ? dateFin : "" %>">
            </div>
            
            <div class="filter-group" style="position: relative; flex: 2;">
                <label for="searchInput">Recherche</label>
                <div class="search-container">
                    <input type="text" name="search" id="searchInput" 
                           placeholder="Nom ou email..." 
                           value="<%= search != null ? search : "" %>"
                           autocomplete="off">
                    <div class="suggestions-box" id="suggestionsBox"></div>
                </div>
            </div>
            
            <div class="filter-group">
                <label for="sortBySelect">Trier par</label>
                <select name="sortBy" id="sortBySelect">
                    <option value="id" <%= "id".equals(sortBy) ? "selected" : "" %>>ID</option>
                    <option value="nom" <%= "nom".equals(sortBy) ? "selected" : "" %>>Nom (A-Z)</option>
                    <option value="date" <%= "date".equals(sortBy) ? "selected" : "" %>>Date d'embauche</option>
                </select>
            </div>
            
            <div class="filter-group">
                <label for="sortOrderSelect">Ordre</label>
                <select name="sortOrder" id="sortOrderSelect">
                    <option value="ASC" <%= "ASC".equals(sortOrder) ? "selected" : "" %>>Croissant</option>
                    <option value="DESC" <%= "DESC".equals(sortOrder) ? "selected" : "" %>>Décroissant</option>
                </select>
            </div>
            
            <div class="filter-group">
                <label>&nbsp;</label>
                <button type="submit" class="btn btn-primary">Filtrer</button>
            </div>
            
            <div class="filter-group">
                <label>&nbsp;</label>
                <a href="<%= basePath %>employe-list.jsp" class="btn btn-warning">Réinitialiser</a>
            </div>
        </form>
    </div>
    
    <div class="sort-info" style="padding: 10px 30px; background: #e3f2fd; margin: 10px 0; border-radius: 5px;">
        <strong>Tri actif :</strong> 
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
                                <a href="<%= basePath %>employe-form.jsp?id=<%= e.getId() %>" class="btn btn-primary btn-small">Modifier</a>
                                <% if ("ACTIF".equals(e.getStatut())) { %>
                                    <a href="<%= basePath %>employe-delete.jsp?id=<%= e.getId() %>" class="btn btn-danger btn-small" 
                                       onclick="return confirm('Êtes-vous sûr de vouloir désactiver cet employé ?')">Désactiver</a>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                <% } %>
            </tbody>
        </table>
    </div>
    

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

    (function() {
        const box = document.getElementById('suggestionsBox');
        if (box) {
            box.innerHTML = '';
            box.classList.remove('active');
            console.log('🧹 Boîte de suggestions vidée à l\'initialisation');
        }
    })();

    let debounceTimer;
    let currentXHR = null;
    const searchInput = document.getElementById('searchInput');
    const suggestionsBox = document.getElementById('suggestionsBox');
    const filterForm = document.getElementById('filterForm');
    const suggestionsUrl = '<%= request.getContextPath() %>/jsp/suggestions.jsp';

    document.addEventListener('DOMContentLoaded', function() {
        if (suggestionsBox) {
            suggestionsBox.innerHTML = '';
            suggestionsBox.classList.remove('active');
        }
        
        console.log('🔍 Vérification des éléments:');
        console.log('- searchInput:', searchInput);
        console.log('- suggestionsBox:', suggestionsBox);
        console.log('- filterForm:', filterForm);
        console.log('🚀 Page chargée, URL des suggestions:', suggestionsUrl);
        
        if (suggestionsBox) {
            suggestionsBox.innerHTML = '';
            suggestionsBox.classList.remove('active');
        }
    });

    function fetchSuggestions(query) {
        console.log('🔍 Recherche de suggestions pour:', query);

        if (currentXHR) {
            currentXHR.abort();
            currentXHR = null;
        }

        if (query.trim().length === 0) {
            suggestionsBox.innerHTML = '';
            suggestionsBox.classList.remove('active');
            return;
        }

        suggestionsBox.innerHTML = '<div class="suggestion-loading"><div class="spinner"></div> Recherche en cours...</div>';
        suggestionsBox.classList.add('active');

        currentXHR = new XMLHttpRequest();
        const url = suggestionsUrl + '?q=' + encodeURIComponent(query);
        console.log('📡 URL de la requête:', url);
        
        currentXHR.open('GET', url, true);
        currentXHR.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        
        currentXHR.onreadystatechange = function() {
            if (currentXHR.readyState === 4) {
                if (currentXHR.status === 200) {
                    try {
                        if (currentXHR.responseText && currentXHR.responseText.trim().length > 0) {
                            const suggestions = JSON.parse(currentXHR.responseText);
                            console.log('✅ Suggestions trouvées:', suggestions);
                            displaySuggestions(suggestions);
                        } else {
                            suggestionsBox.innerHTML = '<div class="suggestion-no-result">Aucun employé trouvé</div>';
                        }
                    } catch (e) {
    console.log("===== REPONSE =====");
    console.log(currentXHR.responseText);

    console.error("===== ERREUR =====");
    console.error(e);

    suggestionsBox.innerHTML =
        "<div class='suggestion-no-result'>Erreur de chargement</div>";
}
                } else {
                    suggestionsBox.innerHTML = '<div class="suggestion-no-result">Erreur de chargement (HTTP ' + currentXHR.status + ')</div>';
                }
                currentXHR = null;
            }
        };
        
        currentXHR.onerror = function() {
            console.error('❌ Erreur de connexion');
            suggestionsBox.innerHTML = '<div class="suggestion-no-result">Erreur de connexion</div>';
            currentXHR = null;
        };
        
        currentXHR.send();
    }

function displaySuggestions(suggestions) {

    suggestionsBox.innerHTML = "";

    if (!suggestions || suggestions.length === 0) {
        suggestionsBox.innerHTML =
            "<div class='suggestion-no-result'>Aucun résultat</div>";
        return;
    }

    const ul = document.createElement("ul");
    ul.style.listStyle = "none";
    ul.style.margin = "0";
    ul.style.padding = "0";

    suggestions.forEach(function(emp){

        const li = document.createElement("li");

        li.className = "suggestion-item";

        li.innerHTML =
            "<strong>"+emp.nom+"</strong><br>" +
            emp.role + "<br>" +
            emp.email;

        li.onclick = function(){
            searchInput.value = emp.nom;
            suggestionsBox.innerHTML = "";
            filterForm.submit();
        };

        ul.appendChild(li);
    });

    suggestionsBox.appendChild(ul);
    suggestionsBox.classList.add("active");
}

    if (searchInput) {
        searchInput.addEventListener('input', function() {
            clearTimeout(debounceTimer);
            const query = this.value;
            console.log('⌨️ Texte saisi:', query);
            
            debounceTimer = setTimeout(function() {
                fetchSuggestions(query);
            }, 300);
        });
    }

    document.addEventListener('click', function(e) {
        const searchContainer = document.querySelector('.search-container');
        if (searchContainer && !searchContainer.contains(e.target)) {
            suggestionsBox.innerHTML = '';
            suggestionsBox.classList.remove('active');
        }
    });

    if (suggestionsBox) {
        suggestionsBox.addEventListener('click', function(e) {
            e.stopPropagation();
        });
    }

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            suggestionsBox.innerHTML = '';
            suggestionsBox.classList.remove('active');
        }
    });


    document.querySelectorAll('#statutSelect, #roleSelect, #sortBySelect, #sortOrderSelect').forEach(select => {
        select.addEventListener('change', function() {
            filterForm.submit();
        });
    });
    
    console.log('🚀 Script de suggestions chargé avec succès');
</script>

</body>
</html>
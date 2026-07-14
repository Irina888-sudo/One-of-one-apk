<%@ page import="java.util.*" %>
<%@ page import="dao.LivraisonDAO" %>
<%@ page import="model.Livraison" %>

<%
    LivraisonDAO dao = new LivraisonDAO();

    List<Livraison> livraisons = dao.getAllLivraisons();
    List<String> lieux = dao.getAllLieux();
    List<String> livreurs = dao.getAllLivreurs();

    String statut = request.getParameter("statut");
    String lieu = request.getParameter("lieu");
    String date = request.getParameter("date");
    String livreur = request.getParameter("livreur");
    String search = request.getParameter("search");

    List<Livraison> filtered = new ArrayList<>();

    for (Livraison liv : livraisons) {

        boolean okStatut =
            (statut == null || statut.isEmpty() ||
            (liv.getStatut() != null && liv.getStatut().equalsIgnoreCase(statut)));

        boolean okLieu =
            (lieu == null || lieu.isEmpty() ||
            (liv.getLieu() != null && liv.getLieu().trim().equalsIgnoreCase(lieu.trim())));

        boolean okDate =
            (date == null || date.isEmpty() ||
            (liv.getDateLivraison() != null &&
            String.valueOf(liv.getDateLivraison()).startsWith(date)));

        boolean okLivreur =
        (livreur == null || livreur.isEmpty() ||
        (liv.getLivreur() != null &&
        liv.getLivreur().equalsIgnoreCase(livreur)));

        boolean okSearch =
            (search == null || search.isEmpty() ||
            (liv.getNumero() != null && liv.getNumero().toLowerCase().contains(search.toLowerCase())) ||
            (liv.getLieu() != null && liv.getLieu().toLowerCase().contains(search.toLowerCase())) ||
            (liv.getLivreur() != null && liv.getLivreur().toLowerCase().contains(search.toLowerCase())) ||
            (String.valueOf(liv.getCommandeId()) != null && String.valueOf(liv.getCommandeId()).contains(search)) ||
            (liv.getStatut() != null && liv.getStatut().toLowerCase().contains(search.toLowerCase())));

        if (okStatut && okLieu && okDate && okLivreur && okSearch) {
            filtered.add(liv);
        }
    }

    int itemsPerPage = 10;
    int totalItems = filtered.size();
    int totalPages = (int) Math.ceil((double) totalItems / itemsPerPage);
    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        try { currentPage = Integer.parseInt(pageParam); } catch (NumberFormatException ignored) {}
    }
    if (currentPage < 1) currentPage = 1;
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
    int start = (currentPage - 1) * itemsPerPage;
    int end = Math.min(start + itemsPerPage, totalItems);
    List<Livraison> livraisonsPage = new ArrayList<>();
    for (int i = start; i < end; i++) {
        livraisonsPage.add(filtered.get(i));
    }

    String queryParams = "";
    if (statut != null && !statut.isEmpty()) queryParams += "&statut=" + statut;
    if (lieu != null && !lieu.isEmpty()) queryParams += "&lieu=" + java.net.URLEncoder.encode(lieu, "UTF-8");
    if (date != null && !date.isEmpty()) queryParams += "&date=" + date;
    if (livreur != null && !livreur.isEmpty()) queryParams += "&livreur=" + java.net.URLEncoder.encode(livreur, "UTF-8");
    if (search != null && !search.isEmpty()) queryParams += "&search=" + java.net.URLEncoder.encode(search, "UTF-8");
%>
<%
    String deleteId = request.getParameter("delete");

    if (deleteId != null) {
        new dao.LivraisonDAO().delete(Integer.parseInt(deleteId));
        response.sendRedirect("livraison-list.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>One of One - Livraisons</title>
    <link rel="stylesheet" href="../../css/livraisons/livraisons.css">
</head>
<body>
<div class="app-container livraison-page">
    <%@ include file="/jsp/nav/navbar.jsp" %>

    <!-- Contenu principal -->
    <div class="main-content">
         <%@ include file="/jsp/nav/header.jsp" %>
        <!-- Ligne titre + bouton Ajouter -->
        <div class="header-row">
            <div class="title-section">
                <h1>LIVRAISONS</h1>
                <p>Gerez le flux logistique et suivez vos colis en temps reel.</p>
            </div>
            <a href="livraison-form.jsp">
                <button class="add-btn" type="button">+ Ajouter une livraison</button>
            </a>
        </div>

        <!-- Filtres (RECHERCHE, STATUT, DATE, LIVREUR, LIEU) -->
        <form method="get" class="filters-bar" id="filterForm">
           

            <div class="filter-group">
                <label>STATUT</label>
                <select name="statut" onchange="this.form.submit()">
                    <option value="">Tous les statuts</option>
                    <option value="ATTENTE" <%= "ATTENTE".equals(statut) ? "selected" : "" %>>ATTENTE</option>
                    <option value="EN_COURS" <%= "EN_COURS".equals(statut) ? "selected" : "" %>>EN COURS</option>
                    <option value="LIVRE" <%= "LIVRE".equals(statut) ? "selected" : "" %>>LIVREE</option>
                </select>
            </div>

            <div class="filter-group">
                <label>DATE</label>
                <input type="date" name="date" onchange="this.form.submit()"
                       value="<%= request.getParameter("date") != null ? request.getParameter("date") : "" %>">
            </div>

            <div class="filter-group">
                <label>LIVREUR</label>
                <select name="livreur" onchange="this.form.submit()">
                    <option value="">Tous les livreurs</option>
                    <% for (String l : livreurs) { %>
                        <option value="<%= l %>" <%= (l != null && l.equals(livreur)) ? "selected" : "" %>><%= l %></option>
                    <% } %>
                </select>
            </div>

            <div class="filter-group">
                <label>LIEU</label>
                <select name="lieu" onchange="this.form.submit()">
                    <option value="">Tous les lieux</option>
                    <% for (String l : lieux) { %>
                        <option value="<%= l %>" <%= (l != null && l.equals(lieu)) ? "selected" : "" %>><%= l %></option>
                    <% } %>
                </select>
            </div>
        </form>

        <!-- Tableau des livraisons -->
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>N° LIVRAISON</th>
                        <th>N° COMMANDE</th>
                        <th>LIEU</th>
                        <th>FRAIS</th>
                        <th>STATUT</th>
                        <th>ACTIONS</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for (Livraison l : livraisonsPage) {
                            String statutClass = "";
                            String statutLabel = l.getStatut();
                            if ("LIVRE".equalsIgnoreCase(l.getStatut())) {
                                statutClass = "statut-livre";
                                statutLabel = "LIVRe";
                            } else if ("EN_COURS".equalsIgnoreCase(l.getStatut())) {
                                statutClass = "statut-en-cours";
                                statutLabel = "EN COURS";
                            } else if ("ATTENTE".equalsIgnoreCase(l.getStatut())) {
                                statutClass = "statut-attente";
                                statutLabel = "ATTENTE";
                            }
                    %>
                    <tr>
                        <td><%= l.getNumero() %></td>
                        <td><%= l.getCommandeId() %></td>
                        <td>
                            <span class="loc-icon" style="display:inline-flex;align-items:center;gap:6px;">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:inherit;"><path stroke-linecap="round" stroke-linejoin="round" d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 1118 0z"/><circle cx="12" cy="10" r="2"/></svg>
                                <span><%= l.getLieu() %></span>
                            </span>
                        </td>
                        <td><%= String.format("%.0f", l.getFrais()) %> Ariary</td>
                        <td><span class="statut-badge <%= statutClass %>"> <%= statutLabel %></span></td>
                        <td class="actions">
                            <a href="livraison-form.jsp?id=<%= l.getId() %>" class="btn-icon edit" title="Modifier">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:inherit;"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                            </a>
                            <a href="livraison-list.jsp?delete=<%= l.getId() %>" class="btn-icon del" title="Supprimer" onclick="return confirm('Supprimer cette livraison ?');">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:inherit;"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6m5 0V4h4v2"/></svg>
                            </a>
                        </td>
                    </tr>
                    <%
                        }
                        if (filtered.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="6" style="text-align:center; padding: 40px;">Aucune livraison trouvee</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <% if (totalPages > 1) { %>
            <div class="pagination">
                <% if (currentPage > 1) { %>
                    <a href="livraison-list.jsp?page=<%= currentPage - 1 %><%= queryParams %>">&laquo; Precedent</a>
                <% } %>
                
                <% 
                int startPage = Math.max(1, currentPage - 2);
                int endPage = Math.min(totalPages, currentPage + 2);
                
                if (startPage > 1) { %>
                    <a href="livraison-list.jsp?page=1<%= queryParams %>">1</a>
                    <% if (startPage > 2) { %>
                        <span>...</span>
                    <% } %>
                <% } %>
                
                <% for(int i = startPage; i <= endPage; i++) { %>
                    <% if (i == currentPage) { %>
                        <span class="active"><%= i %></span>
                    <% } else { %>
                        <a href="livraison-list.jsp?page=<%= i %><%= queryParams %>"><%= i %></a>
                    <% } %>
                <% } %>
                
                <% if (endPage < totalPages) { %>
                    <% if (endPage < totalPages - 1) { %>
                        <span>...</span>
                    <% } %>
                    <a href="livraison-list.jsp?page=<%= totalPages %><%= queryParams %>"><%= totalPages %></a>
                <% } %>
                
                <% if (currentPage < totalPages) { %>
                    <a href="livraison-list.jsp?page=<%= currentPage + 1 %><%= queryParams %>">Suivant &raquo;</a>
                <% } %>
            </div>
        <% } %>

    </div>
</div>
</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.ProduitDAO, dao.CollectionDAO" %>
<%@ page import="model.Produit, model.Collection" %>
<%@ page import="java.util.List" %>

<%
    // ── Recuperation des filtres ───────────────────────────
    String recherche   = request.getParameter("recherche");
    String filtreCat   = request.getParameter("categorie");
    String filtreStatut= request.getParameter("statut");
    String filtreCol   = request.getParameter("collection");
    String filtreTaille= request.getParameter("taille");
    String filtreCouleur = request.getParameter("couleur");

    ProduitDAO dao       = new ProduitDAO();
    CollectionDAO colDao = new CollectionDAO();

    List<Produit>    produits    = dao.lister(recherche, filtreCat, filtreStatut, filtreCol, filtreTaille, filtreCouleur);
    List<String>     categories  = dao.getCategories();
    List<String>     tailles     = dao.getTailles();
    List<String>     couleurs    = dao.getCouleurs();
    List<Collection> collections = colDao.listerActives();

    int totalProduits   = dao.compterTotal();
    int totalDisponibles= dao.compterParStatut("DISPONIBLE");
    int totalVendus     = dao.compterParStatut("VENDU");

    // ── Pagination ─────────────────────────────────────────
    int produitsParPage = 10;
    int totalProduitsFiltres = produits.size();
    int totalPages = (int) Math.ceil((double) totalProduitsFiltres / produitsParPage);

    int pageCourante = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        try {
            pageCourante = Integer.parseInt(pageParam);
        } catch(NumberFormatException e) {
        }
    }
    if (pageCourante < 1) pageCourante = 1;
    if (pageCourante > totalPages && totalPages > 0) pageCourante = totalPages;

    int debut = (pageCourante - 1) * produitsParPage;
    int fin = Math.min(debut + produitsParPage, totalProduitsFiltres);

    String queryParams = "";
    if (recherche != null && !recherche.isBlank()) queryParams += "&recherche=" + java.net.URLEncoder.encode(recherche, "UTF-8");
    if (filtreCat != null && !filtreCat.isBlank()) queryParams += "&categorie=" + java.net.URLEncoder.encode(filtreCat, "UTF-8");
    if (filtreStatut != null && !filtreStatut.isBlank()) queryParams += "&statut=" + java.net.URLEncoder.encode(filtreStatut, "UTF-8");
    if (filtreCol != null && !filtreCol.isBlank()) queryParams += "&collection=" + java.net.URLEncoder.encode(filtreCol, "UTF-8");
    if (filtreTaille != null && !filtreTaille.isBlank()) queryParams += "&taille=" + java.net.URLEncoder.encode(filtreTaille, "UTF-8");
    if (filtreCouleur != null && !filtreCouleur.isBlank()) queryParams += "&couleur=" + java.net.URLEncoder.encode(filtreCouleur, "UTF-8");

    // Message flash (apres ajout/modif/suppression)
    String flash = (String) session.getAttribute("flash");
    String flashType = (String) session.getAttribute("flashType");
    if (flash != null) {
        session.removeAttribute("flash");
        session.removeAttribute("flashType");
    }

%>
<!DOCTYPE html>
<html lang="fr">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Produits – One of One</title>
        <link rel="stylesheet" href="../../css/produits/produits.css">
    </head>
    <body>
        <%@ include file="/jsp/nav/navbar.jsp" %>

        <!-- ════════════════════ MAIN ════════════════════ -->
        <div class="main">
            <%@ include file="/jsp/nav/header.jsp" %>

            <!-- Content -->
            <div class="content">
                <!-- Flash -->
                <%
    if (flash != null) {

%>
                <div class="flash <%= flashType != null ? flashType : "success" %>"><%= flash %></div>
                <% } %>

                <!-- En-tête page -->
                <div class="page-header">
                    <div>
                        <h1>PRODUITS FINIS</h1>
                        <p>Gerez votre catalogue de pieces uniques et editions limitees.</p>
                    </div>
                    <div style="display:flex; gap:10px; flex-wrap:wrap;">
                        <a href="produit-form.jsp" class="btn-primary">+ Ajouter produit</a>
                    </div>
                </div>

                <!-- KPI -->
                <div class="kpi-row">
                    <div class="kpi-card">
                        <div class="label">Total Produits</div>
                        <div class="value"><%= totalProduits %></div>
                    </div>
                    <div class="kpi-card">
                        <div class="label">Disponibles</div>
                        <div class="value green"><%= totalDisponibles %></div>
                    </div>
                    <div class="kpi-card">
                        <div class="label">Vendus</div>
                        <div class="value orange"><%= totalVendus %></div>
                    </div>
                </div>

                <!-- Filtres -->
                <form method="get" action="produits.jsp" class="filters">
                    <div class="filter-group">
                        <label>Categorie</label>
                        <select name="categorie">
                            <option value="">Toutes</option>
                            <%
    for (String cat : categories) {

%>
                            <option value="<%= cat %>" <%= cat.equals(filtreCat) ? "selected" : "" %>><%= cat %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label>Statut</label>
                        <select name="statut">
                            <option value="">Tous</option>
                            <option value="DISPONIBLE" <%= "DISPONIBLE".equals(filtreStatut) ? "selected" : "" %>>Disponible</option>
                            <option value="VENDU"      <%= "VENDU".equals(filtreStatut) ? "selected" : "" %>>Vendu</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label>Collection</label>
                        <select name="collection">
                            <option value="">Toutes</option>
                            <%
    for (Collection col : collections) {

%>
                            <option value="<%= col.getId() %>" <%= String.valueOf(col.getId()).equals(filtreCol) ? "selected" : "" %>><%= col.getNom() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label>Taille</label>
                        <select name="taille">
                            <option value="">S / M / L</option>
                            <%
    for (String t : tailles) {

%>
                            <option value="<%= t %>" <%= t.equals(filtreTaille) ? "selected" : "" %>><%= t %></option>
                            <% } %>
                        </select>
                    </div>
                    <%
    if (recherche != null && !recherche.isBlank()) {

%>
                    <input type="hidden" name="recherche" value="<%= recherche %>">
                    <% } %>
                    <button type="submit" class="btn-filter">Appliquer</button>
                    <a href="produits.jsp" style="align-self:flex-end;font-size:13px;color:var(--text-muted);text-decoration:none;padding:9px 4px;">Reinitialiser</a>
                </form>

                <!-- Table -->
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>PHOTO</th>
                                <th>NOM</th>
                                <th>CATeGORIE</th>
                                <th>PRIX</th>
                                <th>STATUT</th>
                                <th>ACTIONS</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
    if (produits.isEmpty()) {

%>
                            <tr>
                                <td colspan="6">
                                    <div class="empty">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10"/></svg>
                                        <p>Aucun produit trouve.</p>
                                    </div>
                                </td>
                            </tr>
                            <%

    } else {

%>
                            <%
    for (int i = debut;    i < fin;    i++) {
        Produit p = produits.get(i);

%>
                            <tr>
                                <td>
                                    <%
    if (p.getImage() != null && !p.getImage().isBlank()) {

%>
                                    <img src="<%= request.getContextPath() %>/jsp/serve-image.jsp?name=<%= java.net.URLEncoder.encode(p.getImage(), "UTF-8") %>" alt="<%= p.getNom() %>" class="prod-avatar" style="object-fit: cover;">
                                    <%

    } else {

%>
                                    <div class="prod-avatar"><%= p.getInitiales() %></div>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="prod-cell" style="flex-direction:column;align-items:flex-start;gap:2px;">
                                        <div class="prod-name"><%= p.getNom() %></div>
                                        <div class="prod-sku">SKU: <%= p.getSku() %></div>
                                    </div>
                                </td>
                                <td>
                                    <%
    if (p.getCategorie() != null) {

%>
                                    <span class="badge-cat"><%= p.getCategorie() %></span>
                                    <%

    } else {

%><span style="color:var(--text-muted)">—</span><% } %>
                                </td>
                                <td class="prix"><%= String.format("%,.0f Ariary", p.getPrix()) %></td>
                                <td>
                                    <span class="statut <%= p.getStatut() %>">
                                        <%= "DISPONIBLE".equals(p.getStatut()) ? "Disponible" : "Vendu" %>
                                    </span>
                                </td>
                                <td>
                                    <div class="actions">
                                        <a href="produit-form.jsp?id=<%= p.getId() %>" class="btn-icon edit" title="Modifier">
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                        </a>
                                        <a href="produit-supprimer.jsp?id=<%= p.getId() %>"
                                           onclick="return confirm('Supprimer ce produit ?')"
                                           class="btn-icon del" title="Supprimer">
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6m5 0V4h4v2"/></svg>
                                        </a>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <% if (totalPages > 1) { %>
            <div class="pagination">
                <% if (pageCourante > 1) { %>
                    <a href="produits.jsp?page=<%= pageCourante - 1 %><%= queryParams %>">&laquo; Precedent</a>
                <% } %>
                
                <% 
                int startPage = Math.max(1, pageCourante - 2);
                int endPage = Math.min(totalPages, pageCourante + 2);
                
                if (startPage > 1) { %>
                    <a href="produits.jsp?page=1<%= queryParams %>">1</a>
                    <% if (startPage > 2) { %>
                        <span>...</span>
                    <% } %>
                <% } %>
                
                <% for(int pIdx = startPage; pIdx <= endPage; pIdx++) { %>
                    <% if (pIdx == pageCourante) { %>
                        <span class="active"><%= pIdx %></span>
                    <% } else { %>
                        <a href="produits.jsp?page=<%= pIdx %><%= queryParams %>"><%= pIdx %></a>
                    <% } %>
                <% } %>
                
                <% if (endPage < totalPages) { %>
                    <% if (endPage < totalPages - 1) { %>
                        <span>...</span>
                    <% } %>
                    <a href="produits.jsp?page=<%= totalPages %><%= queryParams %>"><%= totalPages %></a>
                <% } %>
                
                <% if (pageCourante < totalPages) { %>
                    <a href="produits.jsp?page=<%= pageCourante + 1 %><%= queryParams %>">Suivant &raquo;</a>
                <% } %>
            </div>
            <% } %>

        <p class="pagination-info">
            Affichage de <%= (totalProduitsFiltres == 0 ? 0 : debut + 1) %> à <%= fin %> sur <%= totalProduitsFiltres %> produit(s)
        </p>

        </div><!-- /content -->
        </div><!-- /main -->

    </body>
</html>

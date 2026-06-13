<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.ProduitDAO, dao.CollectionDAO" %>
<%@ page import="model.Produit, model.Collection" %>
<%@ page import="java.util.List" %>

<%
    // ── Récupération des filtres ───────────────────────────
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

    // Message flash (après ajout/modif/suppression)
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
        <link rel="stylesheet" href="css/style.css">
    </head>
    <style>
        /* ── Couleurs de la charte One of One ── */
        :root {
            --sidebar-bg : #1a3631;
            --sidebar-active: #e8820c;
            --accent-teal : #3ecfb2;
            --accent-orange: #e8820c;
            --bg-main : #f5f0ea;
            --bg-card : #ffffff;
            --text-dark : #1a1a1a;
            --text-muted : #888;
            --status-ok   : #3ecfb2;
            --status-warn : #e8820c;
            --status-error: #e05c5c;
            --border : #e8e3dc;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { display: flex; font-family: 'Inter', sans-serif; background: var(--bg-main); color: var(--text-dark); min-height: 100vh; }

        /* ── Sidebar ── */
        .sidebar { width: 210px; background: var(--sidebar-bg); color: #fff; display: flex; flex-direction: column; padding: 24px 0; flex-shrink: 0; min-height: 100vh; }
        .sidebar .brand { padding: 0 20px 24px; }
        .sidebar .brand h1 { font-size: 18px; font-weight: 700; color: #fff; }
        .sidebar .brand p  { font-size: 11px; color: #7ca89c; margin-top: 2px; }
        .sidebar nav a { display: flex; align-items: center; gap: 10px; padding: 11px 20px; color: #b0ccc6; text-decoration: none; font-size: 14px; transition: background .15s; }
        .sidebar nav a:hover { background: rgba(255,255,255,.07); color: #fff; }
        .sidebar nav a.active { background: var(--accent-orange); color: #fff; border-radius: 0; }
        .sidebar nav a svg { width: 18px; height: 18px; flex-shrink: 0; }
        .sidebar .new-entry { margin: auto 12px 0; background: var(--accent-teal); color: #fff; border: none; border-radius: 8px; padding: 12px; font-size: 14px; font-weight: 600; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 6px; text-decoration: none; }

        /* ── Main ── */
        .main { flex: 1; display: flex; flex-direction: column; }
        .topbar { background: #fff; padding: 14px 28px; display: flex; align-items: center; gap: 16px; border-bottom: 1px solid var(--border); }
        .topbar input.search { flex: 1; max-width: 480px; border: 1px solid var(--border); border-radius: 8px; padding: 9px 14px 9px 36px; font-size: 14px; background: #f9f7f4 url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='%23aaa' viewBox='0 0 16 16'%3E%3Cpath d='M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398l3.85 3.85a1 1 0 0 0 1.415-1.415l-3.868-3.833zm-5.242 1.156a5.5 5.5 0 1 1 0-11 5.5 5.5 0 0 1 0 11z'/%3E%3C/svg%3E") no-repeat 12px center; outline: none; }
        .topbar input.search:focus { border-color: var(--accent-teal); }
        .topbar .user { margin-left: auto; font-size: 13px; color: var(--text-muted); display: flex; align-items: center; gap: 8px; }
        .topbar .user .avatar { width: 34px; height: 34px; border-radius: 50%; background: var(--accent-teal); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 13px; }

        /* ── Content ── */
        .content { padding: 28px 32px; flex: 1; }
        .page-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 24px; }
        .page-header h2 { font-size: 26px; font-weight: 800; letter-spacing: -.5px; }
        .page-header p  { color: var(--text-muted); font-size: 13px; margin-top: 4px; }
        .btn-primary { background: var(--accent-orange); color: #fff; border: none; border-radius: 8px; padding: 11px 18px; font-size: 14px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; text-decoration: none; white-space: nowrap; }
        .btn-primary:hover { opacity: .9; }

        /* ── KPI cards ── */
        .kpi-row { display: flex; gap: 16px; margin-bottom: 24px; }
        .kpi-card { background: #fff; border-radius: 12px; padding: 18px 22px; flex: 1; border: 1px solid var(--border); }
        .kpi-card .label { font-size: 12px; color: var(--text-muted); margin-bottom: 6px; }
        .kpi-card .value { font-size: 28px; font-weight: 800; }
        .kpi-card .value.green  { color: var(--status-ok); }
        .kpi-card .value.orange { color: var(--accent-orange); }

        /* ── Filtres ── */
        .filters { background: #fff; border-radius: 12px; border: 1px solid var(--border); padding: 16px 20px; display: flex; flex-wrap: wrap; gap: 12px; align-items: flex-end; margin-bottom: 20px; }
        .filter-group { display: flex; flex-direction: column; gap: 4px; }
        .filter-group label { font-size: 11px; color: var(--text-muted); font-weight: 600; text-transform: uppercase; letter-spacing: .5px; }
        .filter-group select,
        .filter-group input  { border: 1px solid var(--border); border-radius: 7px; padding: 8px 10px; font-size: 13px; background: #faf9f7; outline: none; min-width: 140px; }
        .filter-group select:focus,
        .filter-group input:focus { border-color: var(--accent-teal); }
        .btn-filter { background: var(--accent-teal); color: #fff; border: none; border-radius: 7px; padding: 9px 18px; font-size: 13px; font-weight: 600; cursor: pointer; align-self: flex-end; }

        /* ── Couleur dots ── */
        .color-dot { display: inline-block; width: 18px; height: 18px; border-radius: 50%; border: 2px solid #fff; box-shadow: 0 0 0 1px #ccc; vertical-align: middle; margin-right: 4px; }

        /* ── Table ── */
        .table-wrap { background: #fff; border-radius: 12px; border: 1px solid var(--border); overflow: hidden; }
        .table-wrap table { width: 100%; border-collapse: collapse; }
        .table-wrap thead th { padding: 13px 16px; text-align: left; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; color: var(--text-muted); background: #faf9f6; border-bottom: 1px solid var(--border); }
        .table-wrap tbody tr { border-bottom: 1px solid var(--border); transition: background .12s; }
        .table-wrap tbody tr:last-child { border-bottom: none; }
        .table-wrap tbody tr:hover { background: #f9f7f4; }
        .table-wrap td { padding: 14px 16px; font-size: 14px; vertical-align: middle; }

        /* ── Produit nom+sku ── */
        .prod-cell { display: flex; align-items: center; gap: 12px; }
        .prod-avatar { width: 42px; height: 42px; border-radius: 8px; background: var(--sidebar-bg); color: var(--accent-teal); display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px; flex-shrink: 0; }
        .prod-name { font-weight: 600; font-size: 14px; }
        .prod-sku  { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

        /* ── Badge catégorie ── */
        .badge-cat { background: #f0ede8; border-radius: 20px; padding: 3px 10px; font-size: 12px; color: #555; }

        /* ── Prix ── */
        .prix { font-weight: 700; color: var(--accent-teal); }

        /* ── Statut ── */
        .statut { display: inline-flex; align-items: center; gap: 5px; font-size: 12px; font-weight: 600; padding: 4px 10px; border-radius: 20px; }
        .statut.DISPONIBLE { background: #e6f9f5; color: #1db899; }
        .statut.VENDU      { background: #fde8e8; color: #d94f4f; }
        .statut::before { content: ''; width: 7px; height: 7px; border-radius: 50%; background: currentColor; }

        /* ── Actions ── */
        .actions { display: flex; gap: 8px; }
        .btn-icon { border: none; background: none; cursor: pointer; padding: 6px; border-radius: 6px; transition: background .15s; }
        .btn-icon:hover { background: #f0ede8; }
        .btn-icon.edit svg  { color: var(--accent-orange); }
        .btn-icon.del  svg  { color: var(--status-error); }

        /* ── Empty state ── */
        .empty { text-align: center; padding: 60px 20px; color: var(--text-muted); }
        .empty svg { width: 48px; height: 48px; margin-bottom: 12px; opacity: .4; }

        /* ── Flash message ── */
        .flash { border-radius: 8px; padding: 12px 18px; margin-bottom: 20px; font-size: 14px; font-weight: 500; }
        .flash.success { background: #e6f9f5; color: #1db899; border: 1px solid #b0eada; }
        .flash.error   { background: #fde8e8; color: #d94f4f; border: 1px solid #f5c0c0; }
    </style>
    <body>

        <!-- ════════════════════ MAIN ════════════════════ -->
        <div class="main">
            <!-- Topbar -->
            <div class="topbar">
                <form method="get" action="produits.jsp" style="display:flex;gap:8px;flex:1;max-width:500px;">
                    <input class="search" type="text" name="recherche" placeholder="Rechercher un produit..."
                    value="<%= recherche != null ? recherche : "" %>">
                    <!-- conserver les autres filtres -->
                    <%
    if (filtreCat    != null) {

%><input type="hidden" name="categorie"   value="<%= filtreCat %>"><% } %>
                    <%
    if (filtreStatut != null) {

%><input type="hidden" name="statut"      value="<%= filtreStatut %>"><% } %>
                    <%
    if (filtreCol    != null) {

%><input type="hidden" name="collection"  value="<%= filtreCol %>"><% } %>
                    <%
    if (filtreTaille != null) {

%><input type="hidden" name="taille"      value="<%= filtreTaille %>"><% } %>
                </form>
                <div class="user">
                    <%
    String userNom = (session.getAttribute("userNom") != null) ? (String) session.getAttribute("userNom") : "Admin";
    String userRole = (session.getAttribute("userRole") != null) ? (String) session.getAttribute("userRole") : "";
    String initAdmin = userNom.length() >= 2 ? userNom.substring(0,2).toUpperCase() : userNom.toUpperCase();

%>
                    <div>
                        <div style="font-weight:600;font-size:13px;text-align:right;"><%= userNom %></div>
                        <div style="font-size:11px;color:var(--text-muted);text-align:right;"><%= userRole %></div>
                    </div>
                    <div class="avatar"><%= initAdmin %></div>
                </div>
            </div>

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
                        <h2>PRODUITS FINIS</h2>
                        <p>Gérez votre catalogue de pièces uniques et éditions limitées.</p>
                    </div>
                    <a href="produit-form.jsp" class="btn-primary">+ Ajouter produit</a>
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
                        <label>Catégorie</label>
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
                    <a href="produits.jsp" style="align-self:flex-end;font-size:13px;color:var(--text-muted);text-decoration:none;padding:9px 4px;">Réinitialiser</a>
                </form>

                <!-- Table -->
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>PHOTO</th>
                                <th>NOM</th>
                                <th>CATÉGORIE</th>
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
                                        <p>Aucun produit trouvé.</p>
                                    </div>
                                </td>
                            </tr>
                            <%

    } else {

%>
                            <%
    for (Produit p : produits) {

%>
                            <tr>
                                <td>
                                    <%
    if (p.getImage() != null && !p.getImage().isBlank()) {

%>
                                    <img src="<%= request.getContextPath() %>/assets/img/<%= p.getImage() %>" alt="<%= p.getNom() %>" class="prod-avatar" style="object-fit: cover;">
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
                                <td class="prix"><%= String.format("%,.2f", p.getPrix()) %> €</td>
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
                                        onclick="return confirm('Supprimer <%= p.getNom().replace("'","\'") %> ?')"
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
            </div><!-- /content -->
            </div><!-- /main -->

        </body>
    </html>

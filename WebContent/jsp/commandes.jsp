<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.CommandeDAO" %>
<%@ page import="model.Commande" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.SQLException" %>
<%
    // if (session.getAttribute("userEmail") == null) {
    //     response.sendRedirect("login.jsp");
    //     return;
    // }

    String userNom = (String) session.getAttribute("userNom");
    String userRole = (String) session.getAttribute("userRole");
    String userInitials = (String) session.getAttribute("userInitials");
    if (userNom == null) userNom = "Admin";
    if (userRole == null) userRole = "SUPER ADMIN";
    if (userInitials == null) userInitials = "AD";

    String recherche = request.getParameter("recherche");
    String filtreStatut = request.getParameter("statut");
    String filtreClient = request.getParameter("client");

    CommandeDAO dao = new CommandeDAO();
    List<Commande> commandes = null;
    List<String> clients = new java.util.ArrayList<>();
    String dbError = null;

    try {
        commandes = dao.lister(recherche, filtreStatut, filtreClient);
        List<model.Client> clientList = dao.getClients();
        for (model.Client c : clientList) {
            clients.add(c.getId() + ":" + c.getNom());
        }
    } catch (SQLException e) {
        commandes = new java.util.ArrayList<>();
        dbError = e.getMessage();
    }

    String flash = (String) session.getAttribute("flash");
    String flashType = (String) session.getAttribute("flashType");
    session.removeAttribute("flash");
    session.removeAttribute("flashType");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Commandes – One of One</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root { --sidebar-bg:#1a3631; --sidebar-active:#e8820c; --accent-teal:#3ecfb2; --accent-orange:#e8820c; --bg-main:#f5f0ea; --bg-card:#ffffff; --text-dark:#111111; --text-muted:#76716a; --border:#e6e1d9; --status-error:#e05c5c; }
        * { box-sizing:border-box; margin:0; padding:0; }
        body { display:flex; font-family:'Inter',sans-serif; background:var(--bg-main); color:var(--text-dark); min-height:100vh; }
        .sidebar { width:240px; background:var(--sidebar-bg); color:#fff; display:flex; flex-direction:column; padding:24px 0; min-height:100vh; }
        .sidebar .brand { padding:0 24px 28px; border-bottom:1px solid rgba(255,255,255,.08); margin-bottom:16px; }
        .sidebar .brand h1 { font-size:18px; font-weight:800; letter-spacing:2px; text-transform:uppercase; }
        .sidebar .brand p { font-size:11px; color:#7ca89c; margin-top:2px; letter-spacing:1px; text-transform:uppercase; }
        .sidebar nav { display:flex; flex-direction:column; gap:2px; }
        .sidebar nav a { display:flex; align-items:center; gap:12px; padding:12px 24px; color:#b0ccc6; text-decoration:none; font-size:14px; font-weight:500; transition:all .2s ease; }
        .sidebar nav a svg { width:18px; height:18px; flex-shrink:0; opacity:.85; }
        .sidebar nav a:hover { background:rgba(255,255,255,.05); color:#fff; }
        .sidebar nav a.active { background:var(--sidebar-active); color:#fff; font-weight:600; }
        .sidebar .new-entry { margin:auto 16px 0; background:var(--accent-teal); color:#1a3631; border:none; border-radius:8px; padding:12px; font-size:13px; font-weight:700; text-decoration:none; display:flex; align-items:center; justify-content:center; gap:8px; transition:all .2s ease; text-transform:uppercase; letter-spacing:.5px; }
        .sidebar .new-entry:hover { opacity:.9; transform:translateY(-1px); }
        .main { flex:1; display:flex; flex-direction:column; }
        .topbar { background:#fff; padding:16px 32px; display:flex; align-items:center; gap:20px; border-bottom:1px solid var(--border); }
        .topbar .search-form { width:100%; max-width:480px; }
        .topbar input.search { width:100%; border:1px solid var(--border); border-radius:8px; padding:10px 14px 10px 38px; font-size:14px; background:#f9f7f4 url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='%23aaa' viewBox='0 0 16 16'%3E%3Cpath d='M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398l3.85 3.85a1 1 0 0 0 1.415-1.415l-3.868-3.833zm-5.242 1.156a5.5 5.5 0 1 1 0-11 5.5 5.5 0 0 1 0 11z'/%3E%3C/svg%3E") no-repeat 14px center; outline:none; }
        .topbar .user { margin-left:auto; font-size:13px; display:flex; align-items:center; gap:12px; }
        .topbar .user-name { font-weight:600; font-size:14px; }
        .topbar .user-role { font-size:11px; color:var(--text-muted); text-transform:uppercase; letter-spacing:.5px; }
        .topbar .avatar { width:38px; height:38px; border-radius:50%; background:var(--accent-teal); color:#1a3631; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:14px; border:2px solid #fff; box-shadow:0 2px 8px rgba(0,0,0,.1); }
        .content { padding:28px 32px; flex:1; }
        .page-header { display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:24px; }
        .page-header h2 { font-size:26px; font-weight:800; letter-spacing:-.5px; }
        .page-header p { color:var(--text-muted); font-size:13px; margin-top:4px; }
        .btn-primary { background:var(--accent-orange); color:#fff; border:none; border-radius:8px; padding:11px 18px; font-size:14px; font-weight:600; text-decoration:none; display:inline-flex; align-items:center; gap:6px; }
        .btn-primary:hover { opacity:.9; }
        .filters { background:#fff; border-radius:12px; border:1px solid var(--border); padding:16px 20px; display:flex; flex-wrap:wrap; gap:12px; align-items:flex-end; margin-bottom:20px; }
        .filter-group { display:flex; flex-direction:column; gap:4px; }
        .filter-group label { font-size:11px; color:var(--text-muted); font-weight:600; text-transform:uppercase; letter-spacing:.5px; }
        .filter-group select { border:1px solid var(--border); border-radius:7px; padding:8px 10px; font-size:13px; background:#faf9f7; outline:none; min-width:150px; }
        .filter-group select:focus { border-color:var(--accent-teal); }
        .btn-filter { background:#e6f9f5; color:var(--sidebar-bg); border:1px solid var(--accent-teal); border-radius:7px; padding:8px 16px; font-size:13px; font-weight:600; text-decoration:none; }
        .btn-filter:hover { background:var(--accent-teal); color:#1a3631; }
        .table-wrap { background:#fff; border-radius:12px; border:1px solid var(--border); overflow:hidden; box-shadow:0 4px 12px rgba(0,0,0,.02); }
        table { width:100%; border-collapse:collapse; }
        th, td { padding:14px 16px; text-align:left; font-size:14px; }
        thead th { background:#faf9f6; border-bottom:1px solid var(--border); color:var(--text-muted); font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.5px; }
        tbody tr { border-bottom:1px solid var(--border); transition:background .12s; }
        tbody tr:hover { background:#f9f7f4; }
        tbody tr:last-child { border-bottom:none; }
        .commande-num { font-weight:500; color:var(--text-muted); }
        .statut { display:inline-flex; align-items:center; gap:5px; font-size:12px; font-weight:600; padding:4px 10px; border-radius:20px; text-transform:uppercase; }
        .statut.ATTENTE { background:#f0ede8; color:var(--text-muted); }
        .statut.PRODUCTION { background:#fff3e6; color:var(--accent-orange); }
        .statut.LIVREE { background:#e6f9f5; color:#1db899; }
        .statut.ANNULEE { background:#fde8e8; color:var(--status-error); }
        .actions { display:flex; gap:8px; }
        .btn-icon { border:none; background:none; cursor:pointer; padding:6px; border-radius:6px; transition:background .15s; }
        .btn-icon:hover { background:#f0ede8; }
        .btn-icon.edit svg { color:var(--accent-orange); }
        .btn-icon.del svg { color:var(--status-error); }
        .flash { border-radius:8px; padding:12px 18px; margin-bottom:20px; font-size:14px; font-weight:500; }
        .flash.success { background:#e6f9f5; color:#1db899; border:1px solid #b0eada; }
        .flash.error { background:#fde8e8; color:#d94f4f; border:1px solid #f5c0c0; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="brand"><h1>One of One</h1><p>Management Suite</p></div>
        <nav>
            <a href="home.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg> Home
            </a>
            <a href="stock.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10"/></svg> Stock
            </a>
            <a href="produits.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg> Produits
            </a>
            <a href="commandes.jsp" class="active">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7h18M7 7v10m10-10v10m-5 0h4a2 2 0 002-2v-4a2 2 0 00-2-2h-4a2 2 0 00-2 2v4a2 2 0 002 2z"/></svg> Commandes
            </a>
            <a href="livraisons.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10M13 16h3.586a1 1 0 00.707-.293l2.414-2.414a1 1 0 00.293-.707V11h-7M13 16H9m4 0V9"/></svg> Livraisons
            </a>
            <a href="#">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/></svg> Clients
            </a>
            <a href="#">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg> Employés
            </a>
            <a href="#">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg> Finances
            </a>
            <a href="#">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/></svg> Salaires
            </a>
            <a href="#">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg> Graphiques
            </a>
            <a href="#">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z"/></svg> IA
            </a>
            <a href="home.jsp?logout=true" style="margin-top:10px;color:#f5c0c0;">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                Déconnexion
            </a>
        </nav>
        <a href="commande-form.jsp" class="new-entry">+ New Entry</a>
    </div>
    <div class="main">
        <div class="topbar">
            <form action="commandes.jsp" method="get" class="search-form">
                <input class="search" type="text" name="recherche" placeholder="Rechercher une commande ou un client..." value="<%= recherche != null ? recherche : "" %>">
            </form>
            <div class="user">
                <div class="user-info"><div class="user-name"><%= userNom %></div><div class="user-role"><%= userRole %></div></div>
                <div class="avatar"><%= userInitials %></div>
            </div>
        </div>
        <div class="content">
            <% if (dbError != null) { %>
                <div class="flash error"><strong>Erreur DB :</strong> <%= dbError %></div>
            <% } %>
            <% if (flash != null) { %>
                <div class="flash <%= flashType != null ? flashType : "success" %>"><%= flash %></div>
            <% } %>
            <div class="page-header">
                <div><h2>COMMANDES</h2><p>Gérez les commandes clients avec suivi de statut et montant total.</p></div>
                <a href="commande-form.jsp" class="btn-primary">+ Nouvelle commande</a>
            </div>
            <form action="commandes.jsp" method="get" class="filters">
                <% if (recherche != null && !recherche.isBlank()) { %><input type="hidden" name="recherche" value="<%= recherche %>"><% } %>
                <div class="filter-group"><label for="statut">Statut</label><select name="statut" id="statut" onchange="this.form.submit()"><option value="">Tous</option><option value="ATTENTE" <%= "ATTENTE".equals(filtreStatut) ? "selected" : "" %>>En attente</option><option value="PRODUCTION" <%= "PRODUCTION".equals(filtreStatut) ? "selected" : "" %>>En production</option><option value="LIVREE" <%= "LIVREE".equals(filtreStatut) ? "selected" : "" %>>Livrée</option><option value="ANNULEE" <%= "ANNULEE".equals(filtreStatut) ? "selected" : "" %>>Annulée</option></select></div>
                <div class="filter-group"><label for="client">Client</label><select name="client" id="client" onchange="this.form.submit()"><option value="">Tous</option><% for (String c : clients) { String[] parts = c.split(":", 2); %><option value="<%= parts[0] %>" <%= parts[0].equals(filtreClient) ? "selected" : "" %>><%= parts[1] %></option><% } %></select></div>
                <a href="commandes.jsp" class="btn-filter">Réinitialiser</a>
            </form>
            <div class="table-wrap">
                <% if (commandes.isEmpty()) { %>
                    <div class="flash error">Aucune commande trouvée.</div>
                <% } else { %>
                <table>
                    <thead>
                        <tr><th>N° Commande</th><th>Client</th><th>Date</th><th>Montant</th><th>Statut</th><th>Produits</th><th>Actions</th></tr>
                    </thead>
                    <tbody>
                        <% for (Commande c : commandes) { %>
                        <tr>
                            <td><span class="commande-num">#<%= c.getNumero() %></span></td>
                            <td><%= c.getClientNom() != null ? c.getClientNom() : "-" %></td>
                            <td><%= c.getDateCommande() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(c.getDateCommande()) : "-" %></td>
                            <td><%= String.format("%,.2f €", c.getMontantTotal()) %></td>
                            <td><span class="statut <%= c.getStatut() %>"><%= c.getStatutAffichage() %></span></td>
                            <td><%= c.getProduits() != null ? c.getProduits() : "-" %></td>
                            <td><div class="actions"><a href="commande-form.jsp?id=<%= c.getId() %>" class="btn-icon edit" title="Modifier"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 113 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg></a><a href="commande-supprimer.jsp?id=<%= c.getId() %>" class="btn-icon del" title="Supprimer" onclick="return confirm('Supprimer cette commande ?')"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg></a></div></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>
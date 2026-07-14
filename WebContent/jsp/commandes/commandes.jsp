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
    String dateDebut = request.getParameter("dateDebut");
    String dateFin = request.getParameter("dateFin");

    CommandeDAO dao = new CommandeDAO();
    List<Commande> commandes = null;
    List<String> clients = new java.util.ArrayList<>();
    String dbError = null;

    try {
        commandes = dao.lister(recherche, filtreStatut, filtreClient);
        List<model.Client> clientList = dao.getClients();
        if ((dateDebut != null && !dateDebut.isBlank()) || (dateFin != null && !dateFin.isBlank())) {
            List<Commande> commandesFiltres = new java.util.ArrayList<>();
            for (Commande c : commandes) {
                if (c.getDateCommande() == null) continue;
                java.sql.Date dateCommande = new java.sql.Date(c.getDateCommande().getTime());
                boolean ok = true;
                if (dateDebut != null && !dateDebut.isBlank()) {
                    ok = !dateCommande.before(java.sql.Date.valueOf(dateDebut));
                }
                if (ok && dateFin != null && !dateFin.isBlank()) {
                    ok = !dateCommande.after(java.sql.Date.valueOf(dateFin));
                }
                if (ok) commandesFiltres.add(c);
            }
            commandes = commandesFiltres;
        }
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

    int commandesParPage = 10;
    int totalCommandes = commandes.size();
    int totalPages = (int) Math.ceil((double) totalCommandes / commandesParPage);
    int pageCourante = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        try { pageCourante = Integer.parseInt(pageParam); } catch (NumberFormatException ignored) {}
    }
    if (pageCourante < 1) pageCourante = 1;
    if (pageCourante > totalPages && totalPages > 0) pageCourante = totalPages;
    int debut = (pageCourante - 1) * commandesParPage;
    int fin = Math.min(debut + commandesParPage, totalCommandes);
    List<Commande> commandesPage = new java.util.ArrayList<>();
    for (int i = debut; i < fin; i++) {
        commandesPage.add(commandes.get(i));
    }
    String queryParams = "";
    if (recherche != null && !recherche.isBlank()) queryParams += "&recherche=" + java.net.URLEncoder.encode(recherche, "UTF-8");
    if (filtreStatut != null && !filtreStatut.isBlank()) queryParams += "&statut=" + filtreStatut;
    if (filtreClient != null && !filtreClient.isBlank()) queryParams += "&client=" + filtreClient;
    if (dateDebut != null && !dateDebut.isBlank()) queryParams += "&dateDebut=" + dateDebut;
    if (dateFin != null && !dateFin.isBlank()) queryParams += "&dateFin=" + dateFin;
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Commandes – One of One</title>
    <link rel="stylesheet" href="../../css/commandes/commandes.css">
    
</head>
<body>
    <%@ include file="/jsp/nav/navbar.jsp" %>
   
    <div class="main">
        <%@ include file="/jsp/nav/header.jsp" %>
        <div class="content">
            <% if (dbError != null) { %>
                <div class="flash error"><strong>Erreur DB :</strong> <%= dbError %></div>
            <% } %>
            <% if (flash != null) { %>
                <div class="flash <%= flashType != null ? flashType : "success" %>"><%= flash %></div>
            <% } %>
            <div class="page-header">
                <div><h1>COMMANDES</h1><p>Gerez les commandes clients avec suivi de statut et montant total.</p></div>
                <a href="commande-form.jsp" class="btn-primary">+ Nouvelle commande</a>
            </div>
            <form action="commandes.jsp" method="get" class="filters">
                <% if (recherche != null && !recherche.isBlank()) { %><input type="hidden" name="recherche" value="<%= recherche %>"><% } %>
                <div class="filter-group"><label for="statut">Statut</label><select name="statut" id="statut"><option value="">Tous</option><option value="ATTENTE" <%= "ATTENTE".equals(filtreStatut) ? "selected" : "" %>>En attente</option><option value="PRODUCTION" <%= "PRODUCTION".equals(filtreStatut) ? "selected" : "" %>>En production</option><option value="LIVREE" <%= "LIVREE".equals(filtreStatut) ? "selected" : "" %>>Livree</option><option value="ANNULEE" <%= "ANNULEE".equals(filtreStatut) ? "selected" : "" %>>Annulee</option></select></div>
                <div class="filter-group"><label for="client">Client</label><select name="client" id="client"><option value="">Tous</option><% for (String c : clients) { String[] parts = c.split(":", 2); %><option value="<%= parts[0] %>" <%= parts[0].equals(filtreClient) ? "selected" : "" %>><%= parts[1] %></option><% } %></select></div>
                <div class="filter-group"><label for="dateDebut">Du</label><input type="date" name="dateDebut" id="dateDebut" value="<%= dateDebut != null ? dateDebut : "" %>"></div>
                <div class="filter-group"><label for="dateFin">Au</label><input type="date" name="dateFin" id="dateFin" value="<%= dateFin != null ? dateFin : "" %>"></div>
                <button type="submit" class="btn-filter">Appliquer</button>
                <a href="commandes.jsp" class="btn-filter">Reinitialiser</a>
            </form>
            <div class="table-wrap">
                <% if (commandes.isEmpty()) { %>
                    <div class="flash error">Aucune commande trouvee.</div>
                <% } else { %>
                <table>
                    <thead>
                        <tr><th>N° Commande</th><th>Client</th><th>Date</th><th>Montant</th><th>Statut</th><th>Produits</th><th>Actions</th></tr>
                    </thead>
                    <tbody>
                        <% for (Commande c : commandesPage) { %>
                        <tr>
                            <td><span class="commande-num">#<%= c.getNumero() %></span></td>
                            <td><%= c.getClientNom() != null ? c.getClientNom() : "-" %></td>
                            <td><%= c.getDateCommande() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(c.getDateCommande()) : "-" %></td>
                            <td><%= String.format("%,.0f Ariary", c.getMontantTotal()) %></td>
                            <td><span class="statut <%= c.getStatut() %>"><%= c.getStatutAffichage() %></span></td>
                            <td><%= c.getProduits() != null ? c.getProduits() : "-" %></td>
                            <td>
                                <div class="actions">
                                    <a href="commande-form.jsp?id=<%= c.getId() %>" class="btn-icon edit" title="Modifier">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                    </a>
                                    <a href="commande-supprimer.jsp?id=<%= c.getId() %>" class="btn-icon del" title="Supprimer" onclick="return confirm('Supprimer cette commande ?')">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6m5 0V4h4v2"/></svg>
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
            <% if (totalPages > 1) { %>
            <div class="pagination">
                <% if (pageCourante > 1) { %>
                    <a href="commandes.jsp?page=<%= pageCourante - 1 %><%= queryParams %>">&laquo; Precedent</a>
                <% } %>
                
                <% 
                int startPage = Math.max(1, pageCourante - 2);
                int endPage = Math.min(totalPages, pageCourante + 2);
                
                if (startPage > 1) { %>
                    <a href="commandes.jsp?page=1<%= queryParams %>">1</a>
                    <% if (startPage > 2) { %>
                        <span>...</span>
                    <% } %>
                <% } %>
                
                <% for(int p = startPage; p <= endPage; p++) { %>
                    <% if (p == pageCourante) { %>
                        <span class="active"><%= p %></span>
                    <% } else { %>
                        <a href="commandes.jsp?page=<%= p %><%= queryParams %>"><%= p %></a>
                    <% } %>
                <% } %>
                
                <% if (endPage < totalPages) { %>
                    <% if (endPage < totalPages - 1) { %>
                        <span>...</span>
                    <% } %>
                    <a href="commandes.jsp?page=<%= totalPages %><%= queryParams %>"><%= totalPages %></a>
                <% } %>
                
                <% if (pageCourante < totalPages) { %>
                    <a href="commandes.jsp?page=<%= pageCourante + 1 %><%= queryParams %>">Suivant &raquo;</a>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>
</body>
</html>
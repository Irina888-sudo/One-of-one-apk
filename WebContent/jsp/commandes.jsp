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
    <link rel="stylesheet" href="../css/commandes.css">
    
</head>
<body>
    <%@ include file="nav/navbar.jsp" %>
   
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
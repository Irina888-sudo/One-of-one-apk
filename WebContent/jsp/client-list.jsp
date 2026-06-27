<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.ClientDAO" %>
<%@ page import="model.Client" %>
<%@ page import="java.util.ArrayList" %>

<%
    // ── PROTECTION DE PAGE : vérifier que l'utilisateur est connecté ──────
    // (session_check.jsp sera inclus par B2 — pour l'instant on simule)
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // ── LECTURE DU PARAMÈTRE DE FILTRE (ACTIF / BLOQUE / tous) ───────────
    // request.getParameter() retourne null si le paramètre n'existe pas dans l'URL
    String filtreStatut = request.getParameter("statut");
    if (filtreStatut == null) {
        filtreStatut = "tous";   // valeur par défaut : afficher tout le monde
    }

    // ── GESTION DE LA SUPPRESSION ─────────────────────────────────────────
    // Si l'URL contient ?action=supprimer&id=X → on supprime le client X
    String action = request.getParameter("action");
    String messageRetour = "";   // message de confirmation ou d'erreur

    if ("supprimer".equals(action)) {
        int idASupprimer = Integer.parseInt(request.getParameter("id"));
        ClientDAO daoTemp = new ClientDAO();
        boolean ok = daoTemp.supprimer(idASupprimer);
        messageRetour = ok ? "✅ Client supprimé avec succès." : "❌ Erreur lors de la suppression.";
    }

    // ── RÉCUPÉRER LA LISTE DES CLIENTS SELON LE FILTRE ───────────────────
    ClientDAO clientDAO = new ClientDAO();
    ArrayList<Client> listeClients;   // ArrayList castée → règle du projet respectée

    if ("ACTIF".equals(filtreStatut) || "BLOQUE".equals(filtreStatut)) {
        listeClients = clientDAO.listerParStatut(filtreStatut);
    } else {
        listeClients = clientDAO.listerTous();
    }

    // ── PAGINATION : 10 clients par page ──────────────────────────────────
    int clientsParPage = 10;
    int totalClients   = listeClients.size();
    int totalPages     = (int) Math.ceil((double) totalClients / clientsParPage);

    // lire le numéro de page depuis l'URL (?page=2), par défaut page 1
    int pageCourante = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        pageCourante = Integer.parseInt(pageParam);
    }
    // sécurité : rester dans les bornes valides
    if (pageCourante < 1)           pageCourante = 1;
    if (pageCourante > totalPages && totalPages > 0) pageCourante = totalPages;

    // calculer les index de début et fin pour la page courante
    int debut = (pageCourante - 1) * clientsParPage;
    int fin   = Math.min(debut + clientsParPage, totalClients);
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>One of One — Clients</title>
    <link rel="stylesheet" href="../css/global.css">
    <link rel="stylesheet" href="../css/client.css">
</head>
<body>

<%-- ── SIDEBAR (navigation) ── sera stylée par B1 ──────────────────────── --%>
<div class="sidebar">
    <div class="sidebar-logo">
        <h2>One of One</h2>
        <small>Management Suite</small>
    </div>
    <nav>
        <a href="dashboard-admin.jsp">🏠 Home</a>
        <a href="stock-list.jsp">📦 Stock</a>
        <a href="produit-list.jsp">🛍 Produits</a>
        <a href="commande-list.jsp">🛒 Commandes</a>
        <a href="livraison-list.jsp">🚚 Livraisons</a>
        <a href="client-list.jsp" class="active">👥 Clients</a>
        <a href="finance-list.jsp">💰 Finances</a>
        <a href="salaire-list.jsp">💳 Salaires</a>
        <a href="graphiques.jsp">📊 Graphiques</a>
        <a href="ia.jsp">🤖 IA</a>
        <a href="notification-list.jsp">🔔 Notifs</a>
    </nav>
    <a href="logout.jsp" class="sidebar-logout">Se déconnecter</a>
</div>

<%-- ── CONTENU PRINCIPAL ──────────────────────────────────────────────── --%>
<div class="main-content">

    <%-- Titre de la page --%>
    <div class="page-header">
        <div>
            <h1>CLIENTS</h1>
            <p>Visualisez et gérez votre base de données clients.</p>
        </div>
        <%-- Bouton pour ouvrir le popup d'ajout --%>
        <a href="client-form.jsp" class="btn-primary">👤+ Ajouter client</a>
    </div>

    <%-- Message de confirmation / erreur après suppression --%>
    <% if (!messageRetour.isEmpty()) { %>
        <div class="message-info"><%= messageRetour %></div>
    <% } %>

    <%-- ── BARRE DE FILTRES PAR STATUT ── --%>
    <div class="filtres">
        <a href="client-list.jsp?statut=tous"
           class="btn-filtre <%= "tous".equals(filtreStatut) ? "actif" : "" %>">
            Tous (<%=totalClients %>)
        </a>
        <a href="client-list.jsp?statut=ACTIF"
           class="btn-filtre <%= "ACTIF".equals(filtreStatut) ? "actif" : "" %>">
            Actifs
        </a>
        <a href="client-list.jsp?statut=BLOQUE"
           class="btn-filtre <%= "BLOQUE".equals(filtreStatut) ? "actif" : "" %>">
            Bloqués
        </a>
    </div>

    <%-- ── TABLEAU DES CLIENTS ── --%>
    <div class="table-container">
        <table class="table">
            <thead>
                <tr>
                    <th>Client</th>
                    <th>Téléphone</th>
                    <th>Adresse</th>
                    <th>Statut</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    // Afficher uniquement les clients de la page courante
                    if (totalClients == 0) {
                %>
                    <tr>
                        <td colspan="5" style="text-align:center;">Aucun client trouvé.</td>
                    </tr>
                <%
                    } else {
                        for (int i = debut; i < fin; i++) {
                            Client c = listeClients.get(i);

                            // Générer les initiales pour l'avatar (ex: "Jean Dupont" → "JD")
                            String[] mots = c.getNom().trim().split(" ");
                            String initiales = "";
                            for (String mot : mots) {
                                if (!mot.isEmpty()) initiales += mot.charAt(0);
                            }
                            initiales = initiales.toUpperCase();
                            if (initiales.length() > 2) initiales = initiales.substring(0, 2);

                            // Choisir la classe CSS du badge selon le statut
                            String badgeClasse = "ACTIF".equals(c.getStatut()) ? "badge-actif" : "badge-bloque";
                %>
                    <tr>
                        <%-- Avatar avec initiales + nom + email --%>
                        <td>
                            <div class="client-profil">
                                <div class="avatar"><%= initiales %></div>
                                <div>
                                    <strong><%= c.getNom() %></strong><br>
                                    <small><%= c.getEmail() != null ? c.getEmail() : "" %></small>
                                </div>
                            </div>
                        </td>
                        <td><%= c.getTelephone() != null ? c.getTelephone() : "—" %></td>
                        <td><%= c.getAdresse()   != null ? c.getAdresse()   : "—" %></td>
                        <td><span class="badge <%= badgeClasse %>"><%= c.getStatut() %></span></td>
                        <td>
                            <%-- Bouton modifier : envoie vers client-form.jsp avec l'id --%>
                            <a href="client-form.jsp?id=<%= c.getId() %>" class="btn-action" title="Modifier">✏️</a>
                            <%-- Bouton supprimer : recharge la même page avec action=supprimer --%>
                            <a href="client-list.jsp?action=supprimer&id=<%= c.getId() %>&statut=<%= filtreStatut %>"
                               class="btn-action btn-danger"
                               title="Supprimer"
                               onclick="return confirm('Supprimer ce client ?');">🗑️</a>
                        </td>
                    </tr>
                <%
                        }
                    }
                %>
            </tbody>
        </table>
    </div>

    <%-- ── PAGINATION ── --%>
    <% if (totalPages > 1) { %>
    <div class="pagination">
        <%-- Bouton Précédent --%>
        <% if (pageCourante > 1) { %>
            <a href="client-list.jsp?statut=<%= filtreStatut %>&page=<%= pageCourante - 1 %>" class="btn-page">◀ Précédent</a>
        <% } %>

        <%-- Numéros de pages --%>
        <% for (int p = 1; p <= totalPages; p++) { %>
            <a href="client-list.jsp?statut=<%= filtreStatut %>&page=<%= p %>"
               class="btn-page <%= p == pageCourante ? "btn-page-actif" : "" %>">
                <%= p %>
            </a>
        <% } %>

        <%-- Bouton Suivant --%>
        <% if (pageCourante < totalPages) { %>
            <a href="client-list.jsp?statut=<%= filtreStatut %>&page=<%= pageCourante + 1 %>" class="btn-page">Suivant ▶</a>
        <% } %>
    </div>
    <% } %>

    <%-- Résumé : "Affichage de X à Y sur Z clients" --%>
    <p class="pagination-info">
        Affichage de <%= (totalClients == 0 ? 0 : debut + 1) %> à <%= fin %> sur <%= totalClients %> client(s)
    </p>

</div><%-- fin main-content --%>

</body>
</html>

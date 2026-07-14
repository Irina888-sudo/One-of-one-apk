<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/jsp/auth/check-auth.jsp" %>
<%@ page import="dao.ClientDAO" %>
<%@ page import="model.Client" %>
<%@ page import="java.util.ArrayList" %>

<%
    // ── PROTECTION DE PAGE : verifier que l'utilisateur est connecte ──────
    // (session_check.jsp sera inclus par B2 — pour l'instant on simule)
    //if (session.getAttribute("userId") == null) {
    //    response.sendRedirect("login.jsp");
    //    return;
    //}

    String recherche = request.getParameter("q");
    if (recherche != null) {
        recherche = recherche.trim();
    }

    String filtreStatut = request.getParameter("statut");
    if (filtreStatut == null) {
        filtreStatut = "tous";
    }

    // ── GESTION DE LA SUPPRESSION ─────────────────────────────────────────
    // Si l'URL contient ?action=supprimer&id=X → on supprime le client X
    String action = request.getParameter("action");
    String messageRetour = "";   // message de confirmation ou d'erreur

    String flashMessage = (String) session.getAttribute("flashMessage");
    if (flashMessage != null) {
        messageRetour = flashMessage;
        session.removeAttribute("flashMessage");
    }

    if ("supprimer".equals(action)) {
        try {
            int idASupprimer = Integer.parseInt(request.getParameter("id"));
            ClientDAO daoTemp = new ClientDAO();
            boolean ok = daoTemp.supprimer(idASupprimer);
            messageRetour = ok ? "✅ Client supprime avec succes." : "❌ Impossible de supprimer ce client : des commandes sont deja liees.";
        } catch (NumberFormatException e) {
            messageRetour = "❌ Identifiant client invalide.";
        }
    }

    // ── ReCUPeRER LA LISTE DES CLIENTS SELON LE FILTRE ───────────────────
    ClientDAO clientDAO = new ClientDAO();
    ArrayList<Client> listeClients = clientDAO.listerTous();

    if (recherche != null && !recherche.isEmpty()) {
        ArrayList<Client> clientsFiltres = new ArrayList<Client>();
        for (Client c : listeClients) {
            String texte = (c.getNom() + " " + c.getEmail() + " " + c.getTelephone() + " " + c.getAdresse()).toLowerCase();
            if (texte.contains(recherche.toLowerCase())) {
                clientsFiltres.add(c);
            }
        }
        listeClients = clientsFiltres;
    }

    // ── PAGINATION : 10 clients par page ──────────────────────────────────
    int clientsParPage = 10;
    int totalClients   = listeClients.size();
    int totalPages     = (int) Math.ceil((double) totalClients / clientsParPage);

    // lire le numero de page depuis l'URL (?page=2), par defaut page 1
    int pageCourante = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        pageCourante = Integer.parseInt(pageParam);
    }
    // securite : rester dans les bornes valides
    if (pageCourante < 1)           pageCourante = 1;
    if (pageCourante > totalPages && totalPages > 0) pageCourante = totalPages;

    // calculer les index de debut et fin pour la page courante
    int debut = (pageCourante - 1) * clientsParPage;
    int fin   = Math.min(debut + clientsParPage, totalClients);
    String rechercheParam = (recherche != null && !recherche.isEmpty()) ? "&q=" + java.net.URLEncoder.encode(recherche, "UTF-8") : "";
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>One of One — Clients</title>
     <link rel="stylesheet" href="../../css/clients/clients.css">
    
</head>
<body style="display: flex; margin: 0; min-height: 100vh;">
<%@ include file="/jsp/nav/navbar.jsp" %>
<div style="flex: 1; display: flex; flex-direction: column;">
<%@ include file="/jsp/nav/header.jsp" %>

<%-- ── CONTENU PRINCIPAL ──────────────────────────────────────────────── --%>
<div class="main-content">

    <%-- Titre de la page --%>
    <div class="page-header">
        <div>
            <h1>CLIENTS</h1>
            <p>Visualisez et gerez votre base de donnees clients.</p>
        </div>
        <%-- Bouton pour ouvrir le popup d'ajout --%>
        <a href="client-form.jsp" class="btn-primary">+ Ajouter client</a>
    </div>

    <%-- Message de confirmation / erreur apres suppression --%>
    <% if (!messageRetour.isEmpty()) { %>
        <div class="message-info"><%= messageRetour %></div>
    <% } %>
    

    <%-- ── TABLEAU DES CLIENTS ── --%>
    <div class="table-container">
        <table class="table">
            <thead>
                <tr>
                    <th>Client</th>
                    <th>Telephone</th>
                    <th>Adresse</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    // Afficher uniquement les clients de la page courante
                    if (totalClients == 0) {
                %>
                    <tr>
                        <td colspan="5" style="text-align:center;">Aucun client trouve.</td>
                    </tr>
                <%
                    } else {
                        for (int i = debut; i < fin; i++) {
                            Client c = listeClients.get(i);

                            // Generer les initiales pour l'avatar (ex: "Jean Dupont" → "JD")
                            String[] mots = c.getNom().trim().split(" ");
                            String initiales = "";
                            for (String mot : mots) {
                                if (!mot.isEmpty()) initiales += mot.charAt(0);
                            }
                            initiales = initiales.toUpperCase();
                            if (initiales.length() > 2) initiales = initiales.substring(0, 2);

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
                        <td>
                            <%-- Bouton modifier : envoie vers client-form.jsp avec l'id --%>
                            <a href="client-form.jsp?id=<%= c.getId() %>" class="btn-icon edit" title="Modifier">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                            </a>
                            <%-- Bouton supprimer : recharge la meme page avec action=supprimer --%>
                            <a href="client-list.jsp?action=supprimer&id=<%= c.getId() %>"
                               class="btn-icon del"
                               title="Supprimer"
                               onclick="return confirm('Supprimer ce client ?');">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6m5 0V4h4v2"/></svg>
                            </a>
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
        <%-- Bouton Precedent --%>
        <% if (pageCourante > 1) { %>
            <a href="client-list.jsp?page=<%= pageCourante - 1 %><%= rechercheParam %>" class="btn-page">◀ Precedent</a>
        <% } %>

        <%-- Numeros de pages --%>
        <% for (int p = 1; p <= totalPages; p++) { %>
            <a href="client-list.jsp?page=<%= p %><%= rechercheParam %>"
               class="btn-page <%= p == pageCourante ? "btn-page-actif" : "" %>">
                <%= p %>
            </a>
        <% } %>

        <%-- Bouton Suivant --%>
        <% if (pageCourante < totalPages) { %>
            <a href="client-list.jsp?page=<%= pageCourante + 1 %><%= rechercheParam %>" class="btn-page">Suivant ▶</a>
        <% } %>
    </div>
    <% } %>

    <%-- Resume : "Affichage de X a Y sur Z clients" --%>
    <p class="pagination-info">
        Affichage de <%= (totalClients == 0 ? 0 : debut + 1) %> a <%= fin %> sur <%= totalClients %> client(s)
    </p>

</div><%-- fin main-content --%>
</div>
</body>
</html>

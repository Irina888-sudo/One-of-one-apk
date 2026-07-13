<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.MatiereDAO" %>
<%@ page import="model.Matiere" %>
<%@ page import="java.util.ArrayList" %>

<%
    String filtreStatut = request.getParameter("statut");
    if (filtreStatut == null) {
        filtreStatut = "tous";
    }

    String recherche = request.getParameter("q");
    if (recherche != null) {
        recherche = recherche.trim();
    }

    String qMin = request.getParameter("qMin");
    String qMax = request.getParameter("qMax");
    if (qMin != null) qMin = qMin.trim();
    if (qMax != null) qMax = qMax.trim();

    String action = request.getParameter("action");
    String messageRetour = "";

    if ("supprimer".equals(action)) {
        int idASupprimer = Integer.parseInt(request.getParameter("id"));
        MatiereDAO daoTemp = new MatiereDAO();
        boolean ok = daoTemp.supprimer(idASupprimer);
        messageRetour = ok ? "✅ Matiere supprimee avec succes." : "❌ Erreur lors de la suppression.";
    }

    String flashMessage = (String) session.getAttribute("flashMessage");
    if (flashMessage != null) {
        messageRetour = flashMessage;
        session.removeAttribute("flashMessage");
    }

    MatiereDAO matiereDAO = new MatiereDAO();
    ArrayList<Matiere> listeMatieres;

    if (recherche != null && !recherche.isEmpty()) {
        listeMatieres = matiereDAO.rechercher(recherche);
    } else if ("ACTIF".equals(filtreStatut) || "INACTIF".equals(filtreStatut)) {
        listeMatieres = matiereDAO.listerParStatut(filtreStatut);
    } else {
        listeMatieres = matiereDAO.listerTous();
    }

    ArrayList<Matiere> matieresFiltres = new ArrayList<Matiere>();
    try {
        int minQuantite = (qMin != null && !qMin.isEmpty()) ? Integer.parseInt(qMin) : Integer.MIN_VALUE;
        int maxQuantite = (qMax != null && !qMax.isEmpty()) ? Integer.parseInt(qMax) : Integer.MAX_VALUE;
        for (Matiere m : listeMatieres) {
            if (m.getQuantite() >= minQuantite && m.getQuantite() <= maxQuantite) {
                matieresFiltres.add(m);
            }
        }
    } catch (NumberFormatException e) {
        matieresFiltres.addAll(listeMatieres);
    }
    listeMatieres = matieresFiltres;

    int matieresParPage = 10;
    int totalMatieres = listeMatieres.size();
    int totalPages = (int) Math.ceil((double) totalMatieres / matieresParPage);
    int pageCourante = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        pageCourante = Integer.parseInt(pageParam);
    }
    if (pageCourante < 1) pageCourante = 1;
    if (pageCourante > totalPages && totalPages > 0) pageCourante = totalPages;
    int debut = (pageCourante - 1) * matieresParPage;
    int fin = Math.min(debut + matieresParPage, totalMatieres);
    String qParam = (recherche != null && !recherche.isEmpty()) ? "&q=" + java.net.URLEncoder.encode(recherche, "UTF-8") : "";
    if (qMin != null && !qMin.isEmpty()) qParam += "&qMin=" + java.net.URLEncoder.encode(qMin, "UTF-8");
    if (qMax != null && !qMax.isEmpty()) qParam += "&qMax=" + java.net.URLEncoder.encode(qMax, "UTF-8");
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>One of One — Matieres</title>
    <link rel="stylesheet" href="../../css/stock/stock.css">
</head>
<body style="display: flex; margin: 0; min-height: 100vh;">

<%@ include file="/jsp/nav/navbar.jsp" %>
<div style="flex: 1; display: flex; flex-direction: column;">
<%@ include file="/jsp/nav/header.jsp" %>

<div class="main-content">
    <div class="page-header">
        <div>
            <h1>STOCK / MATIeRES</h1>
            <p>Gerez les matieres premieres et stocks disponibles.</p>
        </div>
        <a href="stock-form.jsp" class="btn-primary">+ Ajouter matiere</a>
    </div>

    <div class="filtres">
        <a href="stock-list.jsp?statut=tous<%= qParam %>"
           class="btn-filtre <%= "tous".equals(filtreStatut) ? "actif" : "" %>">
            Tous (<%= totalMatieres %>)
        </a>
        <a href="stock-list.jsp?statut=ACTIF<%= qParam %>"
           class="btn-filtre <%= "ACTIF".equals(filtreStatut) ? "actif" : "" %>">
            Actifs
        </a>
        <a href="stock-list.jsp?statut=INACTIF<%= qParam %>"
           class="btn-filtre <%= "INACTIF".equals(filtreStatut) ? "actif" : "" %>">
            Inactifs
        </a>
        <form action="stock-list.jsp" method="GET" class="filtre" >
            <input type="hidden" name="statut" value="<%= filtreStatut %>">
            <input type="number"  name="qMin" placeholder="Min" value=" <%= qMin != null ? qMin : "" %>" style="width:100px;height: 40px; margin-right: 8px;">
            <input type="number"  name="qMax" placeholder="Max" value=" <%= qMax != null ? qMax : "" %>" style="width:100px;height: 40px; margin-right: 8px;">
            <button type="submit" class="btn-primary">Appliquer</button>
        </form>
    </div>

    <% if (!messageRetour.isEmpty()) { %>
        <div class="message-info"><%= messageRetour %></div>
    <% } %>

    <div class="table-container">
        <table class="table">
            <thead>
                <tr>
                    <th>Matiere</th>
                    <th>Description</th>
                    <th>Quantite</th>
                    <th>Unite</th>
                    <th>Statut</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (totalMatieres == 0) { %>
                    <tr>
                        <td colspan="6" style="text-align:center;">Aucune matiere trouvee.</td>
                    </tr>
                <% } else {
                    for (int i = debut; i < fin; i++) {
                        Matiere m = listeMatieres.get(i);
                        String badgeClasse = "ACTIF".equals(m.getStatut()) ? "badge-actif" : "badge-bloque";
                %>
                    <tr>
                        <td><strong><%= m.getNom() %></strong></td>
                        <td><%= m.getDescription() != null ? m.getDescription() : "—" %></td>
                        <td><%= m.getQuantite() %></td>
                        <td><%= m.getUnite() != null ? m.getUnite() : "—" %></td>
                        <td><span class="badge <%= badgeClasse %>"><%= m.getStatut() %></span></td>
                        <td>
                            <a href="stock-form.jsp?id=<%= m.getId() %>" class="btn-action" title="Modifier">✏️</a>
                            <a href="stock-list.jsp?action=supprimer&id=<%= m.getId() %>&statut=<%= filtreStatut %><%= qParam %>"
                               class="btn-action btn-danger"
                               title="Supprimer"
                               onclick="return confirm('Supprimer cette matiere ?');">🗑️</a>
                        </td>
                    </tr>
                <% }
                } %>
            </tbody>
        </table>
    </div>

    <% if (totalPages > 1) { %>
        <div class="pagination">
            <% if (pageCourante > 1) { %>
                <a href="stock-list.jsp?statut=<%= filtreStatut %>&page=<%= pageCourante - 1 %><%= qParam %>" class="btn-page">◀ Precedent</a>
            <% } %>
            <% for (int p = 1; p <= totalPages; p++) { %>
                <a href="stock-list.jsp?statut=<%= filtreStatut %>&page=<%= p %><%= qParam %>"
                   class="btn-page <%= p == pageCourante ? "btn-page-actif" : "" %>">
                    <%= p %>
                </a>
            <% } %>
            <% if (pageCourante < totalPages) { %>
                <a href="stock-list.jsp?statut=<%= filtreStatut %>&page=<%= pageCourante + 1 %><%= qParam %>" class="btn-page">Suivant ▶</a>
            <% } %>
        </div>
    <% } %>

    <p class="pagination-info">
        Affichage de <%= (totalMatieres == 0 ? 0 : debut + 1) %> à <%= fin %> sur <%= totalMatieres %> matiere(s)
    </p>
</div>
</div>
</div>
</body>
</html>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/jsp/auth/check-auth.jsp" %>
<%@ page import="java.util.*, dao.CorbeilleDAO, dao.CorbeilleDAO.CorbeilleEntry" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String section = request.getParameter("section");
    if (section == null || section.isBlank()) {
        section = "all";
    }
    CorbeilleDAO dao = new CorbeilleDAO();
    List<CorbeilleEntry> items = dao.lister(section);
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    String flash = (String) session.getAttribute("flash");
    String flashType = (String) session.getAttribute("flashType");
    session.removeAttribute("flash");
    session.removeAttribute("flashType");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Corbeille - One of One</title>
    <link rel="stylesheet" href="../../css/produits/produits.css">
</head>
<body style="display: flex; margin: 0; min-height: 100vh;">
<%@ include file="/jsp/nav/navbar.jsp" %>
<div style="flex: 1; display: flex; flex-direction: column;">
<%@ include file="/jsp/nav/header.jsp" %>
<div class="main">
    <div class="content">
        <div class="page-header">
            <div>
                <h1>CORBEILLE</h1>
                <p>Les elements supprimes sont ici temporairement.</p>
            </div>
           
        </div>

        <% if (flash != null) { %>
            <div class="flash <%= flashType != null ? flashType : "success" %>"><%= flash %></div>
        <% } %>

        <form method="get" class="filters" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap; margin-bottom:20px;">
            <label for="section">Afficher</label>
            <select id="section" name="section" onchange="this.form.submit()" style="padding: 10px 12px; border: 1px solid #dbe2ea; border-radius: 10px;">
                <option value="all" <%= "all".equals(section) ? "selected" : "" %>>Tous</option>
                <option value="produit" <%= "produit".equals(section) ? "selected" : "" %>>Produits</option>
                <option value="employe" <%= "employe".equals(section) ? "selected" : "" %>>Employes</option>
                <option value="livraison" <%= "livraison".equals(section) ? "selected" : "" %>>Livraisons</option>
                <option value="salaire" <%= "salaire".equals(section) ? "selected" : "" %>>Salaires</option>
                <option value="commande" <%= "commande".equals(section) ? "selected" : "" %>>Commandes</option>
            </select>
        </form>

        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th>Type</th>
                    <th>element</th>
                    <th>Supprime le</th>
                    <th>Action</th>
                </tr>
                </thead>
                <tbody>
                <% if (items == null || items.isEmpty()) { %>
                <tr><td colspan="4" style="text-align:center;">Aucun element dans la corbeille.</td></tr>
                <% } else {
                    for (CorbeilleEntry item : items) {
                %>
                <tr>
                    <td><span class="badge"><%= item.getSectionLabel() %></span></td>
                    <td><strong><%= item.getTitle() != null ? item.getTitle() : "#" + item.getEntityId() %></strong></td>
                    <td><%= sdf.format(item.getDeletedAt()) %></td>
                    <td>
                        <a href="restaurer.jsp?id=<%= item.getId() %>&section=<%= section %>" class="btn-filter">Restaurer</a>
                    </td>
                </tr>
                <% }
                   } %>
                </tbody>
            </table>
        </div>
    </div>
</div>
</div>
</body>
</html>

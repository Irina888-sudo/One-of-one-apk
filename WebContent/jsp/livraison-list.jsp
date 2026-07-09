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

        if (okStatut && okLieu && okDate && okLivreur) {
            filtered.add(liv);
        }
    }
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
    <link rel="stylesheet" href="../css/livraisons.css">
</head>
<body>
<div class="app-container livraison-page">
    <%@ include file="nav/navbar.jsp" %>

    <!-- Contenu principal -->
    <div class="main-content">
         <%@ include file="nav/header.jsp" %>
        <!-- Logo + Barre de recherche côte à côte -->
        <div class="search-header">
            <div class="logo-area">
                <h2>One of One</h2>
            </div>
            <div class="search-wrapper">
                <input type="text" placeholder="Rechercher une livraison..." id="searchInput">
            </div>
        </div>

        <!-- Ligne titre + bouton Ajouter -->
        <div class="header-row">
            <div class="title-section">
                <h1>LIVRAISONS</h1>
                <p>Gérez le flux logistique et suivez vos colis en temps réel.</p>
            </div>
            <a href="livraison-form.jsp">
                <button class="add-btn" type="button">+ Ajouter une livraison</button>
            </a>
        </div>

        <!-- Filtres (STATUT, DATE, LIVREUR, LIEU) -->
        <form method="get" class="filters-bar" id="filterForm">
            <div class="filter-group">
                <label>STATUT</label>
                <select name="statut" onchange="this.form.submit()">
                    <option value="">Tous les statuts</option>
                    <option value="ATTENTE" <%= "ATTENTE".equals(statut) ? "selected" : "" %>>ATTENTE</option>
                    <option value="EN_COURS" <%= "EN_COURS".equals(statut) ? "selected" : "" %>>EN COURS</option>
                    <option value="LIVRE" <%= "LIVRE".equals(statut) ? "selected" : "" %>>LIVRÉ</option>
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
                        for (Livraison l : filtered) {
                            String statutClass = "";
                            String statutLabel = l.getStatut();
                            if ("LIVRE".equalsIgnoreCase(l.getStatut())) {
                                statutClass = "statut-livre";
                                statutLabel = "LIVRÉ";
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
                        <td>📍 <%= l.getLieu() %></td>
                        <td><%= String.format("%.2f", l.getFrais()) %> €</td>
                        <td><span class="statut-badge <%= statutClass %>">● <%= statutLabel %></span></td>
                        <td class="actions">
                            <a href="livraison-form.jsp?id=<%= l.getId() %>">Modifier</a>
                            <a href="livraison-list.jsp?delete=<%= l.getId() %>"
                               onclick="return confirm('Supprimer cette livraison ?');">Supprimer</a>
                        </td>
                    </tr>
                    <%
                        }
                        if (filtered.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="6" style="text-align:center; padding: 40px;">Aucune livraison trouvée</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    // Recherche simple sur le tableau
    const searchInput = document.getElementById('searchInput');
    if(searchInput) {
        searchInput.addEventListener('keyup', function() {
            const filter = this.value.toLowerCase();
            const rows = document.querySelectorAll('table tbody tr');
            rows.forEach(row => {
                if(row.cells && row.cells.length >= 5) {
                    const text = row.innerText.toLowerCase();
                    if(text.includes(filter)) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                }
            });
        });
    }
</script>
</body>
</html>
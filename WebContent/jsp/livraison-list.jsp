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
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
        }

        /* Layout principal avec sidebar à gauche */
        .app-container {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar - sera implémentée plus tard */
        .sidebar {
            width: 260px;
            background-color: #1e293b;
            color: #fff;
        }

        /* Contenu principal */
        .main-content {
            flex: 1;
            padding: 24px 32px;
            background-color: #f8fafc;
        }

        /* Barre de recherche + logo côte à côte */
        .search-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .logo-area h2 {
            font-size: 24px;
            font-weight: 700;
            color: #0f172a;
            letter-spacing: 1px;
        }

        .logo-area p {
            font-size: 12px;
            color: #64748b;
            margin-top: 4px;
        }

        .search-wrapper {
            flex: 1;
            max-width: 400px;
        }

        .search-wrapper input {
            width: 100%;
            padding: 10px 16px;
            border: 1px solid #e2e8f0;
            border-radius: 40px;
            font-size: 14px;
            outline: none;
            background-color: white;
        }

        .search-wrapper input:focus {
            border-color: #94a3b8;
        }

        /* Ligne titre + bouton sur le même niveau */
        .header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .title-section h1 {
            font-size: 28px;
            font-weight: 600;
            color: #0f172a;
            margin-bottom: 4px;
        }

        .title-section p {
            color: #475569;
            font-size: 14px;
        }

        .add-btn {
            background-color: #3b82f6;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 500;
            font-size: 14px;
            cursor: pointer;
            transition: background 0.2s;
            white-space: nowrap;
        }

        .add-btn:hover {
            background-color: #2563eb;
        }

        /* Barre de filtres */
        .filters-bar {
            background-color: white;
            border-radius: 12px;
            padding: 16px 20px;
            margin-bottom: 24px;
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
            align-items: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            border: 1px solid #e2e8f0;
        }

        .filter-group {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .filter-group label {
            font-size: 13px;
            font-weight: 500;
            color: #334155;
        }

        .filter-group select, .filter-group input {
            padding: 8px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            background-color: white;
            font-size: 13px;
            cursor: pointer;
            outline: none;
        }

        .filter-group select:hover, .filter-group input:hover {
            border-color: #94a3b8;
        }

        /* Table */
        .table-container {
            background-color: white;
            border-radius: 16px;
            border: 1px solid #e2e8f0;
            overflow-x: auto;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        th {
            text-align: left;
            padding: 14px 16px;
            background-color: #f8fafc;
            color: #1e293b;
            font-weight: 600;
            border-bottom: 1px solid #e2e8f0;
        }

        td {
            padding: 14px 16px;
            border-bottom: 1px solid #f1f5f9;
            color: #334155;
        }

        tr:hover {
            background-color: #fafcff;
        }

        .statut-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 40px;
            font-size: 12px;
            font-weight: 500;
        }

        .statut-livre {
            background-color: #dcfce7;
            color: #166534;
        }

        .statut-en-cours {
            background-color: #fff3e3;
            color: #9b4a00;
        }

        .statut-attente {
            background-color: #fef9c3;
            color: #854d0e;
        }

        .actions a {
            text-decoration: none;
            color: #3b82f6;
            margin-right: 12px;
            font-size: 13px;
        }

        .actions a:last-child {
            color: #ef4444;
            margin-right: 0;
        }

        .actions a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<div class="app-container">
    <!-- Sidebar (sera ajoutée ultérieurement) -->
    <div class="sidebar">
        <!-- Placeholder pour la navigation latérale -->
    </div>

    <!-- Contenu principal -->
    <div class="main-content">
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
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.CommandeDAO" %>
<%@ page import="dao.ProduitDAO" %>
<%@ page import="model.Commande" %>
<%@ page import="model.Client" %>
<%@ page import="model.LigneCommande" %>
<%@ page import="model.Produit" %>
<%@ page import="java.util.List" %>
<%
    // if (session.getAttribute("userEmail") == null) {
    //     response.sendRedirect("login.jsp");
    //     return;
    // }

    CommandeDAO dao = new CommandeDAO();
    ProduitDAO produitDao = new ProduitDAO();
    String idParam = request.getParameter("id");
    Commande commande = null;
    boolean isEdit = (idParam != null && !idParam.isBlank());

    if (isEdit) {
        try {
            commande = dao.trouverParId(Integer.parseInt(idParam));
        } catch (Exception e) {
            /* ignore */
        }
    }

    if (commande == null) {
        commande = new Commande();
        isEdit = false;
        commande.setNumero("ORD-" + (1000 + new java.util.Random().nextInt(9000)));
        commande.setDateCommande(new java.sql.Timestamp(System.currentTimeMillis()));
    }

    List<Client> clients = dao.getClients();
    List<Produit> produits = null;
    try {
        produits = produitDao.lister(null, null, null, null, null, null);
    } catch (Exception e) {
        produits = new java.util.ArrayList<>();
    }

    String erreur = (String) request.getAttribute("erreur");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title><%= isEdit ? "Modifier la commande" : "Ajouter une commande" %> – One of One</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root { --bg-main:#f5f0ea; --border:#e6e1d9; --accent-teal:#3ecfb2; --accent-orange:#e8820c; --text-dark:#111111; --text-muted:#76716a; }
        * { box-sizing:border-box; margin:0; padding:0; }
        body { font-family:'Inter',sans-serif; background:var(--bg-main); color:var(--text-dark); min-height:100vh; display:flex; align-items:flex-start; justify-content:center; padding:40px 20px; }
        .card { width:100%; max-width:760px; background:#fff; border:1px solid var(--border); border-radius:14px; padding:36px 40px; }
        .card h2 { font-size:24px; font-weight:800; margin-bottom:6px; }
        .card .sub { color:var(--text-muted); font-size:13px; margin-bottom:24px; }
        .form-group { display:flex; flex-direction:column; gap:5px; margin-bottom:18px; }
        .form-group label { font-size:11px; font-weight:700; color:var(--text-muted); text-transform:uppercase; letter-spacing:.5px; }
        .form-group input, .form-group select { border:1px solid var(--border); border-radius:8px; padding:10px 12px; font-size:14px; outline:none; background:#faf9f7; }
        .form-group input:focus, .form-group select:focus { border-color:var(--accent-teal); }
        .row2 { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
        .ligne-table { width:100%; border-collapse:collapse; margin-top:12px; }
        .ligne-table th, .ligne-table td { padding:12px 10px; border:1px solid var(--border); text-align:left; font-size:14px; }
        .ligne-table th { background:#faf9f6; color:var(--text-muted); text-transform:uppercase; letter-spacing:.4px; }
        .btn-row { display:flex; gap:10px; margin-top:22px; }
        .btn-primary { background:var(--accent-orange); color:#fff; border:none; border-radius:8px; padding:12px 24px; font-size:14px; font-weight:700; cursor:pointer; }
        .btn-secondary { background:#f0ede8; color:#555; border:none; border-radius:8px; padding:12px 18px; font-size:14px; font-weight:600; text-decoration:none; display:inline-flex; align-items:center; justify-content:center; }
        .erreur { background:#fde8e8; color:#d94f4f; border:1px solid #f5c0c0; border-radius:8px; padding:12px 16px; font-size:13px; margin-bottom:18px; }
        .action-small { border:none; color:var(--accent-orange); background:none; cursor:pointer; font-weight:700; }
    </style>
    <script>
        function ajouterLigne() {
            const tbody = document.getElementById('lignes-body');
            const index = tbody.children.length;
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>
                    <select name="produitId" class="ligne-produit" required>
                        <option value="">-- Choisir un produit --</option>
                        <% for (Produit p : produits) { %>
                            <option value="<%= p.getId() %>"><%= p.getNom() %> (<%= p.getCategorie() != null ? p.getCategorie() : "Produit" %>)</option>
                        <% } %>
                    </select>
                </td>
                <td><input type="number" name="quantite" value="1" min="1" required></td>
                <td><input type="number" name="prixUnitaire" step="0.01" min="0" value="0.00" required></td>
                <td><button type="button" class="action-small" onclick="supprimerLigne(this)">Supprimer</button></td>
            `;
            tbody.appendChild(row);
        }
        function supprimerLigne(button) { button.closest('tr').remove(); }
    </script>
</head>
<body>
    <div class="card">
        <h2><%= isEdit ? "Modifier la commande" : "Ajouter une commande" %></h2>
        <p class="sub"><%= isEdit ? "Mettez à jour les informations de la commande." : "Créez une nouvelle commande client." %></p>
        <% if (erreur != null) { %>
            <div class="erreur"><%= erreur %></div>
        <% } %>
        <form action="commande-save.jsp" method="post">
            <% if (isEdit) { %><input type="hidden" name="id" value="<%= commande.getId() %>"><% } %>
            <div class="row2">
                <div class="form-group">
                    <label for="numero">N° de commande</label>
                    <input type="text" id="numero" name="numero" value="<%= commande.getNumero() != null ? commande.getNumero() : "" %>" placeholder="ORD-2026-001" required>
                </div>
                <div class="form-group">
                    <label for="clientId">Client</label>
                    <select id="clientId" name="clientId" required>
                        <option value="">-- Choisir un client --</option>
                        <% for (Client client : clients) { %>
                            <option value="<%= client.getId() %>" <%= client.getId() == commande.getClientId() ? "selected" : "" %>><%= client.getNom() %> - <%= client.getEmail() %></option>
                        <% } %>
                    </select>
                </div>
            </div>
            <div class="row2">
                <div class="form-group">
                    <label for="dateCommande">Date de commande</label>
                    <input type="datetime-local" id="dateCommande" name="dateCommande" value="<%= commande.getDateCommande() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(commande.getDateCommande()) : "" %>" required>
                </div>
                <div class="form-group">
                    <label for="statut">Statut</label>
                    <select name="statut" id="statut" required>
                        <option value="ATTENTE" <%= "ATTENTE".equals(commande.getStatut()) ? "selected" : "" %>>En attente</option>
                        <option value="PRODUCTION" <%= "PRODUCTION".equals(commande.getStatut()) ? "selected" : "" %>>En production</option>
                        <option value="LIVREE" <%= "LIVREE".equals(commande.getStatut()) ? "selected" : "" %>>Livrée</option>
                        <option value="ANNULEE" <%= "ANNULEE".equals(commande.getStatut()) ? "selected" : "" %>>Annulée</option>
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label>Lignes de commande</label>
                <table class="ligne-table">
                    <thead>
                        <tr><th>Produit</th><th>Quantité</th><th>Prix unitaire</th><th>Action</th></tr>
                    </thead>
                    <tbody id="lignes-body">
                        <% if (commande.getLignes() != null && !commande.getLignes().isEmpty()) {
                            for (LigneCommande ligne : commande.getLignes()) { %>
                                <tr>
                                    <td>
                                        <select name="produitId" required>
                                            <option value="">-- Choisir un produit --</option>
                                            <% for (Produit p : produits) { %>
                                                <option value="<%= p.getId() %>" <%= p.getId() == ligne.getProduitId() ? "selected" : "" %>><%= p.getNom() %></option>
                                            <% } %>
                                        </select>
                                    </td>
                                    <td><input type="number" name="quantite" min="1" value="<%= ligne.getQuantite() %>" required></td>
                                    <td><input type="number" name="prixUnitaire" step="0.01" min="0" value="<%= ligne.getPrixUnitaire() %>" required></td>
                                    <td><button type="button" class="action-small" onclick="supprimerLigne(this)">Supprimer</button></td>
                                </tr>
                            <% }
                        } else { %>
                            <tr>
                                <td colspan="4" style="text-align:center;color:var(--text-muted);">Ajoutez au moins une ligne de produit.</td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
                <button type="button" class="btn-secondary" onclick="ajouterLigne()">Ajouter un produit</button>
            </div>
            <div class="btn-row">
                <a href="commandes.jsp" class="btn-secondary">Annuler</a>
                <button type="submit" class="btn-primary"><%= isEdit ? "Enregistrer la commande" : "Créer la commande" %></button>
            </div>
        </form>
    </div>
</body>
</html>
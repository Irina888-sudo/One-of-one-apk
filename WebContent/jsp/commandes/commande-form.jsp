<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.CommandeDAO" %>
<%@ page import="dao.ProduitDAO" %>
<%@ page import="model.Commande" %>
<%@ page import="model.Client" %>
<%@ page import="model.LigneCommande" %>
<%@ page import="model.Produit" %>
<%@ page import="java.util.List" %>
<%
    CommandeDAO dao = new CommandeDAO();
    ProduitDAO produitDao = new ProduitDAO();
    String idParam = request.getParameter("id");
    Commande commande = null;
    boolean isEdit = (idParam != null && idParam != null && !idParam.trim().isEmpty());

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
        java.util.Date now = new java.util.Date();
        commande.setDateCommande(new java.sql.Timestamp(now.getTime()));
    }

    if (commande.getLignes() == null) {
        commande.setLignes(new java.util.ArrayList<>());
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
    <link rel="stylesheet" href="../../css/commandes/commandes-form.css">
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
    <%@ include file="/jsp/nav/navbar.jsp" %>

    <div class="main-content">
        <div class="page-header">
            <div>
                <h1><%= isEdit ? "MODIFIER LA COMMANDE" : "AJOUTER UNE COMMANDE" %></h1>
                <p>
                    <a href="commandes.jsp">← Retour à la liste des commandes</a>
                </p>
            </div>
        </div>

        <div class="form-container">
            <% if (erreur != null) { %>
                <div class="message-erreur"><%= erreur %></div>
            <% } %>

            <form class="form" action="commande-save.jsp" method="post">
                <% if (isEdit) { %><input type="hidden" name="id" value="<%= commande.getId() %>"><% } %>

                <div class="form-grid">
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

                <div class="form-grid">
                    <div class="form-group">
                        <label for="dateCommande">Date de commande</label>
                        <input type="datetime-local" id="dateCommande" name="dateCommande" value="<%= commande.getDateCommande() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(commande.getDateCommande()) : "" %>" required>
                    </div>
                    <div class="form-group">
                        <label for="statut">Statut</label>
                        <select name="statut" id="statut" required>
                            <option value="ATTENTE" <%= "ATTENTE".equals(commande.getStatut()) ? "selected" : "" %>>En attente</option>
                            <option value="PRODUCTION" <%= "PRODUCTION".equals(commande.getStatut()) ? "selected" : "" %>>En production</option>
                            <option value="LIVREE" <%= "LIVREE".equals(commande.getStatut()) ? "selected" : "" %>>Livree</option>
                            <option value="ANNULEE" <%= "ANNULEE".equals(commande.getStatut()) ? "selected" : "" %>>Annulee</option>
                        </select>
                    </div>
                </div>

                <div class="form-group lignes-group">
                    <label>Lignes de commande</label>
                    <div class="table-wrapper">
                        <table class="ligne-table">
                            <thead>
                                <tr><th>Produit</th><th>Quantite</th><th>Prix unitaire</th><th>Action</th></tr>
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
                                        <td colspan="4" class="empty-row">Ajoutez au moins une ligne de produit.</td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <button type="button" class="btn-secondary" onclick="ajouterLigne()">Ajouter un produit</button>
                </div>

                <div class="form-actions">
                    <a href="commandes.jsp" class="btn-secondary">Annuler</a>
                    <button type="submit" class="btn-primary"><%= isEdit ? "Enregistrer la commande" : "Creer la commande" %></button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
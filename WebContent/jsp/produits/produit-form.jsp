<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/jsp/auth/check-auth.jsp" %>
<%@ page import="dao.ProduitDAO, dao.CollectionDAO, dao.MatiereDAO" %>
<%@ page import="model.Produit, model.Collection, model.Matiere" %>
<%@ page import="java.util.List" %>
<%!
    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
%>
<%
    ProduitDAO dao = new ProduitDAO();
    CollectionDAO colDao = new CollectionDAO();
    MatiereDAO matDao = new MatiereDAO();

    List<Collection> collections = colDao.listerActives();
    List<Matiere> matieres = matDao.lister();

    String idParam = request.getParameter("id");
    Produit p = null;
    boolean isEdit = !isBlank(idParam);

    List<Matiere> matieresProduit = new java.util.ArrayList<>();
    if (isEdit) {
        try {
            p = dao.trouverParId(Integer.parseInt(idParam));
            if (p != null) {
                matieresProduit = dao.getMatieresParProduit(p.getId());
            }
        } catch (Exception e) {
            /* ignore */
        }
    }
    if (p == null) p = new Produit();

    String titre = isEdit ? "Modifier le produit" : "Ajouter un produit";

    // Recuperer erreur eventuelle
    String erreur = (String) request.getAttribute("erreur");

%>
<!DOCTYPE html>
<html lang="fr">
    <head>
        <meta charset="UTF-8">
        <title><%= titre %> – One of One</title>
        <link rel="stylesheet" href="../../css/produits/produit-form.css">
        <script>
            function updateUnite(selectEl) {
                const selectedOpt = selectEl.options[selectEl.selectedIndex];
                const unite = selectedOpt.getAttribute('data-unite') || '';
                const row = selectEl.closest('tr');
                if (row) {
                    const label = row.querySelector('.unite-label');
                    if (label) label.textContent = unite;
                }
            }

            function ajouterMatiere() {
                const tbody = document.getElementById('matieres-body');
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td style="padding: 8px 4px;">
                        <select name="matiereId" class="select-matiere" style="width: 100%; border: 1px solid var(--border); border-radius: 8px; padding: 10px 12px; font-size: 14px; outline: none; background: #faf9f7;" onchange="updateUnite(this)">
                            <option value="">-- Choisir une matiere --</option>
                            <% for (Matiere m : matieres) { %>
                                <option value="<%= m.getId() %>" data-unite="<%= m.getUnite() != null ? m.getUnite() : "" %>">
                                    <%= m.getNom() %> (Stock: <%= m.getQuantite() %> <%= m.getUnite() != null ? m.getUnite() : "" %>)
                                </option>
                            <% } %>
                        </select>
                    </td>
                    <td style="padding: 8px 4px; display: flex; align-items: center; gap: 4px;">
                        <input type="number" name="quantiteMatiere" step="0.01" min="0" placeholder="0.00" style="width: 100%; border: 1px solid var(--border); border-radius: 8px; padding: 10px 12px; font-size: 14px; outline: none; background: #faf9f7;">
                        <span class="unite-label" style="font-size: 12px; color: var(--text-muted); min-width: 30px;"></span>
                    </td>
                    <td style="padding: 8px 4px; text-align: center;">
                        <button type="button" class="action-small" onclick="supprimerMatiere(this)">Supprimer</button>
                    </td>
                `;
                tbody.appendChild(row);
            }

            function supprimerMatiere(btn) {
                const row = btn.closest('tr');
                if (row) {
                    row.remove();
                }
            }
        </script>
    </head>
   
        <body>
            <%@ include file="/jsp/nav/navbar.jsp" %>
            <div class="page-header">
                <h1><%= titre %></h1>
                <p><%= isEdit ? "Modifiez les informations du produit." : "Remplissez les informations du nouveau produit." %></p>
            </div>

            <div class="form-container">
                <%
        if (erreur != null) {

%>
                <div class="erreur"><%= erreur %></div>
                <% } %>

                <form method="post" action="${pageContext.request.contextPath}/jsp/produits/produit-save.jsp" enctype="multipart/form-data">
                <%
    if (isEdit) {

%>
                <input type="hidden" name="id" value="<%= p.getId() %>">
                <% } %>

                <div class="form-group">
                    <label>Nom du produit *</label>
                    <input type="text" name="nom" required maxlength="100"
                    value="<%= p.getNom() != null ? p.getNom() : "" %>"
                    placeholder="ex : Fauteuil Sculptural Oak">
                </div>

                <div class="row2">
                    <div class="form-group">
                        <label>Categorie</label>
                        <input type="text" name="categorie" maxlength="50"
                        value="<%= p.getCategorie() != null ? p.getCategorie() : "" %>"
                        placeholder="Mobilier, Luminaire…">
                    </div>
                    <div class="form-group">
                        <label>Prix (Ariary) *</label>
                        <input type="number" name="prix" required step="0.01" min="0"
                        value="<%= p.getPrix() > 0 ? p.getPrix() : "" %>"
                        placeholder="0.00">
                    </div>
                </div>

                <div class="row2">
                    <div class="form-group">
                        <label>Taille</label>
                        <input type="text" name="taille" maxlength="20"
                        value="<%= p.getTaille() != null ? p.getTaille() : "" %>"
                        placeholder="S, M, L, XL…">
                    </div>
                    <div class="form-group">
                        <label>Couleur</label>
                        <input type="text" name="couleur" maxlength="30"
                        value="<%= p.getCouleur() != null ? p.getCouleur() : "" %>"
                        placeholder="Noir, Cognac…">
                    </div>
                </div>

                <div class="form-group">
                    <label>Image du produit</label>
                    <%
    if (isEdit && p.getImage() != null && !isBlank(p.getImage())) {

%>
                    <div style="margin-bottom:8px;">
                        <img src="<%= request.getContextPath() %>/jsp/serve-image.jsp?name=<%= java.net.URLEncoder.encode(p.getImage(), "UTF-8") %>" alt="Image actuelle"
                        style="max-width:120px;max-height:120px;border-radius:8px;object-fit:cover;border:1px solid #ddd;">
                        <p style="font-size:11px;color:#888;margin-top:4px;">Image actuelle – choisissez un nouveau fichier pour la remplacer.</p>
                    </div>
                    <input type="hidden" name="image_actuelle" value="<%= p.getImage() %>">
                    <% } %>
                    <input type="file" name="image" accept="image/*">
                </div>

                <div class="row2">
                    <div class="form-group">
                        <label>Statut</label>
                        <select name="statut">
                            <option value="DISPONIBLE" <%= "DISPONIBLE".equals(p.getStatut()) || !isEdit ? "selected" : "" %>>Disponible</option>
                            <option value="VENDU"      <%= "VENDU".equals(p.getStatut()) ? "selected" : "" %>>Vendu</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Collection</label>
                        <select name="collection_id">
                            <option value=""> Aucune </option>
                            <%
    for (Collection col : collections) {
        boolean selected = p.getCollectionId() != null && p.getCollectionId() == col.getId();

%>
                            <option value="<%= col.getId() %>" <%= selected ? "selected" : "" %>><%= col.getNom() %></option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <!-- Section Matieres Premieres -->
                <div class="form-group" style="margin-top: 18px;">
                    <label style="margin-bottom: 8px;">Matieres premieres utilisees</label>
                    
                    <% if (isEdit) { %>
                        <!-- En modification, afficher en lecture seule pour eviter des incoherences de stock -->
                        <% if (matieresProduit != null && !matieresProduit.isEmpty()) { %>
                            <div style="background: #faf9f7; border: 1px solid var(--border); border-radius: 8px; padding: 12px 16px; font-size: 13px;">
                                <ul style="list-style: none; display: flex; flex-direction: column; gap: 6px;">
                                    <% for (Matiere mp : matieresProduit) { %>
                                        <li style="display: flex; justify-content: space-between; align-items: center; padding: 4px 0; border-bottom: 1px solid #f5f0ea;">
                                            <span style="font-weight: 600;"><%= mp.getNom() %></span>
                                            <span style="color: var(--text-muted); font-weight: 500;"><%= mp.getQuantite() %> <%= mp.getUnite() != null ? mp.getUnite() : "" %></span>
                                        </li>
                                    <% } %>
                                </ul>
                            </div>
                        <% } else { %>
                            <p style="font-size: 13px; color: var(--text-muted); font-style: italic;">Aucune matiere associee a ce produit.</p>
                        <% } %>
                    <% } else { %>
                        <!-- En creation, permettre l'ajout dynamique -->
                        <table class="ligne-table" style="margin-bottom: 10px; width: 100%; border-collapse: collapse;">
                            <thead>
                                <tr>
                                    <th style="padding: 8px; font-size: 11px; text-transform: uppercase; color: var(--text-muted); text-align: left; border-bottom: 1px solid var(--border);">Matiere</th>
                                    <th style="padding: 8px; font-size: 11px; text-transform: uppercase; color: var(--text-muted); text-align: left; border-bottom: 1px solid var(--border); width: 150px;">Quantite</th>
                                    <th style="padding: 8px; font-size: 11px; text-transform: uppercase; color: var(--text-muted); text-align: center; border-bottom: 1px solid var(--border); width: 80px;">Action</th>
                                </tr>
                            </thead>
                            <tbody id="matieres-body">
                                <tr>
                                    <td style="padding: 8px 4px;">
                                        <select name="matiereId" class="select-matiere" style="width: 100%; border: 1px solid var(--border); border-radius: 8px; padding: 10px 12px; font-size: 14px; outline: none; background: #faf9f7;" onchange="updateUnite(this)">
                                            <option value=""> Choisir une matiere </option>
                                            <% for (Matiere m : matieres) { %>
                                                <option value="<%= m.getId() %>" data-unite="<%= m.getUnite() != null ? m.getUnite() : "" %>">
                                                    <%= m.getNom() %> (Stock: <%= m.getQuantite() %> <%= m.getUnite() != null ? m.getUnite() : "" %>)
                                                </option>
                                            <% } %>
                                        </select>
                                    </td>
                                    <td style="padding: 8px 4px; display: flex; align-items: center; gap: 4px;">
                                        <input type="number" name="quantiteMatiere" step="0.01" min="0" placeholder="0.00" style="width: 100%; border: 1px solid var(--border); border-radius: 8px; padding: 10px 12px; font-size: 14px; outline: none; background: #faf9f7;">
                                        <span class="unite-label" style="font-size: 12px; color: var(--text-muted); min-width: 30px;"></span>
                                    </td>
                                    <td style="padding: 8px 4px; text-align: center;">
                                        <button type="button" class="action-small" onclick="supprimerMatiere(this)">Supprimer</button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <button type="button" class="btn-secondary" style="padding: 8px 14px; font-size: 12px; align-self: flex-start;" onclick="ajouterMatiere()">+ Ajouter une matiere</button>
                    <% } %>
                </div>

                <div class="btn-row">
                    <a href="produits.jsp" class="btn-secondary">Annuler</a>
                    <button type="submit" class="btn-primary"><%= isEdit ? "Enregistrer" : "Ajouter le produit" %></button>
                </div>
            </form>
        </div>
    </body>
</html>

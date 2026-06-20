<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.ProduitDAO, dao.CollectionDAO, dao.MatiereDAO" %>
<%@ page import="model.Produit, model.Collection, model.Matiere" %>
<%@ page import="java.util.List" %>
<%
    ProduitDAO dao = new ProduitDAO();
    CollectionDAO colDao = new CollectionDAO();
    MatiereDAO matDao = new MatiereDAO();

    List<Collection> collections = colDao.listerActives();
    List<Matiere> matieres = matDao.lister();

    String idParam = request.getParameter("id");
    Produit p = null;
    boolean isEdit = (idParam != null && !idParam.isBlank());

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

    // Récupérer erreur éventuelle
    String erreur = (String) request.getAttribute("erreur");

%>
<!DOCTYPE html>
<html lang="fr">
    <head>
        <meta charset="UTF-8">
        <title><%= titre %> – One of One</title>
        <link rel="stylesheet" href="css/style.css">
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
                            <option value="">-- Choisir une matière --</option>
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
    <style>
        :root {
            --sidebar-bg : #1a3631;
            --accent-teal : #3ecfb2;
            --accent-orange: #e8820c;
            --bg-main : #f5f0ea;
            --border : #e8e3dc;
            --text-muted : #888;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: var(--bg-main); min-height: 100vh; display: flex; align-items: flex-start; justify-content: center; padding: 40px 20px; }
        .card { background: #fff; border-radius: 14px; border: 1px solid var(--border); padding: 36px 40px; width: 100%; max-width: 560px; }
        .card h2 { font-size: 22px; font-weight: 800; margin-bottom: 6px; }
        .card .sub { color: var(--text-muted); font-size: 13px; margin-bottom: 28px; }
        .form-group { display: flex; flex-direction: column; gap: 5px; margin-bottom: 18px; }
        .form-group label { font-size: 12px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: .5px; }
        .form-group input,
        .form-group select { border: 1px solid var(--border); border-radius: 8px; padding: 10px 12px; font-size: 14px; outline: none; background: #faf9f7; transition: border-color .15s; }
        .form-group input:focus,
        .form-group select:focus { border-color: var(--accent-teal); }
        .row2 { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
        .btn-row { display: flex; gap: 10px; margin-top: 8px; }
        .btn-primary { background: var(--accent-orange); color: #fff; border: none; border-radius: 8px; padding: 12px 24px; font-size: 14px; font-weight: 700; cursor: pointer; flex: 1; }
        .btn-primary:hover { opacity: .9; }
        .btn-secondary { background: #f0ede8; color: #555; border: none; border-radius: 8px; padding: 12px 18px; font-size: 14px; font-weight: 600; cursor: pointer; text-decoration: none; display: flex; align-items: center; justify-content: center; }
        .erreur { background: #fde8e8; color: #d94f4f; border: 1px solid #f5c0c0; border-radius: 8px; padding: 12px 16px; font-size: 13px; margin-bottom: 18px; }
        .action-small { border:none; color:var(--accent-orange); background:none; cursor:pointer; font-weight:700; font-size: 12px; }
        .action-small:hover { text-decoration: underline; }
</style>
    <body>
        <div class="card">
            <h2><%= titre %></h2>
            <p class="sub"><%= isEdit ? "Modifiez les informations du produit." : "Remplissez les informations du nouveau produit." %></p>

            <%
    if (erreur != null) {

%>
            <div class="erreur"><%= erreur %></div>
            <% } %>

            <form method="post" action="produit-save.jsp" enctype="multipart/form-data">
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
                        <label>Catégorie</label>
                        <input type="text" name="categorie" maxlength="50"
                        value="<%= p.getCategorie() != null ? p.getCategorie() : "" %>"
                        placeholder="Mobilier, Luminaire…">
                    </div>
                    <div class="form-group">
                        <label>Prix (€) *</label>
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
    if (isEdit && p.getImage() != null && !p.getImage().isBlank()) {

%>
                    <div style="margin-bottom:8px;">
                        <img src="<%= request.getContextPath() %>/assets/img/<%= p.getImage() %>" alt="Image actuelle"
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
                            <option value="">— Aucune —</option>
                            <%
    for (Collection col : collections) {
        boolean selected = p.getCollectionId() != null && p.getCollectionId() == col.getId();

%>
                            <option value="<%= col.getId() %>" <%= selected ? "selected" : "" %>><%= col.getNom() %></option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <!-- Section Matières Premières -->
                <div class="form-group" style="margin-top: 18px;">
                    <label style="margin-bottom: 8px;">Matières premières utilisées</label>
                    
                    <% if (isEdit) { %>
                        <!-- En modification, afficher en lecture seule pour éviter des incohérences de stock -->
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
                            <p style="font-size: 13px; color: var(--text-muted); font-style: italic;">Aucune matière associée à ce produit.</p>
                        <% } %>
                    <% } else { %>
                        <!-- En création, permettre l'ajout dynamique -->
                        <table class="ligne-table" style="margin-bottom: 10px; width: 100%; border-collapse: collapse;">
                            <thead>
                                <tr>
                                    <th style="padding: 8px; font-size: 11px; text-transform: uppercase; color: var(--text-muted); text-align: left; border-bottom: 1px solid var(--border);">Matière</th>
                                    <th style="padding: 8px; font-size: 11px; text-transform: uppercase; color: var(--text-muted); text-align: left; border-bottom: 1px solid var(--border); width: 150px;">Quantité</th>
                                    <th style="padding: 8px; font-size: 11px; text-transform: uppercase; color: var(--text-muted); text-align: center; border-bottom: 1px solid var(--border); width: 80px;">Action</th>
                                </tr>
                            </thead>
                            <tbody id="matieres-body">
                                <tr>
                                    <td style="padding: 8px 4px;">
                                        <select name="matiereId" class="select-matiere" style="width: 100%; border: 1px solid var(--border); border-radius: 8px; padding: 10px 12px; font-size: 14px; outline: none; background: #faf9f7;" onchange="updateUnite(this)">
                                            <option value="">-- Choisir une matière --</option>
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
                        <button type="button" class="btn-secondary" style="padding: 8px 14px; font-size: 12px; align-self: flex-start;" onclick="ajouterMatiere()">+ Ajouter une matière</button>
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

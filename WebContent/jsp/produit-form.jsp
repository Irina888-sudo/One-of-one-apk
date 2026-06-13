<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.ProduitDAO, dao.CollectionDAO" %>
<%@ page import="model.Produit, model.Collection" %>
<%@ page import="java.util.List" %>
<%
    ProduitDAO dao = new ProduitDAO();
    CollectionDAO colDao = new CollectionDAO();
    List<Collection> collections = colDao.listerActives();

    String idParam = request.getParameter("id");
    Produit p = null;
    boolean isEdit = (idParam != null && !idParam.isBlank());

    if (isEdit) {
        try {
            p = dao.trouverParId(Integer.parseInt(idParam));
        } catch (NumberFormatException e) {
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

                <div class="btn-row">
                    <a href="produits.jsp" class="btn-secondary">Annuler</a>
                    <button type="submit" class="btn-primary"><%= isEdit ? "Enregistrer" : "Ajouter le produit" %></button>
                </div>
            </form>
        </div>
    </body>
</html>

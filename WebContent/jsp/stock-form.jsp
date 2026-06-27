<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.MatiereDAO" %>
<%@ page import="model.Matiere" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String idParam = request.getParameter("id");
    boolean modeModification = (idParam != null && !idParam.isEmpty());

    Matiere matiereExistant = null;
    String messageRetour = "";
    String valNom = "";
    String valDescription = "";
    String valQuantite = "0";
    String valUnite = "";

    if (modeModification) {
        int id = Integer.parseInt(idParam);
        MatiereDAO dao = new MatiereDAO();
        matiereExistant = dao.trouverParId(id);
        if (matiereExistant == null) {
            response.sendRedirect("stock-list.jsp");
            return;
        }
        valNom = matiereExistant.getNom() != null ? matiereExistant.getNom() : "";
        valDescription = matiereExistant.getDescription() != null ? matiereExistant.getDescription() : "";
        valQuantite = String.valueOf(matiereExistant.getQuantite());
        valUnite = matiereExistant.getUnite() != null ? matiereExistant.getUnite() : "";
    }

    if ("POST".equals(request.getMethod())) {
        String nom = request.getParameter("nom");
        String description = request.getParameter("description");
        String quantiteTexte = request.getParameter("quantite");
        String unite = request.getParameter("unite");

        valNom = nom != null ? nom.trim() : "";
        valDescription = description != null ? description.trim() : "";
        valQuantite = quantiteTexte != null ? quantiteTexte.trim() : "0";
        valUnite = unite != null ? unite.trim() : "";

        boolean valide = true;
        if (valNom.isEmpty()) {
            messageRetour = "❌ Le nom de la matière est obligatoire.";
            valide = false;
        }

        int quantite = 0;
        try {
            quantite = Integer.parseInt(valQuantite);
            if (quantite < 0) {
                messageRetour = "❌ La quantité doit être zéro ou positive.";
                valide = false;
            }
        } catch (NumberFormatException e) {
            messageRetour = "❌ Quantité invalide.";
            valide = false;
        }

        if (valide) {
            MatiereDAO dao = new MatiereDAO();
            boolean ok;
            if (modeModification) {
                Matiere m = new Matiere();
                m.setId(Integer.parseInt(idParam));
                m.setNom(valNom);
                m.setDescription(valDescription);
                m.setQuantite(quantite);
                m.setUnite(valUnite);
                m.setStatut(matiereExistant != null ? matiereExistant.getStatut() : "ACTIF");
                ok = dao.modifier(m);
                messageRetour = ok ? "✅ Matière modifiée avec succès." : "❌ Erreur lors de la modification.";
            } else {
                Matiere m = new Matiere();
                m.setNom(valNom);
                m.setDescription(valDescription);
                m.setQuantite(quantite);
                m.setUnite(valUnite);
                ok = dao.ajouter(m);
                messageRetour = ok ? "✅ Matière ajoutée avec succès." : "❌ Erreur lors de l'ajout.";
            }
            if (ok) {
                session.setAttribute("flashMessage", messageRetour);
                response.sendRedirect("stock-list.jsp");
                return;
            }
        }
    }

    String titrePage = modeModification ? "Modifier la matière" : "Ajouter une matière";
    String titreBouton = modeModification ? "Enregistrer les modifications" : "Ajouter la matière";
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>One of One — <%= titrePage %></title>
    <link rel="stylesheet" href="../css/global.css">
    <link rel="stylesheet" href="../css/stock.css">
</head>
<body>

<div class="sidebar">
    <div class="sidebar-logo">
        <h2>One of One</h2>
        <small>Management Suite</small>
    </div>
    <nav>
        <a href="dashboard-admin.jsp">🏠 Home</a>
        <a href="stock-list.jsp" class="active">📦 Stock</a>
        <a href="produit-list.jsp">🛍 Produits</a>
        <a href="commande-list.jsp">🛒 Commandes</a>
        <a href="livraison-list.jsp">🚚 Livraisons</a>
        <a href="client-list.jsp">👥 Clients</a>
        <a href="finance-list.jsp">💰 Finances</a>
        <a href="salaire-list.jsp">💳 Salaires</a>
        <a href="graphiques.jsp">📊 Graphiques</a>
        <a href="ia.jsp">🤖 IA</a>
    </nav>
    <a href="logout.jsp" class="sidebar-logout">Se déconnecter</a>
</div>

<div class="main-content">
    <div class="page-header">
        <div>
            <h1><%= titrePage.toUpperCase() %></h1>
            <p><a href="stock-list.jsp">← Retour à la liste des matières</a></p>
        </div>
    </div>

    <% if (!messageRetour.isEmpty()) { %>
        <div class="message-erreur"><%= messageRetour %></div>
    <% } %>

    <div class="form-container">
        <form action="stock-form.jsp<%= modeModification ? "?id=" + idParam : "" %>" method="POST">
            <div class="form-groupe">
                <label for="nom">Nom de la matière <span class="obligatoire">*</span></label>
                <input type="text" id="nom" name="nom" value="<%= valNom %>" placeholder="Ex : Coton" required>
            </div>
            <div class="form-groupe">
                <label for="description">Description</label>
                <textarea id="description" name="description" rows="3" placeholder="Ex : Tissu coton léger"><%= valDescription %></textarea>
            </div>
            <div class="form-groupe">
                <label for="quantite">Quantité</label>
                <input type="number" id="quantite" name="quantite" value="<%= valQuantite %>" min="0">
            </div>
            <div class="form-groupe">
                <label for="unite">Unité</label>
                <input type="text" id="unite" name="unite" value="<%= valUnite %>" placeholder="Ex : mètres">
            </div>
            <div class="form-actions">
                <a href="stock-list.jsp" class="btn-secondaire">Annuler</a>
                <button type="submit" class="btn-primary"><%= titreBouton %></button>
            </div>
        </form>
    </div>
</div>

</body>
</html>

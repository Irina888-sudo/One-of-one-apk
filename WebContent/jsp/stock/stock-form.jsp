<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/jsp/auth/check-auth.jsp" %>
<%@ page import="dao.MatiereDAO" %>
<%@ page import="model.Matiere" %>

<%
    

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
            messageRetour = "❌ Le nom de la matiere est obligatoire.";
            valide = false;
        }

        int quantite = 0;
        try {
            quantite = Integer.parseInt(valQuantite);
            if (quantite < 0) {
                messageRetour = "❌ La quantite doit etre zero ou positive.";
                valide = false;
            }
        } catch (NumberFormatException e) {
            messageRetour = "❌ Quantite invalide.";
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
                messageRetour = ok ? "✅ Matiere modifiee avec succes." : "❌ Erreur lors de la modification.";
            } else {
                Matiere m = new Matiere();
                m.setNom(valNom);
                m.setDescription(valDescription);
                m.setQuantite(quantite);
                m.setUnite(valUnite);
                ok = dao.ajouter(m);
                messageRetour = ok ? "✅ Matiere ajoutee avec succes." : "❌ Erreur lors de l'ajout.";
            }
            if (ok) {
                session.setAttribute("flashMessage", messageRetour);
                response.sendRedirect("stock-list.jsp");
                return;
            }
        }
    }

    String titrePage = modeModification ? "Modifier la matiere" : "Ajouter une matiere";
    String titreBouton = modeModification ? "Enregistrer les modifications" : "Ajouter la matiere";
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>One of One — <%= titrePage %></title>
    <link rel="stylesheet" href="../../css/stock/stock-form.css">
</head>
<body>

    <%@ include file="/jsp/nav/navbar.jsp" %>

<div class="main-content">
    <div class="page-header">
        <div>
            <h1><%= titrePage.toUpperCase() %></h1>
            <p><a href="stock-list.jsp">← Retour a la liste des matieres</a></p>
        </div>
    </div>

    <% if (!messageRetour.isEmpty()) { %>
        <div class="message-erreur"><%= messageRetour %></div>
    <% } %>

    <div class="form-container">
        <form action="stock-form.jsp<%= modeModification ? "?id=" + idParam : "" %>" method="POST">
            <div class="form-groupe">
                <label for="nom">Nom de la matiere <span class="obligatoire">*</span></label>
                <input type="text" id="nom" name="nom" value="<%= valNom %>" placeholder="Ex : Coton" required>
            </div>
            <div class="form-groupe">
                <label for="description">Description</label>
                <textarea id="description" name="description" rows="3" placeholder="Ex : Tissu coton leger"><%= valDescription %></textarea>
            </div>
            <div class="form-groupe">
                <label for="quantite">Quantite</label>
                <input type="number" id="quantite" name="quantite" value="<%= valQuantite %>" min="0">
            </div>
            <div class="form-groupe">
                <label for="unite">Unite</label>
                <input type="text" id="unite" name="unite" value="<%= valUnite %>" placeholder="Ex : metres">
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

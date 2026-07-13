<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.ClientDAO" %>
<%@ page import="model.Client" %>

<%
    // ── PROTECTION DE PAGE ────────────────────────────────────────────────
    

    // ── DeTERMINER LE MODE : AJOUT ou MODIFICATION ────────────────────────
    // Si ?id=X est dans l'URL → mode modification
    // Sinon → mode ajout
    String idParam = request.getParameter("id");
    boolean modeModification = (idParam != null && !idParam.isEmpty());

    Client clientExistant = null;   // sera rempli si mode modification
    String messageRetour  = "";     // message affiche apres soumission du formulaire

    if (modeModification) {
        // Recuperer le client existant pour pre-remplir les champs
        int id = Integer.parseInt(idParam);
        ClientDAO dao = new ClientDAO();
        clientExistant = dao.trouverParId(id);

        if (clientExistant == null) {
            // Si l'ID n'existe pas → retourner à la liste
            response.sendRedirect("client-list.jsp");
            return;
        }
    }

    // ── TRAITEMENT DU FORMULAIRE SOUMIS (methode POST) ───────────────────
    if ("POST".equals(request.getMethod())) {

        // Lire les valeurs saisies dans le formulaire
        String nom       = request.getParameter("nom");
        String email     = request.getParameter("email");
        String telephone = request.getParameter("telephone");
        String adresse   = request.getParameter("adresse");

        // Validation basique : le nom est obligatoire
        if (nom == null || nom.trim().isEmpty()) {
            messageRetour = "❌ Le nom du client est obligatoire.";
        } else {
            ClientDAO dao = new ClientDAO();
            boolean ok;

            if (modeModification) {
                // Mode modification → UPDATE dans la BDD
                Client clientModifie = new Client();
                clientModifie.setId(Integer.parseInt(idParam));
                clientModifie.setNom(nom.trim());
                clientModifie.setEmail(email != null ? email.trim() : "");
                clientModifie.setTelephone(telephone != null ? telephone.trim() : "");
                clientModifie.setAdresse(adresse != null ? adresse.trim() : "");
                ok = dao.modifier(clientModifie);
                messageRetour = ok ? "✅ Client modifie avec succes." : "❌ Erreur lors de la modification.";
            } else {
                // Mode ajout → INSERT dans la BDD
                Client nouveauClient = new Client();
                nouveauClient.setNom(nom.trim());
                nouveauClient.setEmail(email != null ? email.trim() : "");
                nouveauClient.setTelephone(telephone != null ? telephone.trim() : "");
                nouveauClient.setAdresse(adresse != null ? adresse.trim() : "");
                ok = dao.ajouter(nouveauClient);
                messageRetour = ok ? "✅ Client ajoute avec succes." : "❌ Erreur lors de l'ajout.";
            }

            // Si succes → rediriger vers la liste apres 1 seconde (via meta refresh)
            if (ok) {
                // On pose un flag pour afficher le message PUIS rediriger
                session.setAttribute("flashMessage", messageRetour);
                response.sendRedirect("client-list.jsp");
                return;
            }
        }
    }

    // ── VALEURS À AFFICHER DANS LE FORMULAIRE ────────────────────────────
    // En mode modification : valeurs du client existant
    // En mode ajout : champs vides
    String valNom       = (clientExistant != null && clientExistant.getNom()       != null) ? clientExistant.getNom()       : "";
    String valEmail     = (clientExistant != null && clientExistant.getEmail()     != null) ? clientExistant.getEmail()     : "";
    String valTelephone = (clientExistant != null && clientExistant.getTelephone() != null) ? clientExistant.getTelephone() : "";
    String valAdresse   = (clientExistant != null && clientExistant.getAdresse()   != null) ? clientExistant.getAdresse()   : "";

    String titrePage = modeModification ? "Modifier le client" : "Ajouter un client";
    String titreBouton = modeModification ? "Enregistrer les modifications" : "Ajouter le client";
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>One of One — <%= titrePage %></title>
    <link rel="stylesheet" href="../../css/clients/client-form.css">
</head>
<body>

<%@ include file="/jsp/nav/navbar.jsp" %>

<%-- ── CONTENU PRINCIPAL ── --%>
<div class="main-content">

    <div class="page-header">
        <div>
            <h1><%= titrePage.toUpperCase() %></h1>
            <p>
                <%-- Fil d'ariane : Clients > Ajouter/Modifier --%>
                <a href="client-list.jsp">← Retour à la liste des clients</a>
            </p>
        </div>
    </div>

    <%-- Message d'erreur eventuel (si la validation a echoue) --%>
    <% if (!messageRetour.isEmpty()) { %>
        <div class="message-erreur"><%= messageRetour %></div>
    <% } %>

    <%-- ── FORMULAIRE ── --%>
    <%-- action="" = soumettre vers la même page (client-form.jsp) --%>
    <div class="form-container">
        <form class="form" action="client-form.jsp<%= modeModification ? "?id=" + idParam : "" %>" method="POST">

            <%-- Champ NOM — obligatoire --%>
            <div class="form-groupe">
                <label for="nom">Nom complet <span class="obligatoire">*</span></label>
                <input type="text"
                       id="nom"
                       name="nom"
                       placeholder="Ex : Jean Dupont"
                       value="<%= valNom %>"
                       required>
            </div>

            <%-- Champ EMAIL --%>
            <div class="form-groupe">
                <label for="email">Email</label>
                <input type="email"
                       id="email"
                       name="email"
                       placeholder="Ex : jean.dupont@email.com"
                       value="<%= valEmail %>">
            </div>

            <%-- Champ TELEPHONE --%>
            <div class="form-groupe">
                <label for="telephone">Telephone</label>
                <input type="tel"
                       id="telephone"
                       name="telephone"
                       placeholder="Ex : 06 12 34 56 78"
                       value="<%= valTelephone %>">
            </div>

            <%-- Champ ADRESSE --%>
            <div class="form-groupe">
                <label for="adresse">Adresse</label>
                <textarea id="adresse"
                          name="adresse"
                          rows="3"
                          placeholder="Ex : 12 Rue de la Paix, 75002 Paris"><%= valAdresse %></textarea>
            </div>

            <%-- Boutons d'action --%>
            <div class="form-actions">
                <a href="client-list.jsp" class="btn-secondaire">Annuler</a>
                <button type="submit" class="btn-primary"><%= titreBouton %></button>
            </div>

        </form>
    </div>

</div><%-- fin main-content --%>

</body>
</html>

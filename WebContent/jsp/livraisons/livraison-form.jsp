<%@ page import="java.util.*" %>
<%@ include file="/jsp/auth/check-auth.jsp" %>
<%@ page import="dao.LivraisonDAO" %>
<%@ page import="dao.CommandeDAO" %>
<%@ page import="model.Livraison" %>
<%@ page import="model.Commande" %>

<%
    request.setCharacterEncoding("UTF-8");

    LivraisonDAO dao = new LivraisonDAO();

    String id = request.getParameter("id");
    String lieu = request.getParameter("lieu");
    String fraisStr = request.getParameter("frais");
    String statut = request.getParameter("statut");
    String commandeStr = request.getParameter("commande_id");
    String errorMessage = null;

    if (lieu != null && !lieu.trim().isEmpty()
    && fraisStr != null && !fraisStr.trim().isEmpty()
    && statut != null && !statut.trim().isEmpty()
    && commandeStr != null && !commandeStr.trim().isEmpty()) {

        try {
            Livraison l = new Livraison();

            l.setLieu(lieu);
            l.setFrais(Double.parseDouble(fraisStr));
            l.setStatut(statut);
            l.setCommandeId(Integer.parseInt(commandeStr));

            if (id == null || id.isEmpty()) {
                dao.insert(l);
            } else {
                l.setId(Integer.parseInt(id));
                dao.update(l);
            }

            response.sendRedirect("livraison-list.jsp");
            return;
        } catch (NumberFormatException e) {
            errorMessage = "Veuillez saisir un montant de frais valide.";
        }
    }

    Livraison livraison = null;

    String idParam = request.getParameter("id");

    if (idParam != null) {
        livraison = new LivraisonDAO().getById(Integer.parseInt(idParam));
    }

%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
        <link rel="stylesheet" href="../../css/livraisons/livraisons.css">
        <style>
            .header-search { visibility: hidden; }
        </style>
    </head>
    <body>
        <div class="app-container livraison-page">
            <%@ include file="/jsp/nav/navbar.jsp" %>

            <div class="main-content">
                <%@ include file="/jsp/nav/header.jsp" %>
                <div class="form-container" style="margin-top: 40px;">
                    <h1><%= (livraison == null) ? "Creer une livraison" : "Modifier la livraison" %></h1>
                    <%
    if (errorMessage != null) {

%>
                    <div class="form-error"><%= errorMessage %></div>
                    <% } %>
                    <form method="post" action="livraison-form.jsp">
                        <input type="hidden" name="id" value="<%= livraison != null ? livraison.getId() : "" %>">

                        <div class="form-group">
                            <label for="lieu">Lieu</label>
                            <input type="text" id="lieu" name="lieu" value="<%= livraison != null ? livraison.getLieu() : "" %>">
                        </div>

                        <div class="form-group">
                            <label for="frais">Frais</label>
                            <input type="number" id="frais" step="0.01" name="frais" value="<%= livraison != null ? livraison.getFrais() : "" %>">
                        </div>

                        <div class="form-group">
                            <label for="statut">Statut</label>
                            <select id="statut" name="statut">
                                <option value="ATTENTE" <%= (livraison != null && "ATTENTE".equals(livraison.getStatut())) ? "selected" : "" %>>ATTENTE</option>
                                <option value="EN_COURS" <%= (livraison != null && "EN_COURS".equals(livraison.getStatut())) ? "selected" : "" %>>EN_COURS</option>
                                <option value="LIVRE" <%= (livraison != null && "LIVRE".equals(livraison.getStatut())) ? "selected" : "" %>>LIVRE</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="commande_id">Commande</label>
                            <select id="commande_id" name="commande_id">
                                <%
    CommandeDAO cdao = new CommandeDAO();
    // En creation : uniquement les commandes sans livraison
    // En modification : aussi la commande deja liee a cette livraison
    Integer currentCommandeId = (livraison != null) ? livraison.getCommandeId() : null;
    List<Commande> commandes = cdao.listerSansLivraison(currentCommandeId);
    for (Commande c : commandes) {
%>
                                <option value="<%= c.getId() %>" <%= (livraison != null && livraison.getCommandeId() == c.getId()) ? "selected" : "" %>><%= c.getNumero() %></option>
                                <% } %>
                            </select>
                        </div>

                        <button type="submit" class="form-submit-btn">
                            <%= (livraison == null) ? "Creer" : "Modifier" %>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </body>
</html>

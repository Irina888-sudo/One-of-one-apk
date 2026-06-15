<%@ page import="java.util.*" %>
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

if (lieu != null && fraisStr != null && statut != null && commandeStr != null) {

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
}

Livraison livraison = null;

String idParam = request.getParameter("id");

if (idParam != null) {
    livraison = new LivraisonDAO().getById(Integer.parseInt(idParam));
}
%>

<form method="post">

    <input type="hidden" name="id"
           value="<%= livraison != null ? livraison.getId() : "" %>">

    Lieu :
    <input type="text" name="lieu"
           value="<%= livraison != null ? livraison.getLieu() : "" %>">

    <br><br>

    Frais :
    <input type="number" step="0.01" name="frais"
           value="<%= livraison != null ? livraison.getFrais() : "" %>">

    <br><br>

    Statut :
    <select name="statut">

        <option value="ATTENTE"
            <%= (livraison != null && "ATTENTE".equals(livraison.getStatut())) ? "selected" : "" %>>
            ATTENTE
        </option>

        <option value="EN_COURS"
            <%= (livraison != null && "EN_COURS".equals(livraison.getStatut())) ? "selected" : "" %>>
            EN_COURS
        </option>

        <option value="LIVRE"
            <%= (livraison != null && "LIVRE".equals(livraison.getStatut())) ? "selected" : "" %>>
            LIVRE
        </option>

    </select>

    <br><br>

    Commande :

    <select name="commande_id">

    <%
        CommandeDAO cdao = new CommandeDAO();
        List<Commande> commandes = cdao.getAll();

        for (Commande c : commandes) {
    %>

        <option value="<%= c.getId() %>"
            <%= (livraison != null && livraison.getCommandeId() == c.getId()) ? "selected" : "" %>>

            <%= c.getNumero() %>

        </option>

    <%
        }
    %>

    </select>

    <br><br>

    <button type="submit">
        <%= (livraison == null) ? "Créer" : "Modifier" %>
    </button>

</form>
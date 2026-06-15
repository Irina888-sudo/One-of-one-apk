<%@ page import="java.util.*" %>
<%@ page import="dao.LivraisonDAO" %>
<%@ page import="model.Livraison" %>

<%
    LivraisonDAO dao = new LivraisonDAO();

    List<Livraison> livraisons = dao.getAllLivraisons();
    List<String> lieux = dao.getAllLieux();

    String statut = request.getParameter("statut");
    String lieu = request.getParameter("lieu");
    String date = request.getParameter("date");

    List<Livraison> filtered = new ArrayList<>();

    for (Livraison liv : livraisons) {

        boolean okStatut =
            (statut == null || statut.isEmpty() ||
            (liv.getStatut() != null && liv.getStatut().equalsIgnoreCase(statut)));

        boolean okLieu =
            (lieu == null || lieu.isEmpty() ||
            (liv.getLieu() != null && liv.getLieu().trim().equalsIgnoreCase(lieu.trim())));

        boolean okDate =
            (date == null || date.isEmpty() ||
            (liv.getDateLivraison() != null &&
            String.valueOf(liv.getDateLivraison()).startsWith(date)));

        if (okStatut && okLieu && okDate) {
            filtered.add(liv);
        }
    }
%>
<form method="get">

    <select name="statut" onchange="this.form.submit()">
        <option value="">Tous statuts</option>
        <option value="ATTENTE">ATTENTE</option>
        <option value="EN_COURS">EN_COURS</option>
        <option value="LIVRE">LIVRE</option>
    </select>

    <select name="lieu" onchange="this.form.submit()">
        <option value="">Tous lieux</option>

        <%
            for (String l : lieux) {
        %>
            <option value="<%= l %>"
                <%= (l.equals(lieu)) ? "selected" : "" %>>
                <%= l %>
            </option>
        <%
            }
        %>

    </select>
     <input type="date" name="date" onchange="this.form.submit()"
        value="<%= request.getParameter("date") != null ? request.getParameter("date") : "" %>">
</form>


<table border="1">
    <tr>
        <th>N° LIVRAISON</th>
        <th>N° Commande</th>
        <th>Lieu</th>
        <th>Frais</th>
        <th>Statut</th>
    </tr>

    <%
        for (Livraison l : filtered) {
    %>

    <tr>
        <td><%= l.getNumero() %></td>
        <td><%= l.getCommandeId() %></td>
        <td><%= l.getLieu() %></td>
        <td><%= l.getFrais() %></td>
        <td><%= l.getStatut() %></td>
    </tr>

    <%
        }
    %>

</table>
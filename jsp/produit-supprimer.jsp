<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.ProduitDAO" %>
<%
    String idParam = request.getParameter("id");

    if (idParam == null || idParam.isBlank()) {
        response.sendRedirect("produits.jsp");
        return;
    }

    try {
        int id = Integer.parseInt(idParam);
        ProduitDAO dao = new ProduitDAO();
        dao.supprimer(id);
        session.setAttribute("flash", "Produit supprimé.");
        session.setAttribute("flashType", "success");
    } catch (Exception e) {
        session.setAttribute("flash", "Erreur lors de la suppression : " + e.getMessage());
        session.setAttribute("flashType", "error");
    }

    response.sendRedirect("produits.jsp");
%>

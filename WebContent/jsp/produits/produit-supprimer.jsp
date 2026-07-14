<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/jsp/auth/check-auth.jsp" %>
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
        session.setAttribute("flash", "Produit deplace vers la corbeille.");
        session.setAttribute("flashType", "success");
    } catch (Exception e) {
        session.setAttribute("flash", "Erreur lors de la suppression : " + e.getMessage());
        session.setAttribute("flashType", "error");
    }

    response.sendRedirect("produits.jsp");
%>

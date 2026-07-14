<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/jsp/auth/check-auth.jsp" %>
<%@ page import="dao.CommandeDAO" %>
<%
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isBlank()) {
        response.sendRedirect("commandes.jsp");
        return;
    }
    try {
        int id = Integer.parseInt(idParam);
        CommandeDAO dao = new CommandeDAO();
        dao.supprimer(id);
        session.setAttribute("flash", "Commande supprimee.");
        session.setAttribute("flashType", "success");
    } catch (Exception e) {
        session.setAttribute("flash", "Erreur lors de la suppression : " + e.getMessage());
        session.setAttribute("flashType", "error");
    }
    response.sendRedirect("commandes.jsp");
%>

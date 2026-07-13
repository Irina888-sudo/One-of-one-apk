<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.CorbeilleDAO" %>
<%
    String idParam = request.getParameter("id");
    String section = request.getParameter("section");
    if (section == null || section.isBlank()) {
        section = "all";
    }
    if (idParam != null && !idParam.isBlank()) {
        try {
            int id = Integer.parseInt(idParam);
            CorbeilleDAO dao = new CorbeilleDAO();
            boolean restored = dao.restaurer(id);
            session.setAttribute("flash", restored ? "element restaure avec succes." : "Impossible de restaurer cet element.");
            session.setAttribute("flashType", restored ? "success" : "error");
        } catch (Exception e) {
            session.setAttribute("flash", "Erreur lors de la restauration : " + e.getMessage());
            session.setAttribute("flashType", "error");
        }
    }
    response.sendRedirect("corbeille.jsp?section=" + java.net.URLEncoder.encode(section, "UTF-8"));
%>

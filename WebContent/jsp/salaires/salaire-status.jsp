<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/jsp/auth/check-auth.jsp" %>
<%@ page import="dao.SalaireDAO" %>
<%
    String idStr = request.getParameter("id");
    String statut = request.getParameter("statut");
    String redirect = "salaire-list.jsp";
    if (idStr == null || statut == null) {
        response.sendRedirect(redirect + "?error=" + java.net.URLEncoder.encode("Parametres manquants", "UTF-8"));
        return;
    }

    try {
        int id = Integer.parseInt(idStr);
        boolean ok = new SalaireDAO().updateStatut(id, statut);
        if (ok) {
            // Invoice export disabled per user request. Only update status and return to list.
            response.sendRedirect(redirect + "?success=" + java.net.URLEncoder.encode("Statut mis a jour", "UTF-8"));
        } else {
            response.sendRedirect(redirect + "?error=" + java.net.URLEncoder.encode("Impossible de mettre a jour", "UTF-8"));
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect(redirect + "?error=" + java.net.URLEncoder.encode("Erreur interne", "UTF-8"));
    }
%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.EmployeDAO" %>
<%
    EmployeDAO employeDAO = new EmployeDAO();
    String idParam = request.getParameter("id");
    
    if (idParam != null && !idParam.isEmpty()) {
        int id = Integer.parseInt(idParam);
        boolean success = employeDAO.deleteEmployeLogique(id);
        
        if (success) {
            response.sendRedirect("employe-list.jsp?success=Employ%C3%A9+d%C3%A9sactiv%C3%A9+avec+succ%C3%A8s");
        } else {
            response.sendRedirect("employe-list.jsp?error=Erreur+lors+de+la+d%C3%A9sactivation");
        }
    } else {
        response.sendRedirect("employe-list.jsp?error=ID+employ%C3%A9+manquant");
    }
%>
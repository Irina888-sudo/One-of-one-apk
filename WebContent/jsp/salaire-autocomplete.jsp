<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Employe, dao.EmployeDAO" %>
<%
    String term = request.getParameter("term");
    List<Employe> suggestions = new EmployeDAO().getSuggestions(term);

    StringBuilder json = new StringBuilder("[");
    for (int i = 0; i < suggestions.size(); i++) {
        Employe emp = suggestions.get(i);
        if (i > 0) json.append(",");
        json.append("{\"nom\":\"").append(emp.getNom() != null ? emp.getNom().replace("\"","\\\"") : "")
            .append("\"}");
    }
    json.append("]");
    out.print(json.toString());
%>
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Employe, dao.EmployeDAO" %>
<%
    String searchTerm = request.getParameter("q");
    List<Map<String, Object>> results = new ArrayList<>();
    
    if (searchTerm != null && !searchTerm.trim().isEmpty()) {
        try {
            EmployeDAO dao = new EmployeDAO();
            List<Employe> employes = dao.getSuggestions(searchTerm);
            
            if (employes != null && !employes.isEmpty()) {
                for (Employe e : employes) {
                    Map<String, Object> emp = new HashMap<>();
                    System.out.println("Nom employé = " + e.getNom());
System.out.println("Classe = " + e.getNom().getClass());
                    
                    emp.put("id", e.getId());
                    emp.put("nom", e.getNom() != null ? e.getNom() : "");
                    emp.put("email", e.getEmail() != null ? e.getEmail() : "");
                    emp.put("telephone", e.getTelephone() != null ? e.getTelephone() : "");
                    emp.put("role", e.getRole() != null ? e.getRole() : "Sans rôle");
                    emp.put("statut", e.getStatut() != null ? e.getStatut() : "INACTIF");
                    results.add(emp);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            results = new ArrayList<>();
        }
    }
    
    StringBuilder json = new StringBuilder();
    json.append("[");
    for (int i = 0; i < results.size(); i++) {
        Map<String, Object> emp = results.get(i);
        if (i > 0) json.append(",");
        json.append("{");
        json.append("\"id\":").append(emp.get("id")).append(",");
        json.append("\"nom\":\"").append(escapeJson(String.valueOf(emp.get("nom")))).append("\",");
        json.append("\"email\":\"").append(escapeJson(String.valueOf(emp.get("email")))).append("\",");
        json.append("\"telephone\":\"").append(escapeJson(String.valueOf(emp.get("telephone")))).append("\",");
        json.append("\"role\":\"").append(escapeJson(String.valueOf(emp.get("role")))).append("\",");
        json.append("\"statut\":\"").append(escapeJson(String.valueOf(emp.get("statut")))).append("\"");
        json.append("}");
    }
    json.append("]");
    
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    out.print(json.toString());
%>
<%!
    private String escapeJson(String s) {
        if (s == null) return "";
        if (s.equals("null")) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
%>
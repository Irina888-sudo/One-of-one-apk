<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/jsp/auth/check-auth.jsp" %>
<%@ page import="model.Salaire, dao.SalaireDAO, dao.EmployeDAO" %>
<%@ page import="java.io.*" %>
<%
    String idStr = request.getParameter("id");
    String redirect = "salaire-list.jsp";

    if (idStr == null) {
        response.sendRedirect(redirect + "?error=" + java.net.URLEncoder.encode("ID manquant", "UTF-8"));
        return;
    }

    try {
        int id = Integer.parseInt(idStr);
        Salaire salaire = new SalaireDAO().findById(id);

        if (salaire == null) {
            response.sendRedirect(redirect + "?error=" + java.net.URLEncoder.encode("Salaire introuvable", "UTF-8"));
            return;
        }

        String nomEmploye = EmployeDAO.getNomEmployeById(salaire.getEmployeId());
        String role = EmployeDAO.getRoleById(salaire.getEmployeId());
        String mois = Salaire.formatMois(salaire.getMois());
        String brut = salaire.getSalaireBrut() != null ? salaire.getSalaireBrut().toString() : "";
        String net = salaire.getSalaireNet() != null ? salaire.getSalaireNet().toString() : "";

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"salaire-" + id + ".csv\"");

        PrintWriter writer = response.getWriter();
        writer.write("Employe,Role,Mois,SalaireBrut,SalaireNet,DateExport\n");
        writer.write(
                escapeCsv(nomEmploye) + "," +
                escapeCsv(role) + "," +
                escapeCsv(mois) + "," +
                escapeCsv(brut) + "," +
                escapeCsv(net) + "," +
                java.time.LocalDate.now() + "\n");
        writer.flush();

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect(redirect + "?error=" + java.net.URLEncoder.encode("Erreur export: " + e.getMessage(), "UTF-8"));
    }
%>

<%!
   
    boolean exporterLigneVersCsv(String cheminCsv, String nomEmploye, String role, String mois, String brut, String net) {
        try {
            File fichier = new File(cheminCsv);
            File dossier = fichier.getParentFile();
            if (dossier != null && !dossier.exists()) {
                dossier.mkdirs();
            }

            boolean fichierExisteDeja = fichier.exists();

            if (!fichierExisteDeja) {
                FileWriter writer = new FileWriter(cheminCsv, true);
                writer.write("Employe,Role,Mois,SalaireBrut,SalaireNet,DateExport\n");
                writer.close();
            }

            FileWriter writer2 = new FileWriter(cheminCsv, true);
            writer2.write(
                    escapeCsv(nomEmploye) + "," +
                    escapeCsv(role) + "," +
                    escapeCsv(mois) + "," +
                    escapeCsv(brut) + "," +
                    escapeCsv(net) + "," +
                    java.time.LocalDate.now() + "\n");
            writer2.close();

            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    String escapeCsv(String value) {
        if (value == null) return "";
        String escaped = value.replace("\"", "\"\"");
        if (escaped.contains(",") || escaped.contains("\n") || escaped.contains("\r") || escaped.contains("\"")) {
            return "\"" + escaped + "\"";
        }
        return escaped;
    }
%>

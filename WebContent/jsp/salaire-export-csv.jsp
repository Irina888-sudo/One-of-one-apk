<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Salaire, dao.SalaireDAO, dao.EmployeDAO" %>
<%@ page import="java.io.*" %>
<%
    String idStr = request.getParameter("id");
    String redirect = "salaire-liste.jsp";

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

     
        String cheminCsv = application.getRealPath("/") + "data" + File.separator + "historique_salaires_payes.csv";

        String nomEmploye = EmployeDAO.getNomEmployeById(salaire.getEmployeId());
        String role = EmployeDAO.getRoleById(salaire.getEmployeId());
        String mois = Salaire.formatMois(salaire.getMois());
        String brut = salaire.getSalaireBrut().toString();
        String net = salaire.getSalaireNet().toString();

       
        boolean succes = exporterLigneVersCsv(cheminCsv, nomEmploye, role, mois, brut, net);

        if (succes) {
            response.sendRedirect(redirect + "?success=" + java.net.URLEncoder.encode("Ligne ajoutée au CSV", "UTF-8"));
        } else {
            response.sendRedirect(redirect + "?error=" + java.net.URLEncoder.encode("Export CSV non implémenté", "UTF-8"));
        }

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect(redirect + "?error=" + java.net.URLEncoder.encode("Erreur export: " + e.getMessage(), "UTF-8"));
    }
%>

<%!
   
    boolean exporterLigneVersCsv(String cheminCsv, String nomEmploye, String role, String mois, String brut, String net) {
        try {
            File fichier = new File(cheminCsv);
            boolean fichierExisteDeja = fichier.exists();

            if (fichierExisteDeja == false) {
                FileWriter writer = new FileWriter(cheminCsv, true);
                writer.write("Employe,Role,Mois,SalaireBrut,SalaireNet,DateExport\n");
                writer.close();
            }

            FileWriter writer2 = new FileWriter(cheminCsv, true);
            writer2.write(nomEmploye + "," + role + "," + mois + "," + brut + "," + net + "," + java.time.LocalDate.now() + "\n");
            writer2.close();

            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
%>
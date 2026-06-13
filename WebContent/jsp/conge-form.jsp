<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Conge, dao.CongeDAO, dao.EmployeDAO, model.Employe, java.sql.Date" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Formulaire Employé - OneOfOne</title>
    <link rel="stylesheet" href="../css/salaire.css">
</head>
<body>
<%
    CongeDAO congeDAO = new CongeDAO();
    EmployeDAO employeDAO = new EmployeDAO();
    Conge conge = null;
    int id = 0;
    String errorMsg = null;
    
    // If conge_id provided -> editing existing conge; else if id provided -> employe id for new conge
    int congeId = 0;
    if (request.getParameter("conge_id") != null) {
        congeId = Integer.parseInt(request.getParameter("conge_id"));
        conge = congeDAO.getCongeById(congeId);
        if (conge != null) id = conge.getId();
    } else if (request.getParameter("id") != null) {
        // id acts as employe id for new request
        id = 0; // form will not be in edit mode
    }
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
    String employeIdStr = request.getParameter("employe_id");
        String dateDebutStr = request.getParameter("date_debut");
        String dateFinStr = request.getParameter("date_fin");
        String motif = request.getParameter("motif");
    String typeConge = request.getParameter("type_conge");
        String statut = request.getParameter("statut");

        boolean hasError = false;

        Integer employeId = null;
        // if URL has id param (from salaire-list.jsp link), prefer that
        if (request.getParameter("id") != null && (employeIdStr == null || employeIdStr.trim().isEmpty())) {
            try { employeId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { hasError = true; errorMsg = "Identifiant employé invalide."; }
        } else {
            if (employeIdStr == null || employeIdStr.trim().isEmpty()) {
                errorMsg = "Veuillez sélectionner un employé.";
                hasError = true;
            } else {
                try { employeId = Integer.parseInt(employeIdStr); } catch (Exception e) { hasError = true; errorMsg = "Identifiant employé invalide."; }
            }
        }

        java.sql.Date dateDebut = null;
        java.sql.Date dateFin = null;
        try {
            if (dateDebutStr != null && !dateDebutStr.isEmpty()) dateDebut = java.sql.Date.valueOf(dateDebutStr);
            if (dateFinStr != null && !dateFinStr.isEmpty()) dateFin = java.sql.Date.valueOf(dateFinStr);
        } catch (Exception e) {
            hasError = true; errorMsg = "Dates invalides: " + e.getMessage();
        }

        if (!hasError) {
            if (conge == null) conge = new Conge();
            conge.setEmployeId(employeId);
            conge.setDateDebut(dateDebut);
            conge.setDateFin(dateFin);
            if (dateDebut != null && dateFin != null) {
                long diff = (dateFin.getTime() - dateDebut.getTime()) / (1000L * 60 * 60 * 24) + 1;
                conge.setNbrJours((int) diff);
            }
            conge.setMotif(motif);
            conge.setTypeConge(typeConge != null ? typeConge : "NON_PAYE");
            conge.setStatut(statut != null ? statut : "EN_ATTENTE");

            boolean success;
            if (congeId > 0) {
                success = congeDAO.updateConge(conge);
            } else {
                try {
                    success = congeDAO.addConge(conge);
                } catch (Exception e) {
                    success = false;
                    errorMsg = "Erreur SQL: " + e.getMessage();
                    e.printStackTrace();
                }
                // apply immediately to salary if non-paid: recompute total NON_PAYE days for the month and update salaire_net
                if (success) {
                    try {
                        java.time.LocalDate mois = conge.getDateDebut() != null ? conge.getDateDebut().toLocalDate().withDayOfMonth(1) : java.time.LocalDate.now().withDayOfMonth(1);
                        // compute total non-payé days for this employee for that month
                        int totalNonPaye = 0;
                        java.util.List<model.Conge> conges = new dao.CongeDAO().getCongesByEmployeId(conge.getEmployeId());
                        if (conges != null) {
                            for (model.Conge c : conges) {
                                try {
                                    if (c != null && c.getTypeConge() != null && "NON_PAYE".equalsIgnoreCase(c.getTypeConge())) {
                                        if (c.getDateDebut() != null) {
                                            java.time.LocalDate ddeb = c.getDateDebut().toLocalDate();
                                            // count congés that fall in the same month
                                            if (ddeb.getYear() == mois.getYear() && ddeb.getMonthValue() == mois.getMonthValue()) {
                                                totalNonPaye += (c.getNbrJours() != null ? c.getNbrJours() : 0);
                                            }
                                        }
                                    }
                                } catch (Exception ignore) {}
                            }
                        }
                        // update salary for the month using total non-payé days
                        new dao.SalaireDAO().updateSalaryForMonthWithTotalLeave(conge.getEmployeId(), mois, totalNonPaye, false);
                    } catch (Exception ex) { ex.printStackTrace(); }
                }
            }

            if (success) {
                String message = id > 0 ? "Congé modifié avec succès !" : "Congé ajouté avec succès !";
                response.sendRedirect("salaire-list.jsp?success=" + java.net.URLEncoder.encode(message, "UTF-8"));
                return;
            } else {
                errorMsg = "Erreur lors de l'enregistrement.";
            }
        }
    }
%>

<div class="container">
    <div class="header">
        <h1><%= id > 0 ? " Modifier l'employé" : " Ajouter un employé" %></h1>
        <p>OneOfOne - Gestion RH</p>
    </div>
    
    <div class="nav">
        <div class="nav-links">
            <a href="employe-list.jsp"> Retour à la liste</a>
        </div>
    </div>
    
    <% if (errorMsg != null) { %>
        <div class="alert alert-error">
            Erreur <%= errorMsg %>
        </div>
    <% } %>
    
    <div class="form-container">
    <form method="post" action="conge-form.jsp<%= congeId > 0 ? "?conge_id=" + congeId : (request.getParameter("id") != null ? "?id=" + request.getParameter("id") : "") %>" class="form">
            <% if (id > 0) { %>
                <input type="hidden" name="id" value="<%= id %>">
            <% } %>
            <div class="form-group">
                <label>Employé *</label>
                <input type="hidden" name="employe_id" value="<%= request.getParameter("id") != null ? request.getParameter("id") : (conge != null && conge.getEmployeId() != null ? conge.getEmployeId() : "") %>">
                <div><strong><%= request.getParameter("id") != null ? (new dao.EmployeDAO().getEmployeById(Integer.parseInt(request.getParameter("id"))).getNom()) : (conge != null ? new dao.EmployeDAO().getEmployeById(conge.getEmployeId()).getNom() : "") %></strong></div>
            </div>

            <div class="form-group">
                <label>Date de début *</label>
                <input type="date" name="date_debut" required value="<%= conge != null && conge.getDateDebut() != null ? conge.getDateDebut() : "" %>">
            </div>

            <div class="form-group">
                <label>Date de fin *</label>
                <input type="date" name="date_fin" required value="<%= conge != null && conge.getDateFin() != null ? conge.getDateFin() : "" %>">
            </div>

            <div class="form-group">
                <label>Motif</label>
                <textarea name="motif"><%= conge != null && conge.getMotif() != null ? conge.getMotif() : "" %></textarea>
            </div>
            <div class="form-group">
                <label>Type de congé</label>
                <select name="type_conge">
                    <option value="NON_PAYE" <%= conge != null && "NON_PAYE".equals(conge.getTypeConge()) ? "selected" : "" %>>Non payé</option>
                    <option value="PAYE" <%= conge != null && "PAYE".equals(conge.getTypeConge()) ? "selected" : "" %>>Payé</option>
                </select>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-success"> Enregistrer</button>
                <a href="salaire-list.jsp" class="btn btn-warning">Annuler</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
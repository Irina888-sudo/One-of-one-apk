<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Salaire, dao.SalaireDAO, dao.EmployeDAO, model.Employe, java.math.BigDecimal, java.time.LocalDate, java.sql.Date, java.util.List" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Formulaire Employé - OneOfOne</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<%
    // DAOs
    dao.SalaireDAO salaireDAO = null;
    dao.EmployeDAO employeDAO = new EmployeDAO();

    Salaire salaire = null;
    int id = 0;
    String errorMsg = null;

    try {
        // SalaireDAO in codebase accepts a Connection in constructor; try to use default if available
        salaireDAO = new SalaireDAO(null);
    } catch (Exception e) {
        // fallback: create without connection if no ctor available
    }

    if (request.getParameter("id") != null) {
        try {
            id = Integer.parseInt(request.getParameter("id"));
            // try both method names used in codebase
            try { salaire = salaireDAO.findById(id); } catch (Exception ex) { salaire = null; }
        } catch (Exception ignored) {}
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String employeIdStr = request.getParameter("employe_id");
        String moisStr = request.getParameter("mois");
        String salaireBrutStr = request.getParameter("salaire_brut");
        String statut = request.getParameter("statut");

        boolean hasError = false;

        Integer employeId = null;
        if (employeIdStr == null || employeIdStr.isEmpty()) {
            errorMsg = "Veuillez sélectionner un employé.";
            hasError = true;
        } else {
            try { employeId = Integer.parseInt(employeIdStr); } catch (Exception e) { hasError = true; errorMsg = "Identifiant employé invalide."; }
        }

        java.time.LocalDate mois = null;
        if (moisStr != null && !moisStr.isEmpty()) {
            try { mois = java.time.LocalDate.parse(moisStr + "-01"); } catch (Exception e) { hasError = true; errorMsg = "Mois invalide."; }
        }

        java.math.BigDecimal salaireBrut = null;
        try {
            salaireBrut = new java.math.BigDecimal(salaireBrutStr);
            if (salaireBrut.compareTo(java.math.BigDecimal.ZERO) < 0) { errorMsg = "Le salaire doit être supérieur à 0."; hasError = true; }
        } catch (Exception e) {
            if (!hasError) { errorMsg = "Salaire invalide."; hasError = true; }
        }

        if (!hasError) {
            if (salaire == null) salaire = new Salaire();

            salaire.setEmployeId(employeId);
            salaire.setMois(mois);
            salaire.setSalaireBrut(salaireBrut);
            salaire.setStatut(statut);

            boolean success = false;
            try {
                if (id > 0) {
                    // try update or update(Salaire)
                    try { success = salaireDAO.update(salaire); } catch (Exception ex) { success = false; }
                } else {
                    try { Salaire created = salaireDAO.create(salaire); success = created != null; } catch (Exception ex) { success = false; }
                }
            } catch (Exception e) {
                success = false;
            }

            if (success) {
                String message = id > 0 ? "Salaire modifié avec succès !" : "Salaire ajouté avec succès !";
                response.sendRedirect("salaire-list.jsp?success=" + java.net.URLEncoder.encode(message, "UTF-8"));
                return;
            } else {
                errorMsg = "Erreur lors de l'enregistrement.";
            }
        }
    }

    // load employees for dropdown
    java.util.List<Employe> employes = employeDAO.getAllEmployes(null, null, null, null, null, 0, 1000);
%>

<div class="container">
    <div class="header">
        <h1><%= id > 0 ? " Modifier le salaire" : " Ajouter un salaire" %></h1>
        <p>OneOfOne - Gestion RH</p>
    </div>
    
    <div class="nav">
        <div class="nav-links">
            <a href="Salaire-list.jsp"> Retour à la liste</a>
        </div>
    </div>
    
    <% if (errorMsg != null) { %>
        <div class="alert alert-error">
            Erreur <%= errorMsg %>
        </div>
    <% } %>
    
    <div class="form-container">
        <form method="post" action="Salaire-form.jsp<%= id > 0 ? "?id=" + id : "" %>" class="form">
            <% if (id > 0) { %>
                <input type="hidden" name="id" value="<%= id %>">
            <% } %>
            
            <div class="form-group">
                <label>Employé *</label>
                <select name="employe_id" required>
                    <option value="">Sélectionner un employé</option>
                    <% for (Employe e : employes) { %>
                        <option value="<%= e.getId() %>" <%= salaire != null && salaire.getEmployeId() != null && salaire.getEmployeId().equals(e.getId()) ? "selected" : "" %>><%= e.getNom() %> (<%= e.getEmail() %>)</option>
                    <% } %>
                </select>
            </div>

            <div class="form-group">
                <label>Mois *</label>
                <input type="month" name="mois" required value="<%= salaire != null && salaire.getMois() != null ? salaire.getMois().toString().substring(0,7) : "" %>">
            </div>

            <div class="form-group">
                <label>Salaire brut (€) *</label>
                <input type="number" step="0.01" name="salaire_brut" required value="<%= salaire != null && salaire.getSalaireBrut() != null ? salaire.getSalaireBrut() : "" %>">
            </div>

            <div class="form-group">
                <label>Statut</label>
                <select name="statut">
                    <option value="ACTIF" <%= salaire != null && "ACTIF".equals(salaire.getStatut()) ? "selected" : "" %>>ACTIF</option>
                    <option value="INACTIF" <%= salaire != null && "INACTIF".equals(salaire.getStatut()) ? "selected" : "" %>>INACTIF</option>
                </select>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-success"> Enregistrer</button>
                <a href="Salaire-list.jsp" class="btn btn-warning">Annuler</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/jsp/auth/check-auth.jsp" %>
<%@ page import="model.Salaire, dao.SalaireDAO, dao.EmployeDAO, model.Employe, java.math.BigDecimal, java.time.LocalDate, java.sql.Date, java.util.List, util.DBConnection, java.sql.Connection" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Formulaire Salaire - OneOfOne</title>
    <link rel="stylesheet" href="../../css/salaires/salaire-form.css">
</head>
<body>
    <%@ include file="/jsp/nav/navbar.jsp" %>
<%
    Connection conn = null;
    SalaireDAO salaireDAO = null;
    EmployeDAO employeDAO = new EmployeDAO();
    Salaire salaire = null;
    int id = 0;
    String errorMsg = null;

    try {
        conn = DBConnection.getConnection();
        salaireDAO = new SalaireDAO(conn);
    } catch (Exception e) {
        errorMsg = "Erreur de connexion a la base de donnees: " + e.getMessage();
    }

    // Recuperer le salaire s'il y a un ID
    if (request.getParameter("id") != null && !request.getParameter("id").isEmpty()) {
        try {
            id = Integer.parseInt(request.getParameter("id"));
            salaire = salaireDAO.findById(id);
            if (salaire == null) {
                errorMsg = "Salaire non trouve";
            }
        } catch (Exception e) {
            errorMsg = "Erreur: " + e.getMessage();
        }
    }

    // Traiter le formulaire POST
    if ("POST".equalsIgnoreCase(request.getMethod()) && errorMsg == null) {
        try {
            String employeIdStr = request.getParameter("employe_id");
            String moisStr = request.getParameter("mois");
            String salaireBrutStr = request.getParameter("salaire_brut");
            String salaireNetStr = request.getParameter("salaire_net");
            String statut = request.getParameter("statut");

            // Validation
            if (employeIdStr == null || employeIdStr.isEmpty()) {
                errorMsg = "Veuillez selectionner un employe.";
            } else if (moisStr == null || moisStr.isEmpty()) {
                errorMsg = "Veuillez saisir un mois.";
            } else if (salaireBrutStr == null || salaireBrutStr.isEmpty()) {
                errorMsg = "Veuillez saisir le salaire brut.";
            } else {
                // Parser les donnees
                Integer employeId = Integer.parseInt(employeIdStr);
                LocalDate mois = LocalDate.parse(moisStr + "-01");
                BigDecimal salaireBrut = new BigDecimal(salaireBrutStr);
                BigDecimal salairNet = !salaireNetStr.isEmpty() ? new BigDecimal(salaireNetStr) : salaireBrut;

                if (salaireBrut.compareTo(BigDecimal.ZERO) <= 0) {
                    errorMsg = "Le salaire brut doit etre superieur a 0.";
                } else if (id > 0) {
                    // Modification
                    salaire = new Salaire();
                    salaire.setId(id);
                    salaire.setEmployeId(employeId);
                    salaire.setMois(mois);
                    salaire.setSalaireBrut(salaireBrut);
                    salaire.setSalaireNet(salairNet);
                    salaire.setStatut(statut != null ? statut : "ATTENTE");

                    boolean success = salaireDAO.update(salaire);
                    if (success) {
                        response.sendRedirect("salaire-list.jsp?success=Salaire modifie avec succes");
                        return;
                    } else {
                        errorMsg = "Erreur lors de la modification du salaire.";
                    }
                } else {
                    // Creation
                    salaire = new Salaire();
                    salaire.setEmployeId(employeId);
                    salaire.setMois(mois);
                    salaire.setSalaireBrut(salaireBrut);
                    salaire.setSalaireNet(salairNet);
                    salaire.setStatut(statut != null ? statut : "ATTENTE");

                    Salaire created = salaireDAO.create(salaire);
                    if (created != null) {
                        response.sendRedirect("salaire-list.jsp?success=Salaire ajoute avec succes");
                        return;
                    } else {
                        errorMsg = "Erreur lors de la creation du salaire.";
                    }
                }
            }
        } catch (NumberFormatException e) {
            errorMsg = "Erreur de format: " + e.getMessage();
        } catch (Exception e) {
            errorMsg = "Erreur: " + e.getMessage();
            e.printStackTrace();
        }
    }

    // Charger la liste des employes
    List<Employe> employes = employeDAO.getAllEmployes(null, null, null, null, null, 0, 1000);
%>

<div class="container">
    <div class="header">
        <h1><%= id > 0 ? "Modifier un salaire" : "Ajouter un salaire" %></h1>
        <p>OneOfOne - Gestion RH</p>
    </div>
    
    <% if (errorMsg != null) { %>
        <div class="alert alert-error" style="margin:10px; padding:10px;"> 
            Erreur: <%= errorMsg %> 
        </div>
    <% } %>
    
    <div class="form-container">
        <form method="post" action="salaire-form.jsp<%= id > 0 ? "?id=" + id : "" %>" class="form">
            <% if (id > 0) { %>
                <input type="hidden" name="id" value="<%= id %>">
            <% } %>
            
            <div class="form-group">
                <label>Employe *</label>
                <select name="employe_id" required>
                    <option value="">-- Selectionner un employe --</option>
                    <% if (employes != null) {
                        for (Employe e : employes) { %>
                        <option value="<%= e.getId() %>" 
                            <%= salaire != null && salaire.getEmployeId() != null && salaire.getEmployeId().equals(e.getId()) ? "selected" : "" %>>
                            <%= e.getNom() %> (<%= e.getEmail() %>)
                        </option>
                    <% } 
                    } %>
                </select>
            </div>

            <div class="form-group">
                <label>Mois *</label>
                <input type="month" name="mois" required value="<%= salaire != null && salaire.getMois() != null ? salaire.getMois().toString().substring(0,7) : "" %>">
            </div>

            <div class="form-group">
                <label>Salaire Brut (Ariary) *</label>
                <input type="number" step="0.01" name="salaire_brut" required value="<%= salaire != null && salaire.getSalaireBrut() != null ? salaire.getSalaireBrut() : "" %>">
            </div>

            <div class="form-group">
                <label>Salaire Net (Ariary)</label>
                <input type="number" step="0.01" name="salaire_net" value="<%= salaire != null && salaire.getSalaireNet() != null ? salaire.getSalaireNet() : "" %>">
            </div>

            <div class="form-group">
                <label>Statut</label>
                <select name="statut">
                    <option value="ATTENTE" <%= salaire != null && "ATTENTE".equals(salaire.getStatut()) ? "selected" : "" %>>ATTENTE</option>
                    <option value="PAYE" <%= salaire != null && "PAYE".equals(salaire.getStatut()) ? "selected" : "" %>>PAYE</option>
                </select>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-success"> Enregistrer</button>
                <a href="salaire-list.jsp" class="btn btn-warning"> Annuler</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>

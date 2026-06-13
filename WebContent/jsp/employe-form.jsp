<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Employe, dao.EmployeDAO, java.math.BigDecimal, java.sql.Date" %>
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
    EmployeDAO employeDAO = new EmployeDAO();
    Employe employe = null;
    int id = 0;
    String errorMsg = null;
    

    if (request.getParameter("id") != null) {
        id = Integer.parseInt(request.getParameter("id"));
        employe = employeDAO.getEmployeById(id);
    }
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String nom = request.getParameter("nom");
        String email = request.getParameter("email");
        String telephone = request.getParameter("telephone");
        String role = request.getParameter("role");
        String salaireBrutStr = request.getParameter("salaire_brut");
        String statut = request.getParameter("statut");
        String dateEmbaucheStr = request.getParameter("date_embauche");
        
        // Validation
        boolean hasError = false;
        
        if (nom == null || nom.trim().isEmpty()) {
            errorMsg = "Le nom est obligatoire.";
            hasError = true;
        }
        
        if (email == null || email.trim().isEmpty()) {
            errorMsg = "L'email est obligatoire.";
            hasError = true;
        } else if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            errorMsg = "Format d'email invalide.";
            hasError = true;
        }
        
        BigDecimal salaireBrut = null;
        try {
            salaireBrut = new BigDecimal(salaireBrutStr);
            if (salaireBrut.compareTo(BigDecimal.ZERO) < 0) {
                errorMsg = "Le salaire doit être supérieur à 0.";
                hasError = true;
            }
        } catch (Exception e) {
            errorMsg = "Salaire invalide.";
            hasError = true;
        }
        
        // verification email unique
        if (!hasError) {
            if (employeDAO.isEmailExists(email, id)) {
                errorMsg = "Cet email est déjà utilisé par un autre employé.";
                hasError = true;
            }
        }
        
        if (!hasError) {
            if (employe == null) {
                employe = new Employe();
            }
            
            employe.setNom(nom);
            employe.setEmail(email);
            employe.setTelephone(telephone);
            employe.setRole(role);
            employe.setSalaireBrut(salaireBrut);
            employe.setStatut(statut);
            employe.setDateEmbauche(dateEmbaucheStr != null && !dateEmbaucheStr.isEmpty() ? Date.valueOf(dateEmbaucheStr) : null);
            
            boolean success;
            if (id > 0) {
                success = employeDAO.updateEmploye(employe);
            } else {
                success = employeDAO.addEmploye(employe);
            }
            
            if (success) {
                String message = id > 0 ? "Employé modifié avec succès !" : "Employé ajouté avec succès !";
                response.sendRedirect("employe-list.jsp?success=" + java.net.URLEncoder.encode(message, "UTF-8"));
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
        <form method="post" action="employe-form.jsp<%= id > 0 ? "?id=" + id : "" %>" class="form">
            <% if (id > 0) { %>
                <input type="hidden" name="id" value="<%= id %>">
            <% } %>
            
            <div class="form-group">
                <label>Nom complet *</label>
                <input type="text" name="nom" required value="<%= employe != null ? employe.getNom() : "" %>">
            </div>
            
            <div class="form-group">
                <label>Email *</label>
                <input type="email" name="email" required value="<%= employe != null ? employe.getEmail() : "" %>">
            </div>
            
            <div class="form-group">
                <label>Téléphone</label>
                <input type="tel" name="telephone" value="<%= employe != null && employe.getTelephone() != null ? employe.getTelephone() : "" %>">
            </div>
            
            <div class="form-group">
                <label>Rôle</label>
                <select name="role">
                    <option value="">Sélectionner un rôle</option>
                    <option value="Développeur" <%= employe != null && "Développeur".equals(employe.getRole()) ? "selected" : "" %>>Développeur</option>
                    <option value="Comptable" <%= employe != null && "Comptable".equals(employe.getRole()) ? "selected" : "" %>>Comptable</option>
                    <option value="Manager" <%= employe != null && "Manager".equals(employe.getRole()) ? "selected" : "" %>>Manager</option>
                    <option value="Designer" <%= employe != null && "Designer".equals(employe.getRole()) ? "selected" : "" %>>Designer</option>
                    <option value="Commercial" <%= employe != null && "Commercial".equals(employe.getRole()) ? "selected" : "" %>>Commercial</option>
                    <option value="Couturier" <%= employe != null && "Couturier".equals(employe.getRole()) ? "selected" : "" %>>Couturier</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Salaire brut (€) *</label>
                <input type="number" step="0.01" name="salaire_brut" required value="<%= employe != null && employe.getSalaireBrut() != null ? employe.getSalaireBrut() : "" %>">
            </div>
            
            <div class="form-group">
                <label>Statut</label>
                <select name="statut">
                    <option value="ACTIF" <%= employe != null && "ACTIF".equals(employe.getStatut()) ? "selected" : "" %>>ACTIF</option>
                    <option value="INACTIF" <%= employe != null && "INACTIF".equals(employe.getStatut()) ? "selected" : "" %>>INACTIF</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Date d'embauche</label>
                <input type="date" name="date_embauche" value="<%= employe != null && employe.getDateEmbauche() != null ? employe.getDateEmbauche() : "" %>">
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-success"> Enregistrer</button>
                <a href="employe-list.jsp" class="btn btn-warning">Annuler</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
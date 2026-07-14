<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.UtilisateurDAO" %>
<%@ page import="model.Utilisateur" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion - One of One</title>
    <link rel="stylesheet" href="../../css/auth/login.css">
</head>
<body>

<%
    String error = null;
    String success = null;

    if (request.getParameter("logout") != null) {
        HttpSession sess = request.getSession(false);
        if (sess != null) {
            sess.invalidate();
        }
        success = "Vous avez ete deconnecte.";
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String u = request.getParameter("username");
        String p = request.getParameter("password");

        if (u == null || u.trim().isEmpty() || p == null || p.trim().isEmpty()) {
            error = "Veuillez saisir un utilisateur et un mot de passe.";
        } else {
            UtilisateurDAO utilisateurDAO = new UtilisateurDAO();
            Utilisateur utilisateur = utilisateurDAO.authentifier(u.trim(), p);

            if (utilisateur != null) {
                HttpSession sess = request.getSession(true);
                sess.setAttribute("userNom", utilisateur.getEmail());
                sess.setAttribute("userRole", utilisateur.getRole() != null ? utilisateur.getRole() : "ADMIN");
                sess.setAttribute("userInitials", "AD");
                response.sendRedirect(request.getContextPath() + "/jsp/dashboard/dashboard.jsp");
                return;
            } else {
                error = "Identifiants incorrects.";
            }
        }
    }
%>

<div class="login-card">
    <div class="login-form-side">
        <div class="login-header">
            <h1 class="login-title">Login</h1>
            <p class="login-subtitle">Please enter your details.</p>
        </div>

        <% if (error != null) { %>
            <div class="error"><%= error %></div>
        <% } %>
        <% if (success != null) { %>
            <div class="success"><%= success %></div>
        <% } %>

        <form action="login.jsp" method="POST" class="login-form">
            <div class="input-group">
                <input type="text" id="username" name="username" value="admin@oneofone.fr" required placeholder="Email">
            </div>
            <div class="input-group">
                <input type="password" id="password" name="password" value="admin123" required placeholder="Password">
            </div>

            <div class="login-options">
                <label class="remember-me">
                    <input type="checkbox" name="remember">
                    Remember for 30 days
                </label>
                <a href="#" class="forgot-password">Forgot password?</a>
            </div>

            <button type="submit" class="login-btn">Login</button>
        </form>

        <div class="login-footer">
            Need an account? <a href="#">Contact administrator</a>
        </div>
    </div>

    <div class="login-image-side">
        <img src="../../css/1.jpg" alt="Login Image" class="login-image-inner">
    </div>
</div>

</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.UtilisateurDAO" %>
<%@ page import="model.Utilisateur" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Connexion</title>
    <link rel="stylesheet" href="../css/login.css">
</head>
<body>

<div class="card">
    <h2>Connexion</h2>

    <%
        String error = null;
        String success = null;

        if (request.getParameter("logout") != null) {
            HttpSession sess = request.getSession(false);
            if (sess != null) {
                sess.invalidate();
            }
            success = "Vous avez été déconnecté.";
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
                    response.sendRedirect("dashboard.jsp");
                    return;
                } else {
                    error = "Identifiants incorrects.";
                }
            }
        }
    %>

    <% if (error != null) { %>
        <div class="error"><%= error %></div>
    <% } %>
    <% if (success != null) { %>
        <div class="success"><%= success %></div>
    <% } %>

    <form action="login.jsp" method="POST">
        <div class="input-group">
            <label for="username">Utilisateur :</label>
            <input type="text" id="username" name="username" value="admin@oneofone.fr" required placeholder="ex: admin@oneofone.fr">
        </div>
        <div class="input-group">
            <label for="password">Mot de passe :</label>
            <input type="password" id="password" name="password" value="admin123" required placeholder="ex: admin123">
        </div>
        <button type="submit">Se connecter</button>
    </form>
</div>

</body>
</html>
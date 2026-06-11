<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Connexion</title>
   
</head>
<body>

<div class="card">
    <h2>Connexion</h2>
    
    <%-- Logique Java de traitement du formulaire --%>
    <%
        String error = null;
        String success = null;
        String methode = request.getMethod();

        if ("POST".equalsIgnoreCase(methode)) {
            String u = request.getParameter("username");
            String p = request.getParameter("password");

            // Identifiants hardcodés pour le test
            if ("admin".equals(u) && "1234".equals(p)) {
                success = "Connexion réussie ! Bienvenue " + u;
            } else {
                error = "Identifiants incorrects.";
            }
        }
    %>

    <%-- Affichage des messages --%>
    <% if (error != null) { %> <div class="error"><%= error %></div> <% } %>
    <% if (success != null) { %> <div class="success"><%= success %></div> <% } %>

    <%-- Formulaire HTML --%>
    <form action="login.jsp" method="POST">
        <div class="input-group">
            <label for="username">Utilisateur :</label>
            <input type="text" id="username" name="username" required placeholder="ex: admin">
        </div>
        <div class="input-group">
            <label for="password">Mot de passe :</label>
            <input type="password" id="password" name="password" required placeholder="ex: 1234">
        </div>
        <button type="submit">Se connecter</button>
    </form>
</div>

</body>
</html>
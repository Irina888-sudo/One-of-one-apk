<%
    // Récupération des infos utilisateur depuis la session
    String userNom = (String) session.getAttribute("userNom");
    if (userNom == null) userNom = "Admin";

    String userRole = (String) session.getAttribute("userRole");
    if (userRole == null) userRole = "SUPER ADMIN";

    String userInitials = (String) session.getAttribute("userInitials");
    if (userInitials == null) {
        // Générer les initiales à partir du nom si non présentes
        userInitials = userNom.length() >= 2 ? userNom.substring(0, 2).toUpperCase() : userNom.toUpperCase();
    }
%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
<div class="topbar">
    <div class="user">
        <div class="user-info">
            <div class="user-name"><%= userNom %></div>
            <div class="user-role"><%= userRole %></div>
        </div>
        <div class="avatar"><%= userInitials %></div>
    </div>
</div>

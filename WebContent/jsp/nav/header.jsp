<%
    // Recuperation des infos utilisateur depuis la session
    String headerUserNom = (String) session.getAttribute("userNom");
    if (headerUserNom == null) headerUserNom = "Admin";

    String headerUserRole = (String) session.getAttribute("userRole");
    if (headerUserRole == null) headerUserRole = "SUPER ADMIN";

    String headerUserInitials = (String) session.getAttribute("userInitials");
    if (headerUserInitials == null) {
        // Generer les initiales à partir du nom si non presentes
        headerUserInitials = headerUserNom.length() >= 2 ? headerUserNom.substring(0, 2).toUpperCase() : headerUserNom.toUpperCase();
    }

    String headerRequestUri = request.getRequestURI();
    String headerPageName = headerRequestUri.substring(headerRequestUri.lastIndexOf('/') + 1);
    String contextPath = request.getContextPath();
    String headerSearchParam = "q";
    String headerSearchPlaceholder = "Rechercher...";

    if (headerPageName.contains("commandes.jsp")) {
        headerSearchParam = "recherche";
        headerSearchPlaceholder = "Rechercher une commande...";
    } else if (headerPageName.contains("employe-list.jsp")) {
        headerSearchParam = "search";
        headerSearchPlaceholder = "Rechercher un employe...";
    } else if (headerPageName.contains("produits.jsp")) {
        headerSearchParam = "recherche";
        headerSearchPlaceholder = "Rechercher un produit...";
    } else if (headerPageName.contains("client-list.jsp")) {
        headerSearchParam = "q";
        headerSearchPlaceholder = "Rechercher un client...";
    } else if (headerPageName.contains("stock-list.jsp")) {
        headerSearchParam = "q";
        headerSearchPlaceholder = "Rechercher une matiere...";
    } else if (headerPageName.contains("livraison-list.jsp")) {
        headerSearchParam = "search";
        headerSearchPlaceholder = "Rechercher une livraison...";
    }

    String headerSearchValue = request.getParameter(headerSearchParam);
%>
<link rel="stylesheet" href="../../css/shared/header.css">
<div class="topbar">
    <form class="header-search" method="get" action="javascript:void(0)" onsubmit="return submitHeaderSearch(this);" data-param-name="<%= headerSearchParam %>">
        <input type="text" name="<%= headerSearchParam %>" placeholder="<%= headerSearchPlaceholder %>" value="<%= headerSearchValue != null ? headerSearchValue : "" %>">
        <button type="submit">Rechercher</button>
    </form>
    <div class="user">
        <div class="user-info">
            <div class="user-name"><%= headerUserNom %></div>
            <div class="user-role"><%= headerUserRole %></div>
        </div>
        <div class="avatar"><%= headerUserInitials %></div>
    </div>
</div>
<script>
function submitHeaderSearch(form) {
    const input = form.querySelector('input');
    const paramName = form.getAttribute('data-param-name') || 'q';
    const url = new URL(window.location.href);
    const value = input.value.trim();

    url.searchParams.delete(paramName);

    if (value) {
        url.searchParams.set(paramName, value);
    }

    window.location.href = url.toString();
    return false;
}
</script>

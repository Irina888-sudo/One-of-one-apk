<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="../css/navbar.css">
<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    // Appliquer l'état de la sidebar IMMÉDIATEMENT avant le rendu
    const sidebarState = localStorage.getItem("sidebar") || "collapsed";
    if(sidebarState === "collapsed"){
        document.documentElement.setAttribute("data-sidebar-collapsed", "true");
    }
</script>

<div class="sidebar" id="sidebar">
    
<div class="brand" id="toggleSidebar">
    <img src="../svg/logo2.svg" class="brand-logo" style="color: #fff;" alt="Logo">

    <div class="brand-text">
        <h1>One of One</h1>
        <p>Management Suite</p>
    </div>
</div>                                         
        <nav>
            <a href="dashboard.jsp" >
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg> 
                <span>Tableau de bord</span>
            </a>
            <a href="stock-list.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10"/></svg> <span>Stock</span>
            </a>

            <a href="produits.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10"/></svg> <span>Produits</span>
            </a>

            <a href="commandes.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7h18M7 7v10m10-10v10m-5 0h4a2 2 0 002-2v-4a2 2 0 00-2-2h-4a2 2 0 00-2 2v4a2 2 0 002 2z"/></svg> <span>Commandes</span>
            </a>
            <a href="livraison-list.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10M13 16h3.586a1 1 0 00.707-.293l2.414-2.414a1 1 0 00.293-.707V11h-7M13 16H9m4 0V9"/></svg> <span>Livraisons</span>
            </a>
            <a href="client-list.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/></svg> <span>Clients</span>
            </a>
            <a href="employe-list.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg> <span>Employés</span>
            </a>
            <a href="salaire-list.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/></svg> <span>Salaires</span>
            </a>

            <a href="finance-list.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/></svg> <span>Finances</span>
            </a>

            <a href="login.jsp?logout=true" style="margin-top:auto;color:#f5c0c0;">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                <span>Déconnexion</span>
            </a>
        </nav>
    </div>
<script>

const sidebar = document.getElementById("sidebar");
const toggle = document.getElementById("toggleSidebar");

// Appliquer l'état initial au DOM
if(document.documentElement.getAttribute("data-sidebar-collapsed") === "true"){
    sidebar.classList.add("collapsed");
}

toggle.addEventListener("click", () => {

    sidebar.classList.toggle("collapsed");

    if(sidebar.classList.contains("collapsed")){
        localStorage.setItem("sidebar", "collapsed");
    }else{
        localStorage.setItem("sidebar", "expanded");
    }

});

// Marquer la page active dans la sidebar
(function () {
    const current = location.pathname.split("/").pop().toLowerCase();
    document.querySelectorAll(".sidebar nav a").forEach(link => {
        const href = (link.getAttribute("href") || "").toLowerCase();
        const page = href.split("/").pop().split("?")[0];
        const isLogout = href.indexOf("logout") !== -1;
        if (!isLogout && page && page === current) {
            link.classList.add("active");
        }
    });
})();

</script> 
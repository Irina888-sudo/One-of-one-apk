<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.DashboardDAO" %>
<%@ page import="model.StatistiqueMensuelle" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.util.ArrayList" %>
<%
    String userNom = (String) session.getAttribute("userNom");
    String userRole = (String) session.getAttribute("userRole");
    String userInitials = (String) session.getAttribute("userInitials");
    if (userNom == null) userNom = "Admin";
    if (userRole == null) userRole = "SUPER ADMIN";
    if (userInitials == null) userInitials = "AD";

    DashboardDAO dao = new DashboardDAO();
    int currentYear = LocalDate.now().getYear();
    int currentMonthIndex = LocalDate.now().getMonthValue() - 1;
    
    List<StatistiqueMensuelle> stats = null;
    StatistiqueMensuelle currentMonthStat = null;
    
    // Arrays for Chart.js
    StringBuilder labels = new StringBuilder("[");
    StringBuilder caData = new StringBuilder("[");
    StringBuilder depensesData = new StringBuilder("[");
    StringBuilder stockData = new StringBuilder("[");
    StringBuilder commandesData = new StringBuilder("[");

    String[] monthNames = {"Janv", "Fév", "Mars", "Avr", "Mai", "Juin", "Juil", "Août", "Sept", "Oct", "Nov", "Déc"};

    try {
        stats = dao.getStatistiquesAnnuelles(currentYear);
        if (stats != null && !stats.isEmpty()) {
            currentMonthStat = stats.get(currentMonthIndex);
            
            for (int i = 0; i < stats.size(); i++) {
                StatistiqueMensuelle s = stats.get(i);
                labels.append("'").append(monthNames[i]).append("'");
                caData.append(s.getChiffreAffaires());
                depensesData.append(s.getDepenses());
                stockData.append(s.getStockMatieres());
                commandesData.append(s.getNombreCommandes());
                
                if (i < stats.size() - 1) {
                    labels.append(", ");
                    caData.append(", ");
                    depensesData.append(", ");
                    stockData.append(", ");
                    commandesData.append(", ");
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    labels.append("]");
    caData.append("]");
    depensesData.append("]");
    stockData.append("]");
    commandesData.append("]");
    
    if (currentMonthStat == null) {
        currentMonthStat = new StatistiqueMensuelle(currentMonthIndex + 1);
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord – One of One</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root { --sidebar-bg:#1a3631; --sidebar-active:#e8820c; --accent-teal:#3ecfb2; --accent-orange:#e8820c; --bg-main:#f5f0ea; --bg-card:#ffffff; --text-dark:#111111; --text-muted:#76716a; --border:#e6e1d9; --status-error:#e05c5c; }
        * { box-sizing:border-box; margin:0; padding:0; }
        body { display:flex; font-family:'Inter',sans-serif; background:var(--bg-main); color:var(--text-dark); min-height:100vh; }
        .sidebar { width:240px; background:var(--sidebar-bg); color:#fff; display:flex; flex-direction:column; padding:24px 0; min-height:100vh; }
        .sidebar .brand { padding:0 24px 28px; border-bottom:1px solid rgba(255,255,255,.08); margin-bottom:16px; }
        .sidebar .brand h1 { font-size:18px; font-weight:800; letter-spacing:2px; text-transform:uppercase; }
        .sidebar .brand p { font-size:11px; color:#7ca89c; margin-top:2px; letter-spacing:1px; text-transform:uppercase; }
        .sidebar nav { display:flex; flex-direction:column; gap:2px; }
        .sidebar nav a { display:flex; align-items:center; gap:12px; padding:12px 24px; color:#b0ccc6; text-decoration:none; font-size:14px; font-weight:500; transition:all .2s ease; }
        .sidebar nav a svg { width:18px; height:18px; flex-shrink:0; opacity:.85; }
        .sidebar nav a:hover { background:rgba(255,255,255,.05); color:#fff; }
        .sidebar nav a.active { background:var(--sidebar-active); color:#fff; font-weight:600; }
        .sidebar .new-entry { margin:auto 16px 0; background:var(--accent-teal); color:#1a3631; border:none; border-radius:8px; padding:12px; font-size:13px; font-weight:700; text-decoration:none; display:flex; align-items:center; justify-content:center; gap:8px; transition:all .2s ease; text-transform:uppercase; letter-spacing:.5px; }
        .sidebar .new-entry:hover { opacity:.9; transform:translateY(-1px); }
        
        .main { flex:1; display:flex; flex-direction:column; height: 100vh; overflow-y: auto;}
        .topbar { background:#fff; padding:16px 32px; display:flex; align-items:center; gap:20px; border-bottom:1px solid var(--border); }
        .topbar .user { margin-left:auto; font-size:13px; display:flex; align-items:center; gap:12px; }
        .topbar .user-name { font-weight:600; font-size:14px; }
        .topbar .user-role { font-size:11px; color:var(--text-muted); text-transform:uppercase; letter-spacing:.5px; }
        .topbar .avatar { width:38px; height:38px; border-radius:50%; background:var(--accent-teal); color:#1a3631; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:14px; border:2px solid #fff; box-shadow:0 2px 8px rgba(0,0,0,.1); }
        
        .content { padding:28px 32px; flex:1; }
        .page-header { display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:24px; }
        .page-header h2 { font-size:26px; font-weight:800; letter-spacing:-.5px; }
        .page-header p { color:var(--text-muted); font-size:13px; margin-top:4px; }
        
        /* Dashboard Specific Styles */
        .cards-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 24px; }
        .stat-card { background: var(--bg-card); border-radius: 12px; padding: 24px; border: 1px solid var(--border); box-shadow: 0 2px 8px rgba(0,0,0,0.02); }
        .stat-card-icon { width: 40px; height: 40px; border-radius: 8px; display: flex; align-items: center; justify-content: center; margin-bottom: 16px; }
        .icon-green { background: #e6f9f5; color: #1db899; }
        .icon-red { background: #fde8e8; color: #e05c5c; }
        .icon-blue { background: #e8f0fe; color: #4285f4; }
        .stat-card-title { font-size: 11px; color: var(--text-muted); font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; }
        .stat-card-value { font-size: 28px; font-weight: 800; letter-spacing: -0.5px; color: var(--text-dark); margin-bottom: 8px;}
        .stat-card-subtitle { font-size: 12px; color: var(--text-muted); }

        .charts-grid-main { margin-bottom: 24px; }
        .charts-grid-secondary { display: grid; grid-template-columns: repeat(2, 1fr); gap: 24px; margin-bottom: 24px; }
        .chart-card { background: var(--bg-card); border-radius: 12px; padding: 24px; border: 1px solid var(--border); box-shadow: 0 2px 8px rgba(0,0,0,0.02); }
        .chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .chart-title { font-size: 14px; font-weight: 700; text-transform: uppercase; color: var(--text-dark); }
        .chart-container { position: relative; height: 300px; width: 100%; }
        .chart-container-small { position: relative; height: 250px; width: 100%; }

    </style>
</head>
<body>
    <div class="sidebar">
        <div class="brand"><h1>One of One</h1><p>Management Suite</p></div>
        <nav>
            <a href="dashboard.jsp" class="active">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg> Tableau de bord
            </a>
            <a href="stock-list.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10"/></svg> Stock
            </a>
            <a href="commandes.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7h18M7 7v10m10-10v10m-5 0h4a2 2 0 002-2v-4a2 2 0 00-2-2h-4a2 2 0 00-2 2v4a2 2 0 002 2z"/></svg> Commandes
            </a>
            <a href="livraison-list.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10M13 16h3.586a1 1 0 00.707-.293l2.414-2.414a1 1 0 00.293-.707V11h-7M13 16H9m4 0V9"/></svg> Livraisons
            </a>
            <a href="client-list.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/></svg> Clients
            </a>
            <a href="employe-list.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg> Employés
            </a>
            <a href="salaire-list.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/></svg> Salaires
            </a>
            <a href="login.jsp?logout=true" style="margin-top:auto;color:#f5c0c0;">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                Déconnexion
            </a>
        </nav>
    </div>
    <div class="main">
        <div class="topbar">
            <div class="user">
                <div class="user-info"><div class="user-name"><%= userNom %></div><div class="user-role"><%= userRole %></div></div>
                <div class="avatar"><%= userInitials %></div>
            </div>
        </div>
        <div class="content">
            <div class="page-header">
                <div><h2>TABLEAU DE BORD</h2><p>Aperçu de l'activité pour l'année <%= currentYear %> et le mois en cours.</p></div>
            </div>
            
            <!-- KPIs Top Cards -->
            <div class="cards-grid">
                <div class="stat-card">
                    <div class="stat-card-icon icon-green">
                        <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </div>
                    <div class="stat-card-title">Chiffre d'Affaires</div>
                    <div class="stat-card-value"><%= String.format("%,.2f", currentMonthStat.getChiffreAffaires()) %> €</div>
                    <div class="stat-card-subtitle">Mois en cours (<%= monthNames[currentMonthIndex] %>)</div>
                </div>
                <div class="stat-card">
                    <div class="stat-card-icon icon-red">
                        <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path></svg>
                    </div>
                    <div class="stat-card-title">Dépenses Totales</div>
                    <div class="stat-card-value"><%= String.format("%,.2f", currentMonthStat.getDepenses()) %> €</div>
                    <div class="stat-card-subtitle">Mois en cours (<%= monthNames[currentMonthIndex] %>)</div>
                </div>
                <div class="stat-card">
                    <div class="stat-card-icon icon-blue">
                        <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10"></path></svg>
                    </div>
                    <div class="stat-card-title">Stock Total</div>
                    <div class="stat-card-value"><%= String.format("%,.0f", currentMonthStat.getStockMatieres()) %></div>
                    <div class="stat-card-subtitle">Mois en cours (<%= monthNames[currentMonthIndex] %>)</div>
                </div>
            </div>

            <!-- Main Chart: Financial Evolution -->
            <div class="charts-grid-main">
                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">Évolution Financière (12 mois)</div>
                    </div>
                    <div class="chart-container">
                        <canvas id="financeChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Secondary Charts: Stock and Orders -->
            <div class="charts-grid-secondary">
                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">Évolution du Stock</div>
                    </div>
                    <div class="chart-container-small">
                        <canvas id="stockChart"></canvas>
                    </div>
                </div>
                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">Volume de Commandes</div>
                    </div>
                    <div class="chart-container-small">
                        <canvas id="ordersChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const labels = <%= labels.toString() %>;
        const caData = <%= caData.toString() %>;
        const depensesData = <%= depensesData.toString() %>;
        const stockData = <%= stockData.toString() %>;
        const commandesData = <%= commandesData.toString() %>;

        // Chart 1: Financial Evolution (Line Chart)
        const ctxFinance = document.getElementById('financeChart').getContext('2d');
        new Chart(ctxFinance, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Revenus (CA)',
                        data: caData,
                        borderColor: '#1a3631',
                        backgroundColor: 'rgba(26, 54, 49, 0.1)',
                        borderWidth: 2,
                        tension: 0.4,
                        fill: true
                    },
                    {
                        label: 'Dépenses',
                        data: depensesData,
                        borderColor: '#e05c5c',
                        backgroundColor: 'transparent',
                        borderWidth: 2,
                        tension: 0.4,
                        fill: false
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    mode: 'index',
                    intersect: false,
                },
                plugins: {
                    legend: { position: 'top', align: 'end' }
                },
                scales: {
                    y: { beginAtZero: true, grid: { borderDash: [4, 4] } },
                    x: { grid: { display: false } }
                }
            }
        });

        // Chart 2: Stock Evolution (Bar Chart)
        const ctxStock = document.getElementById('stockChart').getContext('2d');
        new Chart(ctxStock, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Stock Total',
                    data: stockData,
                    backgroundColor: 'rgba(62, 207, 178, 0.5)',
                    hoverBackgroundColor: 'rgba(62, 207, 178, 0.8)',
                    borderRadius: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: { beginAtZero: true, grid: { borderDash: [4, 4] } },
                    x: { grid: { display: false } }
                }
            }
        });

        // Chart 3: Orders Volume (Bar Chart instead of Donut, matching Stock style as requested)
        const ctxOrders = document.getElementById('ordersChart').getContext('2d');
        new Chart(ctxOrders, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Nombre de Commandes',
                    data: commandesData,
                    backgroundColor: 'rgba(232, 130, 12, 0.5)',
                    hoverBackgroundColor: 'rgba(232, 130, 12, 0.8)',
                    borderRadius: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: { beginAtZero: true, grid: { borderDash: [4, 4] } },
                    x: { grid: { display: false } }
                }
            }
        });
    </script>
</body>
</html>

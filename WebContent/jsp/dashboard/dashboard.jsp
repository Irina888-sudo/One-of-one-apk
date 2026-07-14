<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/jsp/auth/check-auth.jsp" %>
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

    String[] monthNames = {"Janv", "Fev", "Mars", "Avr", "Mai", "Juin", "Juil", "Aout", "Sept", "Oct", "Nov", "Dec"};

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
    <link rel="stylesheet" href="../../css/dashboard/dashboard.css">
   
</head>
<body>
  <%@ include file="/jsp/nav/navbar.jsp" %>
    <div class="main">
        <div class="topbar">
            <div class="user">
                <div class="user-info"><div class="user-name"><%= userNom %></div><div class="user-role"><%= userRole %></div></div>
                <div class="avatar"><%= userInitials %></div>
            </div>
        </div>
        <div class="content">
            <div class="page-header">
                <div>
                    <h1>TABLEAU DE BORD</h1>
                    <p>Apercu de l'activite pour l'annee <%= currentYear %> et le mois en cours.</p>
                </div>
            </div>
            
            <!-- KPIs Top Cards -->
            <div class="cards-grid">
                <div class="stat-card">
                    <div class="stat-card-icon icon-green">
                        <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </div>
                    <div class="stat-card-title">Chiffre d'Affaires</div>
                    <div class="stat-card-value"><%= String.format("%,.0f", currentMonthStat.getChiffreAffaires()) %> Ariary</div>
                    <div class="stat-card-subtitle">Mois en cours (<%= monthNames[currentMonthIndex] %>)</div>
                </div>
                <div class="stat-card">
                    <div class="stat-card-icon icon-red">
                        <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path></svg>
                    </div>
                    <div class="stat-card-title">Depenses Totales</div>
                    <div class="stat-card-value"><%= String.format("%,.0f", currentMonthStat.getDepenses()) %> Ariary</div>
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
                        <div class="chart-title">evolution Financiere (12 mois)</div>
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
                        <div class="chart-title">evolution du Stock</div>
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
                        borderColor: '#c30000',
                        backgroundColor: 'rgba(195, 0, 0, 0.06)',
                        borderWidth: 2,
                        tension: 0.4,
                        fill: true
                    },
                    {
                        label: 'Depenses',
                        data: depensesData,
                        borderColor: '#6f4c4c',
                        backgroundColor: 'transparent',
                        borderWidth: 2,
                        borderDash: [5, 3],
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
                    legend: { position: 'top', align: 'end', labels: { font: { weight: 'bold' } } }
                },
                scales: {
                    y: { beginAtZero: true, grid: { borderDash: [4, 4], color: 'rgba(195, 0, 0, 0.06)' } },
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
                    backgroundColor: 'rgba(195, 0, 0, 0.12)',
                    hoverBackgroundColor: 'rgba(195, 0, 0, 0.25)',
                    borderRadius: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: { beginAtZero: true, grid: { borderDash: [4, 4], color: 'rgba(195, 0, 0, 0.06)' } },
                    x: { grid: { display: false } }
                }
            }
        });

        // Chart 3: Orders Volume (Bar Chart)
        const ctxOrders = document.getElementById('ordersChart').getContext('2d');
        new Chart(ctxOrders, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Nombre de Commandes',
                    data: commandesData,
                    backgroundColor: 'rgba(195, 0, 0, 0.25)',
                    hoverBackgroundColor: 'rgba(195, 0, 0, 0.4)',
                    borderRadius: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: { beginAtZero: true, grid: { borderDash: [4, 4], color: 'rgba(195, 0, 0, 0.06)' } },
                    x: { grid: { display: false } }
                }
            }
        });
    </script>
</body>
</html>

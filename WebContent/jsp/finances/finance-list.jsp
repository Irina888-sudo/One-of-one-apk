<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/jsp/auth/check-auth.jsp" %>
<%@ page import="dao.FinanceDAO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.LocalDate" %>

<%
    FinanceDAO dao = new FinanceDAO();
    int anneeCourante = LocalDate.now().getYear();

    double ca         = dao.getChiffreAffairesTotal(anneeCourante);
    double salaires   = dao.getTotalSalairesPaies(anneeCourante);
    double matieres   = dao.getTotalAchatsMatieres(anneeCourante);
    double depenses   = salaires + matieres;
    double margeNette = ca - depenses;
    int    nbCmd      = dao.getNbCommandesLivrees(anneeCourante);

    double pctSalaires = depenses > 0 ? (salaires / depenses) * 100 : 0;
    double pctMatieres = depenses > 0 ? (matieres / depenses) * 100 : 0;

    ArrayList<String[]> dernieresCommandes = dao.getDernieresCommandesLivrees();

    String margeCouleur = margeNette >= 0 ? "#1db899" : "#951111";
    String margeSymbole = margeNette >= 0 ? "\u25B2" : "\u25BC";
    String margeLabel   = margeNette >= 0 ? "B\u00E9n\u00E9fice net" : "Perte nette";

    String jsSalaires = String.format("%.0f", salaires).replace(",", ".");
    String jsMatieres = String.format("%.0f", matieres).replace(",", ".");
    String pieData = "[" + jsSalaires + ", " + jsMatieres + "]";
    String margeStyle = "color:" + margeCouleur;
    String salaireWidth = ((int) pctSalaires) + "%";
    String matiereWidth = ((int) pctMatieres) + "%";
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>One of One &mdash; Finances</title>
    <link rel="stylesheet" href="../../css/finances/finances.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
</head>
<body>

<%@ include file="/jsp/nav/navbar.jsp" %>

<div class="main">

<div class="main-content">

    <div class="page-header">
        <div>
            <h1>GESTION DES FINANCES</h1>
            <p>Resume financier &mdash; chiffre d'affaires, depenses et marge nette.</p>
        </div>
    </div>

    <div class="kpi-grille">

        <div class="kpi-card">
            <div class="kpi-icone">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 17l6-6 4 4 8-8"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 7h6v6"/></svg>
            </div>
            <div class="kpi-contenu">
                <small>CHIFFRE D'AFFAIRES TOTAL</small>
                <h2><%= String.format("%,.0f", ca) %> Ar</h2>
                <p>Somme du montant total des commandes de l'annee <%= anneeCourante %> (<%= nbCmd %> commandes livrees)</p>
            </div>
        </div>

        <div class="kpi-card">
            <div class="kpi-icone">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7h16a1 1 0 011 1v8a1 1 0 01-1 1H4a1 1 0 01-1-1V8a1 1 0 011-1z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 11h16"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 15h.01"/></svg>
            </div>
            <div class="kpi-contenu">
                <small>DEPENSES TOTALES</small>
                <h2><%= String.format("%,.0f", depenses) %> Ar</h2>
                <p>Salaires payes + couts matieres premieres consommees</p>
            </div>
        </div>

        <div class="kpi-card">
            <div class="kpi-icone">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 17h18"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 13v4"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v8"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 5v12"/></svg>
            </div>
            <div class="kpi-contenu">
                <small><%= margeLabel.toUpperCase() %></small>
                <h2 style="<%= margeStyle %>">
                    <%= margeSymbole %> <%= String.format("%,.0f", Math.abs(margeNette)) %> Ar
                </h2>
                <p>CA &minus; Depenses totales</p>
            </div>
        </div>

    </div>

    <div class="section-deux-colonnes">

        <div class="detail-depenses">
            <h3>Detail des depenses par categorie</h3>
            <table class="table-detail">
                <thead>
                    <tr><th>Categorie</th><th>Montant</th><th>Part</th></tr>
                </thead>
                <tbody>
                    <tr>
                        <td><span class="point-couleur point-salaires"></span> <span class="row-icon-label"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="row-icon"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 7V6a2 2 0 012-2h8a2 2 0 012 2v1"/><rect x="4" y="7" width="16" height="10" rx="2"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 11h6"/></svg> Salaires payes</span></td>
                        <td><strong><%= String.format("%,.0f", salaires) %> Ar</strong></td>
                        <td>
                            <div class="barre-progress">
                                <div class="barre-remplie barre-salaires" style="width:<%= salaireWidth %>"></div>
                            </div>
                            <%= String.format("%.1f", pctSalaires) %>%
                        </td>
                    </tr>
                    <tr>
                        <td><span class="point-couleur point-matieres"></span> <span class="row-icon-label"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="row-icon"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4v9l8 4 8-4V7z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 10.14v5.86"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 10.14v5.86"/></svg> Matieres premieres</span></td>
                        <td><strong><%= String.format("%,.0f", matieres) %> Ar</strong></td>
                        <td>
                            <div class="barre-progress">
                                <div class="barre-remplie barre-matieres" style="width:<%= matiereWidth %>"></div>
                            </div>
                            <%= String.format("%.1f", pctMatieres) %>%
                        </td>
                    </tr>
                    <tr class="ligne-total">
                        <td><strong>TOTAL</strong></td>
                        <td><strong><%= String.format("%,.0f", depenses) %> Ar</strong></td>
                        <td><strong>100%</strong></td>
                    </tr>
                </tbody>
            </table>

            <div class="note-calcul">
                <strong><span class="note-icon"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 16h.01"/><circle cx="12" cy="12" r="9"/></svg></span> Calculs :</strong>
                <ul>
                    <li><b>CA</b> = SOMME du montant total des commandes de l'annee (hors annulees)</li>
                    <li><b>Salaires</b> = SOMME des salaires payes de l'annee</li>
                    <li><b>Matieres</b> = COUT des matieres consommees par les commandes de l'annee</li>
                    <li><b>Marge</b> = CA &minus; (Salaires + Matieres)</li>
                </ul>
            </div>
        </div>

        <div class="graphique-container">
            <h3>Repartition des depenses</h3>
            <% if (depenses == 0) { %>
                <p class="vide">Aucune depense enregistree.</p>
            <% } else { %>
                <canvas id="camembert" width="280" height="280"></canvas>
                <div class="legende-camembert">
                    <span><span class="point-couleur point-salaires"></span>Salaires : <%= String.format("%.1f", pctSalaires) %>%</span>
                    <span><span class="point-couleur point-matieres"></span>Matieres : <%= String.format("%.1f", pctMatieres) %>%</span>
                </div>
            <% } %>
        </div>

    </div>

    <div class="recap-final">
        <h3>Tableau recapitulatif</h3>
        <table class="table-recap">
            <thead>
                <tr><th>Indicateur</th><th>Montant</th><th>Detail du calcul</th></tr>
            </thead>
            <tbody>
                <tr>
                    <td><span class="row-icon-label"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="row-icon"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 17l6-6 4 4 8-8"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 7h6v6"/></svg> Chiffre d'affaires total</span></td>
                    <td class="montant-positif"><strong><%= String.format("%,.0f", ca) %> Ar</strong></td>
                    <td><%= nbCmd %> commandes livrees (ligne_commande &times; commande LIVREE)</td>
                </tr>
                <tr>
                    <td><span class="row-icon-label"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="row-icon"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 7V6a2 2 0 012-2h8a2 2 0 012 2v1"/><rect x="4" y="7" width="16" height="10" rx="2"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 11h6"/></svg> Salaires payes</span></td>
                    <td class="montant-negatif">&minus; <%= String.format("%,.0f", salaires) %> Ar</td>
                    <td>SUM(salaire_net) ou statut = PAYE</td>
                </tr>
                <tr>
                    <td><span class="row-icon-label"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="row-icon"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4v9l8 4 8-4V7z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 10.14v5.86"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 10.14v5.86"/></svg> Achats matieres premieres</span></td>
                    <td class="montant-negatif">&minus; <%= String.format("%,.0f", matieres) %> Ar</td>
                    <td>SUM(quantite &times; valeur_unitaire) dans la table matiere</td>
                </tr>
                <tr class="ligne-separateur">
                    <td><span class="row-icon-label"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="row-icon"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7h16a1 1 0 011 1v8a1 1 0 01-1 1H4a1 1 0 01-1-1V8a1 1 0 011-1z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 11h16"/></svg> Depenses totales</span></td>
                    <td class="montant-negatif"><strong>&minus; <%= String.format("%,.0f", depenses) %> Ar</strong></td>
                    <td>Salaires + Matieres</td>
                </tr>
                <tr class="ligne-marge-finale">
                    <td><strong><%= margeLabel %></strong></td>
                    <td style="<%= margeStyle %>; font-size:1.1rem; font-weight:800;">
                        <strong><%= margeSymbole %> <%= String.format("%,.0f", Math.abs(margeNette)) %> Ar</strong>
                    </td>
                    <td><%= margeNette >= 0 ? "<span class='status-icon status-positive'><svg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='currentColor'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M5 13l4 4L19 7'/></svg> Resultat positif</span>" : "<span class='status-icon status-warning'><svg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='currentColor'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M12 9v4'/><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M12 17h.01'/><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M10.29 3.86l-8 14A1 1 0 002.17 19h19.66a1 1 0 00.86-1.5l-8-14a1 1 0 00-1.72 0z'/></svg> Depenses > CA</span>" %></td>
                </tr>
            </tbody>
        </table>
    </div>

    <div class="section-commandes">
        <h3>10 dernieres commandes livrees</h3>
        <table class="table">
            <thead>
                <tr><th>N&deg; Commande</th><th>Client</th><th>Montant</th><th>Date</th></tr>
            </thead>
            <tbody>
            <% if (dernieresCommandes.isEmpty()) { %>
                <tr><td colspan="4" class="vide">Aucune commande livree.</td></tr>
            <% } else {
                for (int i = 0; i < dernieresCommandes.size(); i++) {
                    String[] cmd = dernieresCommandes.get(i);
            %>
                <tr>
                    <td><strong><%= cmd[0] != null ? cmd[0] : "&mdash;" %></strong></td>
                    <td><%= cmd[1] != null ? cmd[1] : "&mdash;" %></td>
                    <td class="montant-positif"><strong><%= cmd[2] %> Ar</strong></td>
                    <td><%= cmd[3] != null ? cmd[3].substring(0, Math.min(10, cmd[3].length())) : "&mdash;" %></td>
                </tr>
            <%  }
              } %>
            </tbody>
        </table>
        <p class="lien-voir-tout">
            <a href="../commandes/commandes.jsp?statut=LIVREE">Voir toutes les commandes livrees &rarr;</a>
        </p>
    </div>

</div>
</div>

<% if (depenses > 0) { %>
<script>
(function() {
    var ctx = document.getElementById('camembert').getContext('2d');
    new Chart(ctx, {
        type: 'pie',
        data: {
            labels: ['Salaires pay\u00E9s', 'Achats mati\u00E8res premi\u00E8res'],
            datasets: [{
                data: <%= pieData %>,
                backgroundColor: ['#c30000', '#6f4c4c'],
                borderColor:     ['#ffffff', '#ffffff'],
                borderWidth: 3
            }]
        },
        options: {
            responsive: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: function(ctx) {
                            var total = ctx.dataset.data.reduce(function(a, b){ return a + b; }, 0);
                            var pct   = ((ctx.parsed / total) * 100).toFixed(1);
                            var val   = ctx.parsed.toLocaleString('fr-FR', {minimumFractionDigits:2});
                            return ctx.label + ' : ' + val + ' Ar (' + pct + '%)';
                        }
                    }
                }
            }
        }
    });
})();
</script>
<% } %>

</body>
</html>

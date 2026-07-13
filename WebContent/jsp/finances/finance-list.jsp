<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
            <p>R&eacute;sum&eacute; financier &mdash; chiffre d'affaires, d&eacute;penses et marge nette.</p>
        </div>
    </div>

    <div class="kpi-grille">

        <div class="kpi-card">
            <div class="kpi-icone">&#x1F4B9;</div>
            <div class="kpi-contenu">
                <small>CHIFFRE D'AFFAIRES TOTAL</small>
                <h2><%= String.format("%,.0f", ca) %> Ar</h2>
                <p>Somme du montant total des commandes de l'ann&eacute;e <%= anneeCourante %> (<%= nbCmd %> commandes livr&eacute;es)</p>
            </div>
        </div>

        <div class="kpi-card">
            <div class="kpi-icone">&#x1F4B8;</div>
            <div class="kpi-contenu">
                <small>D&Eacute;PENSES TOTALES</small>
                <h2><%= String.format("%,.0f", depenses) %> Ar</h2>
                <p>Salaires pay&eacute;s + co&ucirc;ts mati&egrave;res premi&egrave;res consomm&eacute;es</p>
            </div>
        </div>

        <div class="kpi-card">
            <div class="kpi-icone"><%= margeNette >= 0 ? "&#x1F4C8;" : "&#x1F4C9;" %></div>
            <div class="kpi-contenu">
                <small><%= margeLabel.toUpperCase() %></small>
                <h2 style="<%= margeStyle %>">
                    <%= margeSymbole %> <%= String.format("%,.0f", Math.abs(margeNette)) %> Ar
                </h2>
                <p>CA &minus; D&eacute;penses totales</p>
            </div>
        </div>

    </div>

    <div class="section-deux-colonnes">

        <div class="detail-depenses">
            <h3>D&eacute;tail des d&eacute;penses par cat&eacute;gorie</h3>
            <table class="table-detail">
                <thead>
                    <tr><th>Cat&eacute;gorie</th><th>Montant</th><th>Part</th></tr>
                </thead>
                <tbody>
                    <tr>
                        <td><span class="point-couleur point-salaires"></span> &#x1F4BC; Salaires pay&eacute;s</td>
                        <td><strong><%= String.format("%,.0f", salaires) %> Ar</strong></td>
                        <td>
                            <div class="barre-progress">
                                <div class="barre-remplie barre-salaires" style="width:<%= salaireWidth %>"></div>
                            </div>
                            <%= String.format("%.1f", pctSalaires) %>%
                        </td>
                    </tr>
                    <tr>
                        <td><span class="point-couleur point-matieres"></span> &#x1F9F5; Mati&egrave;res premi&egrave;res</td>
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
                <strong>&#x1F4CC; Calculs :</strong>
                <ul>
                    <li><b>CA</b> = SOMME du montant total des commandes de l'ann&eacute;e (hors annul&eacute;es)</li>
                    <li><b>Salaires</b> = SOMME des salaires pay&eacute;s de l'ann&eacute;e</li>
                    <li><b>Mati&egrave;res</b> = CO&Ucirc;T des mati&egrave;res consomm&eacute;es par les commandes de l'ann&eacute;e</li>
                    <li><b>Marge</b> = CA &minus; (Salaires + Mati&egrave;res)</li>
                </ul>
            </div>
        </div>

        <div class="graphique-container">
            <h3>R&eacute;partition des d&eacute;penses</h3>
            <% if (depenses == 0) { %>
                <p class="vide">Aucune d&eacute;pense enregistr&eacute;e.</p>
            <% } else { %>
                <canvas id="camembert" width="280" height="280"></canvas>
                <div class="legende-camembert">
                    <span><span class="point-couleur point-salaires"></span>Salaires : <%= String.format("%.1f", pctSalaires) %>%</span>
                    <span><span class="point-couleur point-matieres"></span>Mati&egrave;res : <%= String.format("%.1f", pctMatieres) %>%</span>
                </div>
            <% } %>
        </div>

    </div>

    <div class="recap-final">
        <h3>Tableau r&eacute;capitulatif</h3>
        <table class="table-recap">
            <thead>
                <tr><th>Indicateur</th><th>Montant</th><th>D&eacute;tail du calcul</th></tr>
            </thead>
            <tbody>
                <tr>
                    <td>&#x1F4B9; Chiffre d'affaires total</td>
                    <td class="montant-positif"><strong><%= String.format("%,.0f", ca) %> Ar</strong></td>
                    <td><%= nbCmd %> commandes livr&eacute;es (ligne_commande &times; commande LIVREE)</td>
                </tr>
                <tr>
                    <td>&#x1F4BC; Salaires pay&eacute;s</td>
                    <td class="montant-negatif">&minus; <%= String.format("%,.0f", salaires) %> Ar</td>
                    <td>SUM(salaire_net) o&ugrave; statut = PAYE</td>
                </tr>
                <tr>
                    <td>&#x1F9F5; Achats mati&egrave;res premi&egrave;res</td>
                    <td class="montant-negatif">&minus; <%= String.format("%,.0f", matieres) %> Ar</td>
                    <td>SUM(quantite &times; valeur_unitaire) dans la table matiere</td>
                </tr>
                <tr class="ligne-separateur">
                    <td>&#x1F4B8; D&eacute;penses totales</td>
                    <td class="montant-negatif"><strong>&minus; <%= String.format("%,.0f", depenses) %> Ar</strong></td>
                    <td>Salaires + Mati&egrave;res</td>
                </tr>
                <tr class="ligne-marge-finale">
                    <td><strong><%= margeLabel %></strong></td>
                    <td style="<%= margeStyle %>; font-size:1.1rem; font-weight:800;">
                        <strong><%= margeSymbole %> <%= String.format("%,.0f", Math.abs(margeNette)) %> Ar</strong>
                    </td>
                    <td><%= margeNette >= 0 ? "&#x2705; R&eacute;sultat positif" : "&#x26A0;&#xFE0F; D&eacute;penses > CA" %></td>
                </tr>
            </tbody>
        </table>
    </div>

    <div class="section-commandes">
        <h3>10 derni&egrave;res commandes livr&eacute;es</h3>
        <table class="table">
            <thead>
                <tr><th>N&deg; Commande</th><th>Client</th><th>Montant</th><th>Date</th></tr>
            </thead>
            <tbody>
            <% if (dernieresCommandes.isEmpty()) { %>
                <tr><td colspan="4" class="vide">Aucune commande livr&eacute;e.</td></tr>
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
            <a href="../commandes/commandes.jsp?statut=LIVREE">Voir toutes les commandes livr&eacute;es &rarr;</a>
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

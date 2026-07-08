<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.FinanceDAO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.LocalDate" %>

<%
    FinanceDAO dao = new FinanceDAO();
    int anneeCourante = LocalDate.now().getYear();

    // ── Les 4 grands chiffres ──────────────────────────
    double ca         = dao.getChiffreAffairesTotal(anneeCourante);
    double salaires   = dao.getTotalSalairesPaies(anneeCourante);
    double matieres   = dao.getTotalAchatsMatieres(anneeCourante);
    double depenses   = salaires + matieres;
    double margeNette = ca - depenses;
    int    nbCmd      = dao.getNbCommandesLivrees(anneeCourante);

    // ── Pourcentages pour le camembert ────────────────
    double pctSalaires = depenses > 0 ? (salaires / depenses) * 100 : 0;
    double pctMatieres = depenses > 0 ? (matieres / depenses) * 100 : 0;

    // ── Dernières commandes livrées ───────────────────
    ArrayList<String[]> dernieresCommandes = dao.getDernieresCommandesLivrees();

    // ── Style selon marge positive ou négative ────────
    String margeCouleur = margeNette >= 0 ? "#10b981" : "#dc2626";
    String margeSymbole = margeNette >= 0 ? "▲" : "▼";
    String margeLabel   = margeNette >= 0 ? "📈 Bénéfice net" : "📉 Perte nette";

    // ── Valeurs JS-safe (point décimal, pas de virgule) ─
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
    <title>One of One — Finances</title>
    <link rel="stylesheet" href="../css/finances.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
</head>
<body>

<%@ include file="nav/navbar.jsp" %>


<div class="main-content">

    <div class="page-header">
        <div>
            <%@ include file="nav/header.jsp" %>
            <h1>GESTION DES FINANCES</h1>
            <p>Résumé financier — chiffre d'affaires, dépenses et marge nette.</p>
        </div>
    </div>

    <%-- ══════════════════════════════════════
         BLOC 1 : LES 3 KPI PRINCIPAUX
         Identiques à ceux du dashboard
         ══════════════════════════════════════ --%>
    <div class="kpi-grille">

        <div class="kpi-card kpi-ca">
            <div class="kpi-icone">💹</div>
            <div class="kpi-contenu">
                <small>CHIFFRE D'AFFAIRES TOTAL</small>
                <h2><%= String.format("%,.0f", ca) %> Ar</h2>
                <p>Somme du montant total des commandes de l'année <%= anneeCourante %> (<%= nbCmd %> commandes livrées)</p>
            </div>
        </div>

        <div class="kpi-card kpi-depenses">
            <div class="kpi-icone">💸</div>
            <div class="kpi-contenu">
                <small>DÉPENSES TOTALES</small>
                <h2><%= String.format("%,.0f", depenses) %> Ar</h2>
                <p>Salaires payés + coûts matières premières consommées</p>
            </div>
        </div>

        <div class="kpi-card kpi-marge">
            <div class="kpi-icone"><%= margeNette >= 0 ? "📈" : "📉" %></div>
            <div class="kpi-contenu">
                <small><%= margeLabel.toUpperCase() %></small>
                <h2 style="<%= margeStyle %>">
                    <%= margeSymbole %> <%= String.format("%,.0f", Math.abs(margeNette)) %> Ar
                </h2>
                <p>CA − Dépenses totales</p>
            </div>
        </div>

    </div>

    <%-- ══════════════════════════════════════
         BLOC 2 : DÉTAIL DÉPENSES + CAMEMBERT
         ══════════════════════════════════════ --%>
    <div class="section-deux-colonnes">

        <%-- Colonne gauche : tableau détail --%>
        <div class="detail-depenses">
            <h3>Détail des dépenses par catégorie</h3>
            <table class="table-detail">
                <thead>
                    <tr><th>Catégorie</th><th>Montant</th><th>Part</th></tr>
                </thead>
                <tbody>
                    <tr>
                        <td><span class="point-couleur point-salaires"></span> 💼 Salaires payés</td>
                        <td><strong><%= String.format("%,.0f", salaires) %> Ar</strong></td>
                        <td>
                            <div class="barre-progress">
                                <div class="barre-remplie barre-salaires" style="width:<%= salaireWidth %>"></div>
                            </div>
                            <%= String.format("%.1f", pctSalaires) %>%
                        </td>
                    </tr>
                    <tr>
                        <td><span class="point-couleur point-matieres"></span> 🧵 Matières premières</td>
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

            <%-- Note transparence des calculs --%>
            <div class="note-calcul">
                <strong>📌 Calculs :</strong>
                <ul>
                    <li><b>CA</b> = SOMME du montant total des commandes de l'année (hors annulées)</li>
                    <li><b>Salaires</b> = SOMME des salaires payés de l'année</li>
                    <li><b>Matières</b> = COÛT des matières consommées par les commandes de l'année</li>
                    <li><b>Marge</b> = CA − (Salaires + Matières)</li>
                </ul>
            </div>
        </div>

        <%-- Colonne droite : camembert Chart.js --%>
        <div class="graphique-container">
            <h3>Répartition des dépenses</h3>
            <% if (depenses == 0) { %>
                <p class="vide">Aucune dépense enregistrée.</p>
            <% } else { %>
                <%--
                    CAMEMBERT CHART.JS
                    Les données Java sont écrites directement
                    dans le <script> grâce aux scriptlets JSP.
                    jsSalaires et jsMatieres utilisent le point
                    décimal (pas la virgule) pour que JS les lise.
                --%>
                <canvas id="camembert" width="280" height="280"></canvas>
                <div class="legende-camembert">
                    <span><span class="point-couleur point-salaires"></span>Salaires : <%= String.format("%.1f", pctSalaires) %>%</span>
                    <span><span class="point-couleur point-matieres"></span>Matières : <%= String.format("%.1f", pctMatieres) %>%</span>
                </div>
            <% } %>
        </div>

    </div>

    <%-- ══════════════════════════════════════
         BLOC 3 : TABLEAU RÉCAPITULATIF FINAL
         ══════════════════════════════════════ --%>
    <div class="recap-final">
        <h3>Tableau récapitulatif</h3>
        <table class="table-recap">
            <thead>
                <tr><th>Indicateur</th><th>Montant</th><th>Détail du calcul</th></tr>
            </thead>
            <tbody>
                <tr>
                    <td>💹 Chiffre d'affaires total</td>
                    <td class="montant-positif"><strong><%= String.format("%,.0f", ca) %> Ar</strong></td>
                    <td><%= nbCmd %> commandes livrées (ligne_commande × commande LIVREE)</td>
                </tr>
                <tr>
                    <td>💼 Salaires payés</td>
                    <td class="montant-negatif">− <%= String.format("%,.0f", salaires) %> Ar</td>
                    <td>SUM(salaire_net) où statut = PAYE</td>
                </tr>
                <tr>
                    <td>🧵 Achats matières premières</td>
                    <td class="montant-negatif">− <%= String.format("%,.0f", matieres) %> Ar</td>
                    <td>SUM(quantite × valeur_unitaire) dans la table matiere</td>
                </tr>
                <tr class="ligne-separateur">
                    <td>💸 Dépenses totales</td>
                    <td class="montant-negatif"><strong>− <%= String.format("%,.0f", depenses) %> Ar</strong></td>
                    <td>Salaires + Matières</td>
                </tr>
                <tr class="ligne-marge-finale">
                    <td><strong><%= margeLabel %></strong></td>
                    <td style="<%= margeStyle %>; font-size:1.1rem;">
                        <strong><%= margeSymbole %> <%= String.format("%,.0f", Math.abs(margeNette)) %> Ar</strong>
                    </td>
                    <td><%= margeNette >= 0 ? "✅ Résultat positif" : "⚠️ Dépenses > CA" %></td>
                </tr>
            </tbody>
        </table>
    </div>

    <%-- ══════════════════════════════════════
         BLOC 4 : DÉTAIL RECETTES (commandes)
         ══════════════════════════════════════ --%>
    <div class="section-commandes">
        <h3>10 dernières commandes livrées</h3>
        <div class="table-container">
            <table class="table">
                <thead>
                    <tr><th>N° Commande</th><th>Client</th><th>Montant</th><th>Date</th></tr>
                </thead>
                <tbody>
                <% if (dernieresCommandes.isEmpty()) { %>
                    <tr><td colspan="4" class="vide">Aucune commande livrée.</td></tr>
                <% } else {
                    for (int i = 0; i < dernieresCommandes.size(); i++) {
                        String[] cmd = dernieresCommandes.get(i);
                %>
                    <tr>
                        <td><strong><%= cmd[0] != null ? cmd[0] : "—" %></strong></td>
                        <td><%= cmd[1] != null ? cmd[1] : "—" %></td>
                        <td class="montant-positif"><strong><%= cmd[2] %> Ar</strong></td>
                        <td><%= cmd[3] != null ? cmd[3].substring(0, Math.min(10, cmd[3].length())) : "—" %></td>
                    </tr>
                <%  }
                  } %>
                </tbody>
            </table>
        </div>
        <p class="lien-voir-tout">
            <a href="commande-list.jsp?statut=LIVREE">Voir toutes les commandes livrées →</a>
        </p>
    </div>

</div>

<%-- ══════════════════════════════════════════
     SCRIPT Chart.js pour le camembert
     Exécuté APRÈS le chargement du DOM
     ══════════════════════════════════════════ --%>
<% if (depenses > 0) { %>
<script>
(function() {
    var ctx = document.getElementById('camembert').getContext('2d');

    new Chart(ctx, {
        type: 'pie',
        data: {
            labels: ['Salaires payés', 'Achats matières premières'],
            datasets: [{
                // Les valeurs viennent des variables Java injectées ici :
                data: <%= pieData %>,
                backgroundColor: ['#2D6A6A', '#F97316'],
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

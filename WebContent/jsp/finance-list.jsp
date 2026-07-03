<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.FinanceDAO" %>
<%@ page import="java.util.ArrayList" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    FinanceDAO dao = new FinanceDAO();

    // ── Les 4 grands chiffres ──────────────────────────
    double ca         = dao.getChiffreAffairesTotal();    // CA = commandes LIVREES
    double salaires   = dao.getTotalSalairesPaies();      // dépenses = salaires PAYES
    double matieres   = dao.getTotalAchatsMatières();     // dépenses = valeur stock matières
    double depenses   = salaires + matieres;
    double margeNette = ca - depenses;
    int    nbCmd      = dao.getNbCommandesLivrees();

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
    String jsSalaires = String.format("%.2f", salaires).replace(",", ".");
    String jsMatieres = String.format("%.2f", matieres).replace(",", ".");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>One of One — Finances</title>
    <link rel="stylesheet" href="../css/global.css">
    <link rel="stylesheet" href="../css/finance.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
</head>
<body>

<div class="sidebar">
    <div class="sidebar-logo"><h2>One of One</h2><small>Management Suite</small></div>
    <nav>
        <a href="dashboard-admin.jsp">🏠 Home</a>
        <a href="stock-list.jsp">📦 Stock</a>
        <a href="produit-list.jsp">🛍 Produits</a>
        <a href="commande-list.jsp">🛒 Commandes</a>
        <a href="livraison-list.jsp">🚚 Livraisons</a>
        <a href="client-list.jsp">👥 Clients</a>
        <a href="employe-list.jsp">👔 Employés</a>
        <a href="finance-list.jsp" class="active">💰 Finances</a>
        <a href="salaire-list.jsp">💳 Salaires</a>
        <a href="graphiques.jsp">📊 Graphiques</a>
        <a href="ia.jsp">🤖 IA</a>
        <a href="notification-list.jsp">🔔 Notifs</a>
    </nav>
    <a href="logout.jsp" class="sidebar-logout">Se déconnecter</a>
</div>

<div class="main-content">

    <div class="page-header">
        <div>
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
                <h2><%= String.format("%,.2f", ca) %> €</h2>
                <p>Somme de toutes les commandes livrées (<%= nbCmd %> commandes)</p>
            </div>
        </div>

        <div class="kpi-card kpi-depenses">
            <div class="kpi-icone">💸</div>
            <div class="kpi-contenu">
                <small>DÉPENSES TOTALES</small>
                <h2><%= String.format("%,.2f", depenses) %> €</h2>
                <p>Salaires payés + achats matières premières</p>
            </div>
        </div>

        <div class="kpi-card kpi-marge">
            <div class="kpi-icone"><%= margeNette >= 0 ? "📈" : "📉" %></div>
            <div class="kpi-contenu">
                <small><%= margeLabel.toUpperCase() %></small>
                <h2 style="color:<%= margeCouleur %>">
                    <%= margeSymbole %> <%= String.format("%,.2f", Math.abs(margeNette)) %> €
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
                        <td><strong><%= String.format("%,.2f", salaires) %> €</strong></td>
                        <td>
                            <div class="barre-progress">
                                <div class="barre-remplie barre-salaires" style="width:<%= (int)pctSalaires %>%"></div>
                            </div>
                            <%= String.format("%.1f", pctSalaires) %>%
                        </td>
                    </tr>
                    <tr>
                        <td><span class="point-couleur point-matieres"></span> 🧵 Matières premières</td>
                        <td><strong><%= String.format("%,.2f", matieres) %> €</strong></td>
                        <td>
                            <div class="barre-progress">
                                <div class="barre-remplie barre-matieres" style="width:<%= (int)pctMatieres %>%"></div>
                            </div>
                            <%= String.format("%.1f", pctMatieres) %>%
                        </td>
                    </tr>
                    <tr class="ligne-total">
                        <td><strong>TOTAL</strong></td>
                        <td><strong><%= String.format("%,.2f", depenses) %> €</strong></td>
                        <td><strong>100%</strong></td>
                    </tr>
                </tbody>
            </table>

            <%-- Note transparence des calculs --%>
            <div class="note-calcul">
                <strong>📌 Calculs :</strong>
                <ul>
                    <li><b>CA</b> = SUM(quantite × prix_unitaire) des commandes <em>LIVREE</em></li>
                    <li><b>Salaires</b> = SUM(salaire_net) où statut = <em>PAYE</em></li>
                    <li><b>Matières</b> = SUM(quantite × valeur_unitaire) de la table matiere</li>
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
                    <td class="montant-positif"><strong><%= String.format("%,.2f", ca) %> €</strong></td>
                    <td><%= nbCmd %> commandes livrées (ligne_commande × commande LIVREE)</td>
                </tr>
                <tr>
                    <td>💼 Salaires payés</td>
                    <td class="montant-negatif">− <%= String.format("%,.2f", salaires) %> €</td>
                    <td>SUM(salaire_net) où statut = PAYE</td>
                </tr>
                <tr>
                    <td>🧵 Achats matières premières</td>
                    <td class="montant-negatif">− <%= String.format("%,.2f", matieres) %> €</td>
                    <td>SUM(quantite × valeur_unitaire) dans la table matiere</td>
                </tr>
                <tr class="ligne-separateur">
                    <td>💸 Dépenses totales</td>
                    <td class="montant-negatif"><strong>− <%= String.format("%,.2f", depenses) %> €</strong></td>
                    <td>Salaires + Matières</td>
                </tr>
                <tr class="ligne-marge-finale">
                    <td><strong><%= margeLabel %></strong></td>
                    <td style="color:<%= margeCouleur %>; font-size:1.1rem;">
                        <strong><%= margeSymbole %> <%= String.format("%,.2f", Math.abs(margeNette)) %> €</strong>
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
                        <td class="montant-positif"><strong><%= cmd[2] %> €</strong></td>
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
                data: [ <%= jsSalaires %>, <%= jsMatieres %> ],
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
                            return ctx.label + ' : ' + val + ' € (' + pct + '%)';
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

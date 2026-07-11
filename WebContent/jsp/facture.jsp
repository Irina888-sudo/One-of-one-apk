<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Salaire, dao.SalaireDAO, dao.EmployeDAO" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Facture de Salaire - OneOfOne</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/facture.css">
</head>
<body>

    <%!
        String genererNumeroFacture(Salaire salaire) {
            int annee = salaire.getMois().getYear();
            int id = salaire.getId();
            return "FAC-" + annee + "-" + String.format("%04d", id);
        }
    %>
    <%
        String idStr = request.getParameter("id");
        Salaire salaire = null;
        String errorMessage = null;
        String numeroFacture = "-";

        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                salaire = new SalaireDAO().findById(id);
                numeroFacture = genererNumeroFacture(salaire);
            } catch (Exception e) {
                errorMessage = "Erreur: " + e.getMessage();
            }
        }
    %>

    <% if (salaire == null) { %>
        <p style="color:red; text-align:center; padding:40px;">Salaire introuvable. <%= errorMessage != null ? errorMessage : "" %></p>
    <% } else { %>

    <div class="btn-bar">
        <button class="btn-print" onclick="window.print()">🖨 Imprimer / PDF</button>
        <button class="btn-back" onclick="window.location.href='salaire-list.jsp'">← Retour</button>
    </div>

    <div class="facture-wrapper">
        <div class="facture-container">

            <div class="facture-header">
                <div class="header-left">
                    <div class="enseigne">ONE OF ONE</div>
                    <div class="enseigne-sub">Management Suite</div>
                    <div class="enseigne-addr">Antananarivo, Madagascar</div>
                </div>
                <div class="header-right">
                    <div class="facture-label">FACTURE DE SALAIRE</div>
                    <div class="facture-ref">N° <strong><%= numeroFacture %></strong></div>
                    <div class="facture-date">Date : <strong><%= java.time.LocalDate.now() %></strong></div>
                </div>
            </div>

            <div class="info-section">
                <div class="info-row">
                    <span class="info-label">Employé</span>
                    <span class="info-value"><%= EmployeDAO.getNomEmployeById(salaire.getEmployeId()) %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Rôle</span>
                    <span class="info-value"><%= EmployeDAO.getRoleById(salaire.getEmployeId()) %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Période</span>
                    <span class="info-value"><%= Salaire.formatMois(salaire.getMois()) %></span>
                </div>
            </div>

            <table class="detail">
                <thead>
                    <tr>
                        <th>Libellé</th>
                        <th class="montant-th">Montant</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Salaire Brut</td>
                        <td class="montant-td"><%= String.format("%,.2f", salaire.getSalaireBrut()) %> Ar</td>
                    </tr>
                    <tr>
                        <td>Déductions</td>
                        <td class="montant-td"><%= String.format("%,.2f", salaire.getSalaireBrut().subtract(salaire.getSalaireNet())) %> Ar</td>
                    </tr>
                    <tr class="tr-total">
                        <td><strong>Salaire Net à payer</strong></td>
                        <td class="montant-net"><strong><%= String.format("%,.2f", salaire.getSalaireNet()) %> Ar</strong></td>
                    </tr>
                </tbody>
            </table>

            <div class="statut-row">
                <span class="statut-badge <%= salaire.getStatut() %>"><%= salaire.getStatut() %></span>
            </div>

            <div class="signature-section">
                <div class="signature-box">
                    <span class="signature-label">Cachet et signature</span>
                    <div class="signature-line"></div>
                </div>
            </div>

        </div>
    </div>

    <% } %>

</body>
</html>

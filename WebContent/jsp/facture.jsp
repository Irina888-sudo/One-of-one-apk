<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Salaire, dao.SalaireDAO, dao.EmployeDAO" %>
<!DOCTYPE html>
<html lang="fr">
  <link rel="stylesheet" href="../css/facture.css">
<head>
    <meta charset="UTF-8">
    <title>Facture de Salaire - OneOfOne</title>
    
</head>
<body>

    <button class="btn-print" onclick="window.print()">🖨️ Imprimer / Enregistrer en PDF</button>

    <div class="facture-container">

        <%!
            // Écrite par Mihaja
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
            <p style="color:red;">Salaire introuvable. <%= errorMessage != null ? errorMessage : "" %></p>
        <% } else { %>

            <div class="facture-header">
                <div>
                    <p class="entreprise-nom">One Of One</p>
                    <p class="entreprise-sub">Gestion &amp; Services — Antananarivo, Madagascar</p>
                </div>
                <div class="facture-meta">
                    <div>N° Facture : <strong><%= numeroFacture %></strong></div>
                    <div>Date d'émission : <strong><%= java.time.LocalDate.now() %></strong></div>
                </div>
            </div>

            <p class="facture-titre">Facture de Salaire</p>

            <table class="detail">
                <tr>
                    <th>Employé</th>
                    <td><%= EmployeDAO.getNomEmployeById(salaire.getEmployeId()) %></td>
                </tr>
                <tr>
                    <th>Rôle</th>
                    <td><%= EmployeDAO.getRoleById(salaire.getEmployeId()) %></td>
                </tr>
                <tr>
                    <th>Mois</th>
                    <td><%= Salaire.formatMois(salaire.getMois()) %></td>
                </tr>
                <tr>
                    <th>Salaire Brut</th>
                    <td><%= String.format("%,.2f", salaire.getSalaireBrut()) %> Ariary</td>
                </tr>
                <tr>
                    <th>Salaire Net</th>
                    <td class="montant-net"><%= String.format("%,.2f", salaire.getSalaireNet()) %> Ariary</td>
                </tr>
                <tr>
                    <th>Statut</th>
                    <td><span class="statut-badge"><%= salaire.getStatut() %></span></td>
                </tr>
            </table>

        <% } %>

        <div class="facture-footer">
            Document généré automatiquement par OneOfOne — Ne nécessite pas de signature.
        </div>
    </div>

</body>
</html>
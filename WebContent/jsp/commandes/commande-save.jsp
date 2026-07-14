<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/jsp/auth/check-auth.jsp" %>
<%@ page import="dao.CommandeDAO" %>
<%@ page import="model.Commande" %>
<%@ page import="model.LigneCommande" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
    String idStr = request.getParameter("id");
    String numero = request.getParameter("numero");
    String clientIdStr = request.getParameter("clientId");
    String statut = request.getParameter("statut");
    String dateCommandeStr = request.getParameter("dateCommande");
    String[] produitIds = request.getParameterValues("produitId");
    String[] quantites = request.getParameterValues("quantite");
    String[] prixUnitaires = request.getParameterValues("prixUnitaire");

    boolean isEdit = (idStr != null && !idStr.trim().isEmpty());
    String erreur = null;
    int clientId = 0;
    Timestamp dateCommande = null;

    if (numero == null || numero.isBlank()) {
        numero = "ORD-" + new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date());
    }

    if (clientIdStr == null || clientIdStr.isBlank()) {
        erreur = "Le client est obligatoire.";
    } else if (dateCommandeStr == null || dateCommandeStr.isBlank()) {
        erreur = "La date de commande est obligatoire.";
    } else if (produitIds == null || produitIds.length == 0) {
        erreur = "La commande doit contenir au moins un produit.";
    } else {
        try {
            clientId = Integer.parseInt(clientIdStr);
        } catch (NumberFormatException e) {
            erreur = "Le client selectionne n'est pas valide.";
        }

        if (erreur == null) {
            try {
                String dateTime = dateCommandeStr.replace('T', ' ').trim();
                if (dateTime.length() == 16) {
                    dateTime += ":00"; // datetime-local fournit minutes seulement
                }
                dateCommande = Timestamp.valueOf(dateTime);
            } catch (IllegalArgumentException e) {
                erreur = "Le format de la date de commande est invalide.";
            }
        }
    }

    List<LigneCommande> lignes = new ArrayList<>();
    if (erreur == null) {
        for (int i = 0; i < produitIds.length; i++) {
            String prodId = produitIds[i];
            String quantite = quantites != null && i < quantites.length ? quantites[i] : "";
            String prixUnit = prixUnitaires != null && i < prixUnitaires.length ? prixUnitaires[i] : "";
            if (prodId == null || prodId.isBlank()) {
                continue;
            }
            try {
                LigneCommande ligne = new LigneCommande();
                ligne.setProduitId(Integer.parseInt(prodId));
                ligne.setQuantite(Integer.parseInt(quantite));
                ligne.setPrixUnitaire(Double.parseDouble(prixUnit));
                lignes.add(ligne);
            } catch (NumberFormatException e) {
                erreur = "Les lignes de commande contiennent des valeurs invalides.";
                break;
            }
        }
        if (erreur == null && lignes.isEmpty()) {
            erreur = "La commande doit contenir au moins un produit valide.";
        }
    }

    if (erreur != null) {
        request.setAttribute("erreur", erreur);
        request.getRequestDispatcher(isEdit ? "commande-form.jsp?id=" + idStr : "commande-form.jsp").forward(request, response);
        return;
    }

    Commande commande = new Commande();
    if (isEdit) {
        commande.setId(Integer.parseInt(idStr));
    }
    commande.setNumero(numero.trim());
    commande.setClientId(clientId);
    commande.setStatut(statut != null ? statut : "ATTENTE");
    commande.setDateCommande(dateCommande);
    commande.setLignes(lignes);

    CommandeDAO dao = new CommandeDAO();
    try {
        if (isEdit) {
            dao.modifier(commande);
            session.setAttribute("flash", "Commande modifiee avec succes.");
        } else {
            dao.ajouter(commande);
            session.setAttribute("flash", "Commande ajoutee avec succes.");
        }
        session.setAttribute("flashType", "success");
        response.sendRedirect("commandes.jsp");
    } catch (Exception e) {
        request.setAttribute("erreur", "Erreur SQL : " + e.getMessage());
        request.getRequestDispatcher(isEdit ? "commande-form.jsp?id=" + idStr : "commande-form.jsp").forward(request, response);
    }
%>

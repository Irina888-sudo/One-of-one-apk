<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.ProduitDAO" %>
<%@ page import="model.Produit" %>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.nio.file.Files" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="java.nio.file.StandardCopyOption" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%
    String idParam  = request.getParameter("id");
    String nom      = request.getParameter("nom");
    String categorie= request.getParameter("categorie");
    String prixStr  = request.getParameter("prix");
    String taille   = request.getParameter("taille");
    String couleur  = request.getParameter("couleur");
    String statut   = request.getParameter("statut");
    String colIdStr = request.getParameter("collection_id");
    String imageActuelle = request.getParameter("image_actuelle");
    // valeur précédente

    // ── Validation basique ───────────────────────────────
    if (nom == null || nom.isBlank() || prixStr == null || prixStr.isBlank()) {
        request.setAttribute("erreur", "Le nom et le prix sont obligatoires.");
        request.getRequestDispatcher(idParam != null
        ? "produit-form.jsp?id=" + idParam
        : "produit-form.jsp").forward(request, response);
        return;
    }

    double prix;
    try {
        prix = Double.parseDouble(prixStr);
        if (prix < 0) throw new NumberFormatException();
    } catch (NumberFormatException e) {
        request.setAttribute("erreur", "Le prix doit être un nombre positif.");
        request.getRequestDispatcher(idParam != null
        ? "produit-form.jsp?id=" + idParam
        : "produit-form.jsp").forward(request, response);
        return;
    }

    // ── Traitement de l'upload ───────────────────────────
    String imagePath = imageActuelle;
    // conserver l'ancienne image par défaut

    Part filePart = request.getPart("image");
    if (filePart != null && filePart.getSize() > 0) {
        // Récupérer le nom du fichier original
        String originalName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String extension = "";
        int dotIdx = originalName.lastIndexOf('.');
        if (dotIdx >= 0) extension = originalName.substring(dotIdx);
        // ex: ".jpg"

        // Générer un nom unique pour éviter les conflits
        String uniqueName = UUID.randomUUID().toString() + extension;

        // Dossier de stockage absolu (dans WebContent/assets/img/)
        String uploadDir = application.getRealPath("") + File.separator
        + "assets" + File.separator + "img";
        File uploadFolder = new File(uploadDir);
        if (!uploadFolder.exists()) uploadFolder.mkdirs();

        // Copier le fichier sur le disque
        File destFile = new File(uploadFolder, uniqueName);
        try (InputStream in = filePart.getInputStream()) {
            Files.copy(in, destFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
        }

        // Seul le nom du fichier est stocké en base
        imagePath = uniqueName;
    }

    // ── Construction du model ─────────────────────────────
    Produit p = new Produit();
    p.setNom(nom.trim());
    p.setCategorie(categorie != null && !categorie.isBlank() ? categorie.trim() : null);
    p.setPrix(prix);
    p.setTaille(taille != null && !taille.isBlank() ? taille.trim() : null);
    p.setCouleur(couleur != null && !couleur.isBlank() ? couleur.trim() : null);
    p.setStatut(statut != null ? statut : "DISPONIBLE");
    p.setCollectionId(colIdStr != null && !colIdStr.isBlank() ? Integer.parseInt(colIdStr) : null);
    p.setImage(imagePath);

    ProduitDAO dao = new ProduitDAO();
    boolean isEdit = (idParam != null && !idParam.isBlank());

    // ── Traitement des matières premières (si création) ──
    List<Integer> matiereIds = new java.util.ArrayList<>();
    List<Double> quantites = new java.util.ArrayList<>();
    
    if (!isEdit) {
        String[] matiereIdsParam = request.getParameterValues("matiereId");
        String[] quantitesParam = request.getParameterValues("quantiteMatiere");
        
        if (matiereIdsParam != null && quantitesParam != null) {
            for (int i = 0; i < matiereIdsParam.length; i++) {
                String mIdStr = matiereIdsParam[i];
                String qtyStr = i < quantitesParam.length ? quantitesParam[i] : "";
                
                if (mIdStr == null || mIdStr.isBlank()) {
                    continue;
                }
                
                int mId;
                double qty;
                try {
                    mId = Integer.parseInt(mIdStr);
                } catch (NumberFormatException e) {
                    request.setAttribute("erreur", "Matière invalide.");
                    request.getRequestDispatcher("produit-form.jsp").forward(request, response);
                    return;
                }
                
                try {
                    qty = Double.parseDouble(qtyStr);
                    if (qty <= 0) {
                        throw new NumberFormatException();
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("erreur", "La quantité utilisée pour chaque matière doit être un nombre strictement positif.");
                    request.getRequestDispatcher("produit-form.jsp").forward(request, response);
                    return;
                }
                
                if (matiereIds.contains(mId)) {
                    request.setAttribute("erreur", "Une matière ne peut pas être sélectionnée plusieurs fois.");
                    request.getRequestDispatcher("produit-form.jsp").forward(request, response);
                    return;
                }
                
                matiereIds.add(mId);
                quantites.add(qty);
            }
        }
    }

    try {
        if (isEdit) {
            p.setId(Integer.parseInt(idParam));
            dao.modifier(p);
            session.setAttribute("flash", "Produit modifié avec succès.");
        } else {
            dao.ajouter(p, matiereIds, quantites);
            session.setAttribute("flash", "Produit ajouté avec succès.");
        }
        session.setAttribute("flashType", "success");
        response.sendRedirect("produits.jsp");
    } catch (Exception e) {
        request.setAttribute("erreur", "Erreur : " + e.getMessage());
        request.getRequestDispatcher(isEdit ? "produit-form.jsp?id=" + idParam : "produit-form.jsp").forward(request, response);
    }

%>

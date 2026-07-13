<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.File, java.io.FileInputStream, java.io.OutputStream" %>
<%@ page import="java.nio.file.Files" %>
<%
    String rawName = request.getParameter("name");
    
    // Verifier si le parametre est present
    if (rawName == null || rawName.isBlank()) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }

    // Decoder le nom envoye (securiser contre l'url-encoding)
    String name = java.net.URLDecoder.decode(rawName, "UTF-8");

    // Determiner dynamiquement le dossier d'uploads (même logique que produit-save.jsp)
    File webappRoot = new File(application.getRealPath(""));
    File externalUploads = new File(webappRoot.getParentFile(), "uploads" + File.separator + "img");
    File imageFile = new File(externalUploads, name);
    
    // Verifier si le fichier existe
    if (!imageFile.exists()) {
        // Log pour deboguer
        application.log("Image non trouvee : " + imageFile.getAbsolutePath());
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }
    
    // Determiner le type MIME en fonction de l'extension
    String contentType = getServletContext().getMimeType(imageFile.getName());
    if (contentType == null || contentType.isEmpty()) {
        // Si le type MIME n'est pas detecte, on le definit manuellement
        String fileName = imageFile.getName().toLowerCase();
        if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) {
            contentType = "image/jpeg";
        } else if (fileName.endsWith(".png")) {
            contentType = "image/png";
        } else if (fileName.endsWith(".gif")) {
            contentType = "image/gif";
        } else if (fileName.endsWith(".webp")) {
            contentType = "image/webp";
        } else {
            contentType = "image/jpeg"; // Par defaut
        }
    }
    
    // Configurer la reponse
    response.setContentType(contentType);
    try {
        response.setContentLengthLong(imageFile.length());
    } catch (NoSuchMethodError ignore) {
        // fallback for older servlet API implementations
        response.setHeader("Content-Length", String.valueOf(imageFile.length()));
    }
    response.setHeader("Cache-Control", "public, max-age=3600"); // Cache 1 heure
    
    // Envoyer le fichier
    try (FileInputStream fis = new FileInputStream(imageFile);
         OutputStream os = response.getOutputStream()) {
        
        byte[] buffer = new byte[4096];
        int bytesRead;
        while ((bytesRead = fis.read(buffer)) != -1) {
            os.write(buffer, 0, bytesRead);
        }
        os.flush();
    } catch (Exception e) {
        // Log l'erreur
        application.log("Erreur lors de l'envoi de l'image : " + e.getMessage(), e);
        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    }
%>
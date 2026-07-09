<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Properties" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ page import="dao.SalaireDAO, dao.EmployeDAO, model.Salaire, model.Employe, util.DBConnection" %>
<%@ page import="java.sql.Connection" %>
<%
response.setContentType("application/json;charset=UTF-8");
String salaireId = request.getParameter("id");
Connection conn = null;
try {
    if (salaireId == null || salaireId.isEmpty()) {
        out.print("{\"success\":false,\"message\":\"ID manquant\"}");
        return;
    }

    conn = DBConnection.getConnection();
    SalaireDAO salaireDAO = new SalaireDAO(conn);
    Salaire salaire = salaireDAO.findById(Integer.parseInt(salaireId));

    if (salaire == null) {
        out.print("{\"success\":false,\"message\":\"Salaire introuvable\"}");
        return;
    }

    EmployeDAO employeDAO = new EmployeDAO();
    Employe employe = employeDAO.getEmployeById(salaire.getEmployeId());

    if (employe == null || employe.getEmail() == null || employe.getEmail().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Employé ou email introuvable\"}");
        return;
    }

    String from = "rakotovaoteo@gmail.com";
    String pass = "icsqqgglnwoqbbto";

    Properties props = new Properties();
    props.put("mail.smtp.host", "smtp.gmail.com");
    props.put("mail.smtp.port", "587");
    props.put("mail.smtp.auth", "true");
    props.put("mail.smtp.starttls.enable", "true");
    props.put("mail.smtp.starttls.required", "true");

    Session mailSession = Session.getInstance(props, new Authenticator() {
        @Override
        protected PasswordAuthentication getPasswordAuthentication() {
            return new PasswordAuthentication(from, pass);
        }
    });

    Message message = new MimeMessage(mailSession);
    message.setFrom(new InternetAddress(from));
    message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(employe.getEmail()));
    message.setSubject("Fiche de salaire");

    java.text.NumberFormat currency = java.text.NumberFormat.getCurrencyInstance(new java.util.Locale("fr", "FR"));
    String moisLabel = salaire.getMois() != null ? salaire.getMois().format(java.time.format.DateTimeFormatter.ofPattern("MMMM yyyy", new java.util.Locale("fr", "FR"))) : "-";
    String brut = currency.format(salaire.getSalaireBrut() != null ? salaire.getSalaireBrut() : java.math.BigDecimal.ZERO);
    String net = currency.format(salaire.getSalaireNet() != null ? salaire.getSalaireNet() : java.math.BigDecimal.ZERO);

    String html = "<html><body style='font-family:Arial,sans-serif;line-height:1.6;'>"
            + "<p>Bonjour <strong>" + (employe.getNom() != null ? employe.getNom() : "") + "</strong>,</p>"
            + "<p>Voici votre fiche de salaire pour <strong>" + moisLabel + "</strong>.</p>"
            + "<table style='border-collapse:collapse;width:100%;max-width:480px;'>"
            + "<tr><th style='border:1px solid #ddd;padding:8px;text-align:left;background:#f5f5f5;'>Détail</th><th style='border:1px solid #ddd;padding:8px;text-align:left;background:#f5f5f5;'>Valeur</th></tr>"
            + "<tr><td style='border:1px solid #ddd;padding:8px;'>Salaire brut</td><td style='border:1px solid #ddd;padding:8px;'>" + brut + "</td></tr>"
            + "<tr><td style='border:1px solid #ddd;padding:8px;'>Salaire net</td><td style='border:1px solid #ddd;padding:8px;'>" + net + "</td></tr>"
            + "<tr><td style='border:1px solid #ddd;padding:8px;'>Statut</td><td style='border:1px solid #ddd;padding:8px;'>" + (salaire.getStatut() != null ? salaire.getStatut() : "-") + "</td></tr>"
            + "</table>"
            + "<p>Merci,<br/>L'équipe One of One</p>"
            + "</body></html>";
    message.setContent(html, "text/html; charset=utf-8");

    Transport.send(message);
    out.print("{\"success\":true,\"message\":\"Email envoyé\"}");
} catch (Exception ex) {
    out.print("{\"success\":false,\"message\":\"Erreur: " + ex.getMessage().replace("\"", "'") + "\"}");
} finally {
    if (conn != null) {
        try { conn.close(); } catch (Exception ignored) {}
    }
}
%>
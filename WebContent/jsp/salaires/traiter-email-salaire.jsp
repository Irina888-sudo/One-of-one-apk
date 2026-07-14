<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/jsp/auth/check-auth.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ page import="dao.SalaireDAO, dao.EmployeDAO, model.Salaire, model.Employe, util.DBConnection" %>
<%@ page import="java.sql.Connection" %>
<%
response.setContentType("application/json;charset=UTF-8");
String salaireId = request.getParameter("id");
Connection conn = null;

System.out.println("=== DEBUT EMAIL SEND ===");

try {
    if (salaireId == null || salaireId.isEmpty()) {
        System.out.println("ERREUR: ID salaire manquant");
        out.print("{\"success\": false, \"message\": \"ID salaire manquant\"}");
        return;
    }
    
    System.out.println("Recuperation du salaire avec ID: " + salaireId);
    
    conn = DBConnection.getConnection();
    SalaireDAO salaireDAO = new SalaireDAO(conn);
    Salaire salaire = salaireDAO.findById(Integer.parseInt(salaireId));
    
    if (salaire == null) {
        System.out.println("ERREUR: Salaire non trouve");
        out.print("{\"success\": false, \"message\": \"Salaire non trouve\"}");
        return;
    }
    
    System.out.println("Salaire trouve. EmployeId: " + salaire.getEmployeId());
    
    EmployeDAO employeDAO = new EmployeDAO();
    Employe employe = employeDAO.getEmployeById(salaire.getEmployeId());
    
    if (employe == null) {
        System.out.println("ERREUR: Employe non trouve");
        out.print("{\"success\": false, \"message\": \"Employe non trouve\"}");
        return;
    }
    
    System.out.println("Employe trouve: " + employe.getNom());
    System.out.println("Email: " + employe.getEmail());
    
    if (employe.getEmail() == null || employe.getEmail().isEmpty()) {
        System.out.println("ERREUR: Email vide");
        out.print("{\"success\": false, \"message\": \"Email de l'employe est vide\"}");
        return;
    }
    
    String emailSender = "rakotovaoteo@gmail.com";
    String passwordApp = "icsqqgglnwoqbbto";
    
    System.out.println("Configuration SMTP - FROM: " + emailSender);
    
    Properties props = new Properties();
    props.put("mail.smtp.host", "smtp.gmail.com");
    props.put("mail.smtp.port", "587");
    props.put("mail.smtp.auth", "true");
    props.put("mail.smtp.starttls.enable", "true");
    props.put("mail.smtp.starttls.required", "true");
    
    System.out.println("Proprietes SMTP configurees");
    
    final String finalEmail = emailSender;
    final String finalPassword = passwordApp;
    
    Session mailSession = Session.getInstance(props, new Authenticator() {
        protected PasswordAuthentication getPasswordAuthentication() {
            return new PasswordAuthentication(finalEmail, finalPassword);
        }
    });
    
    System.out.println("Session creee");
    
    Message message = new MimeMessage(mailSession);
    message.setFrom(new InternetAddress(emailSender));
    message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(employe.getEmail()));
    message.setSubject("Fiche de Salaire - " + Salaire.formatMois(salaire.getMois()));
    
    System.out.println("Message prepare - TO: " + employe.getEmail());
    
    double salaireBrut = salaire.getSalaireBrut() != null ? salaire.getSalaireBrut().doubleValue() : 0;
    double salairNet = salaire.getSalaireNet() != null ? salaire.getSalaireNet().doubleValue() : 0;
    double charges = salaireBrut - salairNet;
    
    String htmlContent = "<html><body>Salaire Brut: " + salaireBrut + " Ariary<br/>Salaire Net: " + salairNet + " Ariary</body></html>";
    
    message.setContent(htmlContent, "text/html; charset=utf-8");
    
    System.out.println("Contenu HTML prepare");
    System.out.println("Tentative d'envoi...");
    
    Transport.send(message);
    
    System.out.println("Email envoye avec succes");
    out.print("{\"success\": true, \"message\": \"Email envoye a " + employe.getEmail() + "\"}");
    
} catch (MessagingException e) {
    System.err.println("MessagingException: " + e.getMessage());
    e.printStackTrace();
    out.print("{\"success\": false, \"message\": \"Erreur SMTP: " + e.getMessage() + "\"}");
} catch (Exception e) {
    System.err.println("Exception: " + e.getMessage());
    e.printStackTrace();
    out.print("{\"success\": false, \"message\": \"Erreur: " + e.getMessage() + "\"}");
} finally {
    try {
        if (conn != null) conn.close();
    } catch (Exception ignored) {}
}
%>

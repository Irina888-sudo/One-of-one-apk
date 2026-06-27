package model;

import java.math.BigDecimal;
import java.sql.Date;

public class Employe {
    private int id;
    private Integer utilisateurId;
    private String nom;
    private String email;
    private String telephone;
    private String role;
    private BigDecimal salaireBrut;
    private String statut;
    private Date dateEmbauche;
    
    public Employe() {}
    
    public Employe(int id, Integer utilisateurId, String nom, String email, String telephone, 
                   String role, BigDecimal salaireBrut, String statut, Date dateEmbauche) {
        this.id = id;
        this.utilisateurId = utilisateurId;
        this.nom = nom;
        this.email = email;
        this.telephone = telephone;
        this.role = role;
        this.salaireBrut = salaireBrut;
        this.statut = statut;
        this.dateEmbauche = dateEmbauche;
    }
    
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public Integer getUtilisateurId() { return utilisateurId; }
    public void setUtilisateurId(Integer utilisateurId) { this.utilisateurId = utilisateurId; }
    
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public BigDecimal getSalaireBrut() { return salaireBrut; }
    public void setSalaireBrut(BigDecimal salaireBrut) { this.salaireBrut = salaireBrut; }
    
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
    
    public Date getDateEmbauche() { return dateEmbauche; }
    public void setDateEmbauche(Date dateEmbauche) { this.dateEmbauche = dateEmbauche; }
}
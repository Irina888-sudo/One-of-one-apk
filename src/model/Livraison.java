package model;

import java.sql.Date;

public class Livraison {

    private int id;
    private String numero;

    private int commandeId;
    private Integer employeId;

    private String livreur;
    private String lieu;

    private double frais;

    private String statut;

    private Date dateLivraison;

    public Livraison() {}

    public Livraison(int id, String numero, int commandeId, Integer employeId,
                     String livreur, String lieu, double frais,
                     String statut, Date dateLivraison) {
        this.id = id;
        this.numero = numero;
        this.commandeId = commandeId;
        this.employeId = employeId;
        this.livreur = livreur;
        this.lieu = lieu;
        this.frais = frais;
        this.statut = statut;
        this.dateLivraison = dateLivraison;
    }

    // 🔹 GETTERS (OBLIGATOIRES pour JSP)
    public int getId() { return id; }

    public String getNumero() { return numero; }

    public String getCommandeId() { return "#ORD-" + (commandeId); }

    public Integer getEmployeId() { return employeId; }

    public String getLivreur() { return livreur; }

    public String getLieu() { return lieu; }

    public double getFrais() { return frais; }

    public String getStatut() { return statut; }

    public Date getDateLivraison() { return dateLivraison; }

    // 🔹 SETTERS
    public void setId(int id) { this.id = id; }

    public void setNumero(String numero) { this.numero = numero; }

    public void setCommandeId(int commandeId) { this.commandeId = commandeId; }

    public void setEmployeId(Integer employeId) { this.employeId = employeId; }

    public void setLivreur(String livreur) { this.livreur = livreur; }

    public void setLieu(String lieu) { this.lieu = lieu; }

    public void setFrais(double frais) { this.frais = frais; }

    public void setStatut(String statut) { this.statut = statut; }

    public void setDateLivraison(Date dateLivraison) { this.dateLivraison = dateLivraison; }

}

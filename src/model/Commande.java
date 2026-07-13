package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Commande {
    private int id;
    private String numero;
    private int clientId;
    private String clientNom;
    private String clientEmail;
    private String produits;
    private String statut;
    private double montantTotal;
    private Timestamp dateCommande;
    private List<LigneCommande> lignes = new ArrayList<>();

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNumero() {
        return numero;
    }

    public void setNumero(String numero) {
        this.numero = numero;
    }

    public int getClientId() {
        return clientId;
    }

    public void setClientId(int clientId) {
        this.clientId = clientId;
    }

    public String getClientNom() {
        return clientNom;
    }

    public void setClientNom(String clientNom) {
        this.clientNom = clientNom;
    }

    public String getClientEmail() {
        return clientEmail;
    }

    public void setClientEmail(String clientEmail) {
        this.clientEmail = clientEmail;
    }

    public String getProduits() {
        return produits;
    }

    public void setProduits(String produits) {
        this.produits = produits;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public String getStatutAffichage() {
        if (statut == null) return "Inconnu";
        switch (statut) {
            case "ATTENTE": return "En attente";
            case "PRODUCTION": return "En production";
            case "LIVREE": return "Livree";
            case "ANNULEE": return "Annulee";
            default: return statut;
        }
    }

    public double getMontantTotal() {
        return montantTotal;
    }

    public void setMontantTotal(double montantTotal) {
        this.montantTotal = montantTotal;
    }

    public Timestamp getDateCommande() {
        return dateCommande;
    }

    public void setDateCommande(Timestamp dateCommande) {
        this.dateCommande = dateCommande;
    }

    public List<LigneCommande> getLignes() {
        return lignes;
    }

    public void setLignes(List<LigneCommande> lignes) {
        this.lignes = lignes;
    }

    public void ajouterLigne(LigneCommande ligne) {
        this.lignes.add(ligne);
    }

    public double calculerMontantTotal() {
        double total = 0.0;
        for (LigneCommande ligne : lignes) {
            total += ligne.getMontantLigne();
        }
        return total;
    }
}

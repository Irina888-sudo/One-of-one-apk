package model;

public class StatistiqueMensuelle {
    private int mois;
    private double chiffreAffaires;
    private double depenses;
    private double stockMatieres;
    private int nombreCommandes;

    public StatistiqueMensuelle() {
    }

    public StatistiqueMensuelle(int mois) {
        this.mois = mois;
        this.chiffreAffaires = 0.0;
        this.depenses = 0.0;
        this.stockMatieres = 0.0;
        this.nombreCommandes = 0;
    }

    public int getMois() {
        return mois;
    }

    public void setMois(int mois) {
        this.mois = mois;
    }

    public double getChiffreAffaires() {
        return chiffreAffaires;
    }

    public void setChiffreAffaires(double chiffreAffaires) {
        this.chiffreAffaires = chiffreAffaires;
    }

    public double getDepenses() {
        return depenses;
    }

    public void setDepenses(double depenses) {
        this.depenses = depenses;
    }

    public double getStockMatieres() {
        return stockMatieres;
    }

    public void setStockMatieres(double stockMatieres) {
        this.stockMatieres = stockMatieres;
    }

    public int getNombreCommandes() {
        return nombreCommandes;
    }

    public void setNombreCommandes(int nombreCommandes) {
        this.nombreCommandes = nombreCommandes;
    }
}

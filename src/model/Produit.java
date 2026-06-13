package model;

public class Produit {
    private int id;
    private String nom;
    private String categorie;
    private String taille;
    private String couleur;
    private double prix;
    private String statut; // DISPONIBLE | VENDU
    private Integer collectionId;
    private String collectionNom; // from JOIN

    public Produit() {
    }

    // ── Getters / Setters ──────────────────────────────────
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getCategorie() {
        return categorie;
    }

    public void setCategorie(String categorie) {
        this.categorie = categorie;
    }

    public String getTaille() {
        return taille;
    }

    public void setTaille(String taille) {
        this.taille = taille;
    }

    public String getCouleur() {
        return couleur;
    }

    public void setCouleur(String couleur) {
        this.couleur = couleur;
    }

    public double getPrix() {
        return prix;
    }

    public void setPrix(double prix) {
        this.prix = prix;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public Integer getCollectionId() {
        return collectionId;
    }

    public void setCollectionId(Integer collectionId) {
        this.collectionId = collectionId;
    }

    public String getCollectionNom() {
        return collectionNom;
    }

    public void setCollectionNom(String collectionNom) {
        this.collectionNom = collectionNom;
    }

    /** Génère un SKU d'affichage type OOO-24-001 */
    public String getSku() {
        return String.format("OOO-24-%03d", id);
    }

    /** Initiales pour l'avatar couleur (2 premières lettres du nom) */
    public String getInitiales() {
        if (nom == null || nom.isEmpty())
            return "??";
        String[] parts = nom.trim().split("\\s+");
        if (parts.length == 1)
            return nom.substring(0, Math.min(2, nom.length())).toUpperCase();
        return ("" + parts[0].charAt(0) + parts[1].charAt(0)).toUpperCase();
    }
}

package model;

/**
 * Modèle Java représentant un enregistrement de la table `matiere`.
 */
public class Matiere {

    private int id;
    private String nom;
    private String description;
    private int quantite;
    private String unite;
    private String statut;
    private String createdAt;

    public Matiere() {}

    public Matiere(int id, String nom, String description, int quantite,
                   String unite, String statut, String createdAt) {
        this.id = id;
        this.nom = nom;
        this.description = description;
        this.quantite = quantite;
        this.unite = unite;
        this.statut = statut;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public String getNom() { return nom; }
    public String getDescription() { return description; }
    public int getQuantite() { return quantite; }
    public String getUnite() { return unite; }
    public String getStatut() { return statut; }
    public String getCreatedAt() { return createdAt; }

    public void setId(int id) { this.id = id; }
    public void setNom(String nom) { this.nom = nom; }
    public void setDescription(String description) { this.description = description; }
    public void setQuantite(int quantite) { this.quantite = quantite; }
    public void setUnite(String unite) { this.unite = unite; }
    public void setStatut(String statut) { this.statut = statut; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "Matiere{id=" + id + ", nom='" + nom + "', quantite=" + quantite + "}";
    }
}

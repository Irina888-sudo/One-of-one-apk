package model;

/**
 * Modele Java representant un enregistrement de la table `client`.
 *
 * Chaque attribut correspond à une colonne de la table :
 *   id, nom, email, telephone, adresse, statut, motif_blocage, created_at
 */
public class Client {

    // ── Attributs (colonnes de la table) ───────────────────────────────────
    private int    id;
    private String nom;
    private String email;
    private String telephone;
    private String adresse;
    private String statut;        // 'ACTIF' ou 'BLOQUE'
    private String motifBlocage;  // rempli seulement si statut = BLOQUE
    private String createdAt;     // date de creation (stockee en String pour simplifier l'affichage JSP)

    // ── Constructeur vide (obligatoire pour creer un objet avant de le remplir) ──
    public Client() {}

    // ── Constructeur complet (pratique pour creer un client depuis la BDD) ──
    public Client(int id, String nom, String email, String telephone,
                  String adresse, String statut, String motifBlocage, String createdAt) {
        this.id           = id;
        this.nom          = nom;
        this.email        = email;
        this.telephone    = telephone;
        this.adresse      = adresse;
        this.statut       = statut;
        this.motifBlocage = motifBlocage;
        this.createdAt    = createdAt;
    }

    // ── Getters ────────────────────────────────────────────────────────────
    public int    getId()           { return id; }
    public String getNom()          { return nom; }
    public String getEmail()        { return email; }
    public String getTelephone()    { return telephone; }
    public String getAdresse()      { return adresse; }
    public String getStatut()       { return statut; }
    public String getMotifBlocage() { return motifBlocage; }
    public String getCreatedAt()    { return createdAt; }

    // ── Setters ────────────────────────────────────────────────────────────
    public void setId(int id)                   { this.id = id; }
    public void setNom(String nom)              { this.nom = nom; }
    public void setEmail(String email)          { this.email = email; }
    public void setTelephone(String telephone)  { this.telephone = telephone; }
    public void setAdresse(String adresse)      { this.adresse = adresse; }
    public void setStatut(String statut)        { this.statut = statut; }
    public void setMotifBlocage(String m)       { this.motifBlocage = m; }
    public void setCreatedAt(String c)          { this.createdAt = c; }

    // ── toString (utile pour deboguer dans la console) ─────────────────────
    @Override
    public String toString() {
        return "Client{id=" + id + ", nom='" + nom + "', statut='" + statut + "'}";
    }
}

package model;

/**
 * Finance.java
 * Represente une ligne de la table `finance`.
 *
 * Dans ce projet, une Finance peut être :
 *   - Une RECETTE  : vient automatiquement d'une commande livree
 *   - Une DEPENSE  : achat de matiere premiere, ou salaire paye
 *
 * Colonnes de la table :
 *   id, description, type (RECETTE/DEPENSE), montant,
 *   date_transaction, commande_id (si recette liee à une commande)
 */
public class Finance {

    private int    id;
    private String description;
    private String type;          // "RECETTE" ou "DEPENSE"
    private double montant;
    private String dateTransaction; // format YYYY-MM-DD
    private int    commandeId;      // 0 si pas lie à une commande

    public Finance() {}

    public Finance(int id, String description, String type,
                   double montant, String dateTransaction, int commandeId) {
        this.id              = id;
        this.description     = description;
        this.type            = type;
        this.montant         = montant;
        this.dateTransaction = dateTransaction;
        this.commandeId      = commandeId;
    }

    // ── Getters ────────────────────────────────────────
    public int    getId()              { return id; }
    public String getDescription()     { return description; }
    public String getType()            { return type; }
    public double getMontant()         { return montant; }
    public String getDateTransaction() { return dateTransaction; }
    public int    getCommandeId()      { return commandeId; }

    // ── Setters ────────────────────────────────────────
    public void setId(int id)                      { this.id = id; }
    public void setDescription(String d)           { this.description = d; }
    public void setType(String type)               { this.type = type; }
    public void setMontant(double montant)         { this.montant = montant; }
    public void setDateTransaction(String date)    { this.dateTransaction = date; }
    public void setCommandeId(int commandeId)      { this.commandeId = commandeId; }
}

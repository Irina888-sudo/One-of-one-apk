package model;

import java.math.BigDecimal;
import java.sql.Date;

public class Conge {
    private int id;
    private Integer employeId;
    private Date dateDebut;
    private Date dateFin;
    private Integer nbrJours;
    private String statut;
    private String motif;
    private String typeConge; // PAYE or NON_PAYE

    public Conge() {}
    
    public Conge(int id, Integer employeId, Date dateDebut, Date dateFin, Integer nbrJours, String statut) {
        this.id = id;
        this.employeId = employeId;
        this.dateDebut = dateDebut;
        this.dateFin = dateFin;
        this.nbrJours = nbrJours;
        this.statut = statut;
    }

    public String getMotif() { return motif; }
    public void setMotif(String motif) { this.motif = motif; }

    public String getTypeConge() { return typeConge; }
    public void setTypeConge(String typeConge) { this.typeConge = typeConge; }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Integer getEmployeId() { return employeId; }
    public void setEmployeId(Integer employeId) { this.employeId = employeId; }
    public Date getDateDebut() { return dateDebut; }
    public void setDateDebut(Date dateDebut) { this.dateDebut = dateDebut; }
    public Date getDateFin() { return dateFin; }
    public void setDateFin(Date dateFin) { this.dateFin = dateFin; }
    public Integer getNbrJours() { return nbrJours; }
    public void setNbrJours(Integer nbrJours) { this.nbrJours = nbrJours; }
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

}

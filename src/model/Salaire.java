package model;


import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class Salaire {
    private int id;
    private Integer employeId;
    private BigDecimal salaireBrut;
    private LocalDate mois;
    private String statut;
    private BigDecimal salaireNet;
    private Integer joursConges;

    public Salaire() {}

    public Salaire(int id, Integer employeId, BigDecimal salaireBrut, LocalDate mois, String statut) {
        this.id = id;
        this.employeId = employeId;
        this.salaireBrut = salaireBrut;
        this.mois = mois;
        this.statut = statut;
    }
    

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Integer getEmployeId() { return employeId; }
    public void setEmployeId(Integer employeId) { this.employeId = employeId; }
    public BigDecimal getSalaireBrut() { return salaireBrut; }
    public void setSalaireBrut(BigDecimal salaireBrut) { this.salaireBrut = salaireBrut; }
    public LocalDate getMois() { return mois; }
    public void setMois(LocalDate mois) { this.mois = mois; }
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

    public BigDecimal getSalaireNet() { return salaireNet; }
    public void setSalaireNet(BigDecimal salaireNet) { this.salaireNet = salaireNet; }

    public Integer getJoursConges() { return joursConges; }
    public void setJoursConges(Integer joursConges) { this.joursConges = joursConges; }

    public static String formatMois(LocalDate date) {
        DateTimeFormatter formatter =
                DateTimeFormatter.ofPattern("MMMM yyyy", Locale.FRENCH);

        return date.format(formatter);
    }
}




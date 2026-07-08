package model;

public class Utilisateur {
    private int id;
    private String email;
    private String role;
    private boolean actif;

    public Utilisateur() {
    }

    public Utilisateur(int id, String email, String role, boolean actif) {
        this.id = id;
        this.email = email;
        this.role = role;
        this.actif = actif;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public boolean isActif() {
        return actif;
    }

    public void setActif(boolean actif) {
        this.actif = actif;
    }
}

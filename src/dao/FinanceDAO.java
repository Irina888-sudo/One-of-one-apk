package dao;

import model.Finance;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;

/**
 * FinanceDAO.java
 *
 * Toutes les requêtes SQL pour la page finance-list.jsp.
 *
 * Les donnees viennent de DEUX tables differentes :
 *   1. `commande`  → le chiffre d'affaires (montant_total des commandes LIVREES)
 *   2. `salaire`   → les depenses salaires (salaire_net des salaires PAYES)
 *   3. `matiere`   → les depenses matieres (quantite * valeur_unitaire)
 *
 * Methodes :
 *   getChiffreAffairesTotal()     → SUM montant_total des commandes LIVREES
 *   getTotalSalairesPaies()       → SUM salaire_net des salaires statut=PAYE
 *   getTotalAchatsMatieres()      → SUM quantite * valeur_unitaire de toutes les matieres
 *   listerDernieresCommandes()    → les 10 dernieres commandes livrees (pour le tableau)
 */
public class FinanceDAO {

    // ─────────────────────────────────────────────────────────────
    // 1. CHIFFRE D'AFFAIRES TOTAL
    //    = somme des montant_total de toutes les commandes LIVREES
    //    Une commande est comptee dans le CA seulement quand elle
    //    est livree (statut != 'ANNULEE')
    // ─────────────────────────────────────────────────────────────
    public double getChiffreAffairesTotal() {
        return getChiffreAffairesTotal(LocalDate.now().getYear());
    }

    public double getChiffreAffairesTotal(int annee) {
        double total = 0;
        String sql = "SELECT COALESCE(SUM(c.montant_total), 0) AS ca "
                   + "FROM commande c "
                   + "WHERE YEAR(c.date_commande) = ? AND c.statut <> 'ANNULEE'";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, annee);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) total = rs.getDouble("ca");
            rs.close(); ps.close(); conn.close();
        } catch (SQLException e) {
            System.err.println("FinanceDAO.getChiffreAffairesTotal() : " + e.getMessage());
        }
        return total;
    }

    // ─────────────────────────────────────────────────────────────
    // 2. TOTAL SALAIRES PAYeS
    //    = somme des salaire_brut de tous les salaires avec statut=PAYE
    //    pour garder le même calcul que le dashboard
    // ─────────────────────────────────────────────────────────────
    public double getTotalSalairesPaies() {
        return getTotalSalairesPaies(LocalDate.now().getYear());
    }

    public double getTotalSalairesPaies(int annee) {
        double total = 0;
        String sql = "SELECT COALESCE(SUM(salaire_brut), 0) AS total_salaires "
                   + "FROM salaire "
                   + "WHERE statut = 'PAYE' AND YEAR(mois) = ?";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, annee);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) total = rs.getDouble("total_salaires");
            rs.close(); ps.close(); conn.close();
        } catch (SQLException e) {
            System.err.println("FinanceDAO.getTotalSalairesPaies() : " + e.getMessage());
        }
        return total;
    }

    // ─────────────────────────────────────────────────────────────
    // 3. TOTAL ACHATS MATIeRES PREMIeRES
    //    = somme des depenses enregistrees dans la table finance
    //    pour correspondre au calcul du dashboard
    // ─────────────────────────────────────────────────────────────
    public double getTotalAchatsMatieres() {
        return getTotalAchatsMatieres(LocalDate.now().getYear());
    }

    public double getTotalAchatsMatieres(int annee) {
        double total = 0;
        String sql = "SELECT COALESCE(SUM(montant), 0) AS total_matieres "
                   + "FROM finance "
                   + "WHERE type = 'DEPENSE' AND YEAR(date_transaction) = ?";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, annee);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) total = rs.getDouble("total_matieres");
            rs.close(); ps.close(); conn.close();
        } catch (SQLException e) {
            System.err.println("FinanceDAO.getTotalAchatsMatieres() : " + e.getMessage());
        }
        return total;
    }

   

    // ─────────────────────────────────────────────────────────────
    // 4. NOMBRE TOTAL DE COMMANDES LIVReES
    //    Sert à afficher un KPI sur la page finance
    // ─────────────────────────────────────────────────────────────
    public int getNbCommandesLivrees() {
        return getNbCommandesLivrees(LocalDate.now().getYear());
    }

    public int getNbCommandesLivrees(int annee) {
        int nb = 0;
        String sql = "SELECT COUNT(*) AS nb FROM commande WHERE YEAR(date_commande) = ? AND statut = 'LIVREE'";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, annee);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) nb = rs.getInt("nb");
            rs.close(); ps.close(); conn.close();
        } catch (SQLException e) {
            System.err.println("FinanceDAO.getNbCommandesLivrees() : " + e.getMessage());
        }
        return nb;
    }

    // ─────────────────────────────────────────────────────────────
    // 5. LISTE DES DERNIeRES COMMANDES LIVReES
    //    Pour le tableau "Detail des recettes" sur finance-list.jsp
    //    On recupere les 10 plus recentes avec le nom du client
    // ─────────────────────────────────────────────────────────────
    public ArrayList<String[]> getDernieresCommandesLivrees() {
        return getDernieresCommandesLivrees(LocalDate.now().getYear());
    }

    public ArrayList<String[]> getDernieresCommandesLivrees(int annee) {
        // On utilise String[] à 4 cases : [numero, client_nom, montant, date]
        // Regle du projet : pas de HashMap → tableau simple String[]
        ArrayList<String[]> liste = new ArrayList<String[]>();

        String sql = "SELECT c.numero, cl.nom AS client_nom, "
                   + "c.montant_total AS montant, "
                   + "c.date_commande "
                   + "FROM commande c "
                   + "JOIN client cl ON c.client_id = cl.id "
                   + "WHERE YEAR(c.date_commande) = ? AND c.statut = 'LIVREE' "
                   + "ORDER BY c.date_commande DESC "
                   + "LIMIT 10";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, annee);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String[] ligne = new String[4];
                ligne[0] = rs.getString("numero");          // numero commande
                ligne[1] = rs.getString("client_nom");      // nom du client
                ligne[2] = String.format("%,.0f", rs.getDouble("montant"));
                ligne[3] = rs.getString("date_commande");   // date
                liste.add(ligne);
            }
            rs.close(); ps.close(); conn.close();
        } catch (SQLException e) {
            System.err.println("FinanceDAO.getDernieresCommandesLivrees() : " + e.getMessage());
        }
        return liste;
    }
}

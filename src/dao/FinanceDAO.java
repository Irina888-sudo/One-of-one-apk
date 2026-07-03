package dao;

import model.Finance;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

/**
 * FinanceDAO.java
 *
 * Toutes les requêtes SQL pour la page finance-list.jsp.
 *
 * Les données viennent de DEUX tables différentes :
 *   1. `commande`  → le chiffre d'affaires (montant_total des commandes LIVREES)
 *   2. `salaire`   → les dépenses salaires (salaire_net des salaires PAYES)
 *   3. `matiere`   → les dépenses matières (quantite * valeur_unitaire)
 *
 * Méthodes :
 *   getChiffreAffairesTotal()     → SUM montant_total des commandes LIVREES
 *   getTotalSalairesPaies()       → SUM salaire_net des salaires statut=PAYE
 *   getTotalAchatsMatières()      → SUM quantite * valeur_unitaire de toutes les matières
 *   listerDernieresCommandes()    → les 10 dernières commandes livrées (pour le tableau)
 */
public class FinanceDAO {

    // ─────────────────────────────────────────────────────────────
    // 1. CHIFFRE D'AFFAIRES TOTAL
    //    = somme des montant_total de toutes les commandes LIVREES
    //    Une commande est comptée dans le CA seulement quand elle
    //    est livrée (statut = 'LIVREE')
    // ─────────────────────────────────────────────────────────────
    public double getChiffreAffairesTotal() {
        double total = 0;
        // On somme les montants de toutes les lignes_commande liées
        // aux commandes dont le statut est LIVREE
        String sql = "SELECT COALESCE(SUM(lc.quantite * lc.prix_unitaire), 0) AS ca "
                   + "FROM ligne_commande lc "
                   + "JOIN commande c ON lc.commande_id = c.id "
                   + "WHERE c.statut = 'LIVREE'";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) total = rs.getDouble("ca");
            rs.close(); ps.close(); conn.close();
        } catch (SQLException e) {
            System.err.println("FinanceDAO.getChiffreAffairesTotal() : " + e.getMessage());
        }
        return total;
    }

    // ─────────────────────────────────────────────────────────────
    // 2. TOTAL SALAIRES PAYÉS
    //    = somme des salaire_net de tous les salaires avec statut=PAYE
    //    (salaire_net est calculé automatiquement par MySQL : brut - déduction congés)
    // ─────────────────────────────────────────────────────────────
    public double getTotalSalairesPaies() {
        double total = 0;
        String sql = "SELECT COALESCE(SUM(salaire_net), 0) AS total_salaires "
                   + "FROM salaire "
                   + "WHERE statut = 'PAYE'";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) total = rs.getDouble("total_salaires");
            rs.close(); ps.close(); conn.close();
        } catch (SQLException e) {
            System.err.println("FinanceDAO.getTotalSalairesPaies() : " + e.getMessage());
        }
        return total;
    }

    // ─────────────────────────────────────────────────────────────
    // 3. TOTAL ACHATS MATIÈRES PREMIÈRES
    //    = valeur actuelle de tout le stock (quantite × valeur_unitaire)
    //    C'est ce que représente l'investissement en matières
    // ─────────────────────────────────────────────────────────────
    public double getTotalAchatsMatières() {
        double total = 0;
        String sql = "SELECT COALESCE(SUM(quantite * valeur_unitaire), 0) AS total_matieres "
                   + "FROM matiere";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) total = rs.getDouble("total_matieres");
            rs.close(); ps.close(); conn.close();
        } catch (SQLException e) {
            System.err.println("FinanceDAO.getTotalAchatsMatières() : " + e.getMessage());
        }
        return total;
    }

    // ─────────────────────────────────────────────────────────────
    // 4. NOMBRE TOTAL DE COMMANDES LIVRÉES
    //    Sert à afficher un KPI sur la page finance
    // ─────────────────────────────────────────────────────────────
    public int getNbCommandesLivrees() {
        int nb = 0;
        String sql = "SELECT COUNT(*) AS nb FROM commande WHERE statut = 'LIVREE'";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) nb = rs.getInt("nb");
            rs.close(); ps.close(); conn.close();
        } catch (SQLException e) {
            System.err.println("FinanceDAO.getNbCommandesLivrees() : " + e.getMessage());
        }
        return nb;
    }

    // ─────────────────────────────────────────────────────────────
    // 5. LISTE DES DERNIÈRES COMMANDES LIVRÉES
    //    Pour le tableau "Détail des recettes" sur finance-list.jsp
    //    On récupère les 10 plus récentes avec le nom du client
    // ─────────────────────────────────────────────────────────────
    public ArrayList<String[]> getDernieresCommandesLivrees() {
        // On utilise String[] à 4 cases : [numero, client_nom, montant, date]
        // Règle du projet : pas de HashMap → tableau simple String[]
        ArrayList<String[]> liste = new ArrayList<String[]>();

        String sql = "SELECT c.numero, cl.nom AS client_nom, "
                   + "COALESCE(SUM(lc.quantite * lc.prix_unitaire), 0) AS montant, "
                   + "c.date_commande "
                   + "FROM commande c "
                   + "JOIN client cl ON c.client_id = cl.id "
                   + "LEFT JOIN ligne_commande lc ON lc.commande_id = c.id "
                   + "WHERE c.statut = 'LIVREE' "
                   + "GROUP BY c.id "
                   + "ORDER BY c.date_commande DESC "
                   + "LIMIT 10";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String[] ligne = new String[4];
                ligne[0] = rs.getString("numero");          // numéro commande
                ligne[1] = rs.getString("client_nom");      // nom du client
                ligne[2] = String.format("%.2f", rs.getDouble("montant")); // montant formaté
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

package dao;

import model.StatistiqueMensuelle;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DashboardDAO {

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return DriverManager.getConnection("jdbc:mysql://localhost:3306/oneofone", "root", "");
    }

    public List<StatistiqueMensuelle> getStatistiquesAnnuelles(int annee) throws SQLException {
        List<StatistiqueMensuelle> stats = new ArrayList<>();
        // Initialisation des 12 mois
        for (int i = 1; i <= 12; i++) {
            stats.add(new StatistiqueMensuelle(i));
        }

        try (Connection conn = getConnection()) {
            // 1. Chiffre d'affaires & Nombre de commandes par mois
            String sqlCommandes = "SELECT MONTH(date_commande) as mois, SUM(montant_total) as ca, COUNT(*) as nb_cmd " +
                                  "FROM commande " +
                                  "WHERE YEAR(date_commande) = ? AND statut != 'ANNULEE' " +
                                  "GROUP BY MONTH(date_commande)";
            try (PreparedStatement ps = conn.prepareStatement(sqlCommandes)) {
                ps.setInt(1, annee);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int mois = rs.getInt("mois");
                        if (mois >= 1 && mois <= 12) {
                            StatistiqueMensuelle stat = stats.get(mois - 1);
                            stat.setChiffreAffaires(rs.getDouble("ca"));
                            stat.setNombreCommandes(rs.getInt("nb_cmd"));
                        }
                    }
                }
            }

            // 2. Depenses par mois (Achats matieres et autres dans la table finance)
            String sqlDepensesFinance = "SELECT MONTH(date_transaction) as mois, SUM(montant) as depenses " +
                                        "FROM finance " +
                                        "WHERE type = 'DEPENSE' AND YEAR(date_transaction) = ? " +
                                        "GROUP BY MONTH(date_transaction)";
            try (PreparedStatement ps = conn.prepareStatement(sqlDepensesFinance)) {
                ps.setInt(1, annee);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int mois = rs.getInt("mois");
                        if (mois >= 1 && mois <= 12) {
                            StatistiqueMensuelle stat = stats.get(mois - 1);
                            stat.setDepenses(stat.getDepenses() + rs.getDouble("depenses"));
                        }
                    }
                }
            }

            // Depenses par mois (Salaires payes, depuis la table salaire si non inclus dans finance)
            String sqlSalaires = "SELECT MONTH(mois) as mois, SUM(salaire_brut) as total_salaires " +
                                 "FROM salaire " +
                                 "WHERE statut = 'PAYE' AND YEAR(mois) = ? " +
                                 "GROUP BY MONTH(mois)";
            try (PreparedStatement ps = conn.prepareStatement(sqlSalaires)) {
                ps.setInt(1, annee);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int mois = rs.getInt("mois");
                        if (mois >= 1 && mois <= 12) {
                            StatistiqueMensuelle stat = stats.get(mois - 1);
                            stat.setDepenses(stat.getDepenses() + rs.getDouble("total_salaires"));
                        }
                    }
                }
            }

            // 3. evolution du stock de matieres 
            // Note: Faute d'historique (ex: table mouvement_stock), on recupere la quantite actuelle globale
            // que l'on assigne au mois actuel de l'annee. 
            String sqlStock = "SELECT SUM(quantite) as total_stock FROM matiere";
            double currentStock = 0;
            try (PreparedStatement ps = conn.prepareStatement(sqlStock);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentStock = rs.getDouble("total_stock");
                }
            }
            
            int currentYear = java.time.LocalDate.now().getYear();
            int currentMonth = java.time.LocalDate.now().getMonthValue();
            
            if (annee == currentYear && currentMonth >= 1 && currentMonth <= 12) {
                stats.get(currentMonth - 1).setStockMatieres(currentStock);
            }
        }
        
        return stats;
    }
}

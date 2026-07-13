package dao;

import util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CorbeilleDAO {

    public static class CorbeilleEntry {
        private int id;
        private String entityType;
        private int entityId;
        private String title;
        private String payload;
        private Timestamp deletedAt;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }

        public String getEntityType() { return entityType; }
        public void setEntityType(String entityType) { this.entityType = entityType; }

        public int getEntityId() { return entityId; }
        public void setEntityId(int entityId) { this.entityId = entityId; }

        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }

        public String getPayload() { return payload; }
        public void setPayload(String payload) { this.payload = payload; }

        public Timestamp getDeletedAt() { return deletedAt; }
        public void setDeletedAt(Timestamp deletedAt) { this.deletedAt = deletedAt; }

        public String getSectionLabel() {
            switch (entityType) {
                case "produit": return "Produits";
                case "employe": return "Employes";
                case "livraison": return "Livraisons";
                case "salaire": return "Salaires";
                case "commande": return "Commandes";
                default: return entityType;
            }
        }
    }

    private Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    private boolean hasSupprimeColumn(Connection conn) throws SQLException {
        DatabaseMetaData meta = conn.getMetaData();
        try (ResultSet rs = meta.getColumns(null, null, "produit", "supprime")) {
            return rs.next();
        }
    }

    public void ensureTable() throws SQLException {
        String sql = """
            CREATE TABLE IF NOT EXISTS deleted_items (
                id INT PRIMARY KEY AUTO_INCREMENT,
                entity_type VARCHAR(50) NOT NULL,
                entity_id INT NOT NULL,
                title VARCHAR(255),
                payload TEXT,
                deleted_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
            """;
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        }
    }

    private void saveEntry(Connection conn, String entityType, int entityId, String title, String payload) throws SQLException {
        String sql = "INSERT INTO deleted_items (entity_type, entity_id, title, payload) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            ps.setString(3, title);
            ps.setString(4, payload);
            ps.executeUpdate();
        }
    }

    public void archiverProduit(int id) throws SQLException {
        ensureTable();
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            String title = null;
            String payload = null;
            try (PreparedStatement ps = conn.prepareStatement("SELECT id, nom, categorie, taille, couleur, prix, statut, collection_id, image FROM produit WHERE id = ?")) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        title = rs.getString("nom");
                        payload = String.join("|",
                                String.valueOf(rs.getInt("id")),
                                rs.getString("nom") == null ? "" : rs.getString("nom"),
                                rs.getString("categorie") == null ? "" : rs.getString("categorie"),
                                rs.getString("taille") == null ? "" : rs.getString("taille"),
                                rs.getString("couleur") == null ? "" : rs.getString("couleur"),
                                rs.getBigDecimal("prix") == null ? "" : rs.getBigDecimal("prix").toPlainString(),
                                rs.getString("statut") == null ? "" : rs.getString("statut"),
                                rs.getObject("collection_id") == null ? "" : rs.getString("collection_id"),
                                rs.getString("image") == null ? "" : rs.getString("image")
                        );
                    }
                }
            }
            if (title != null) {
                saveEntry(conn, "produit", id, title, payload);
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM ligne_commande WHERE produit_id = ?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                if (hasSupprimeColumn(conn)) {
                    try (PreparedStatement ps = conn.prepareStatement("UPDATE produit SET supprime = 1 WHERE id = ?")) {
                        ps.setInt(1, id);
                        ps.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ps = conn.prepareStatement("DELETE FROM produit WHERE id = ?")) {
                        ps.setInt(1, id);
                        ps.executeUpdate();
                    }
                }
            }
            conn.commit();
        }
    }

    public void archiverEmploye(int id) throws SQLException {
        ensureTable();
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            String title = null;
            String payload = null;
            try (PreparedStatement ps = conn.prepareStatement("SELECT id, utilisateur_id, nom, email, telephone, role, salaire_brut, statut, date_embauche FROM employe WHERE id = ?")) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        title = rs.getString("nom");
                        payload = String.join("|",
                                String.valueOf(rs.getInt("id")),
                                rs.getObject("utilisateur_id") == null ? "" : rs.getString("utilisateur_id"),
                                rs.getString("nom") == null ? "" : rs.getString("nom"),
                                rs.getString("email") == null ? "" : rs.getString("email"),
                                rs.getString("telephone") == null ? "" : rs.getString("telephone"),
                                rs.getString("role") == null ? "" : rs.getString("role"),
                                rs.getBigDecimal("salaire_brut") == null ? "" : rs.getBigDecimal("salaire_brut").toPlainString(),
                                rs.getString("statut") == null ? "" : rs.getString("statut"),
                                rs.getDate("date_embauche") == null ? "" : rs.getDate("date_embauche").toString()
                        );
                    }
                }
            }
            if (title != null) {
                saveEntry(conn, "employe", id, title, payload);
                try (PreparedStatement ps = conn.prepareStatement("UPDATE employe SET statut = 'INACTIF' WHERE id = ?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
            }
            conn.commit();
        }
    }

    public void archiverLivraison(int id) throws SQLException {
        ensureTable();
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            String title = null;
            String payload = null;
            try (PreparedStatement ps = conn.prepareStatement("SELECT id, numero, commande_id, employe_id, livreur, lieu, frais, statut, date_livraison FROM livraison WHERE id = ?")) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        title = rs.getString("numero");
                        payload = String.join("|",
                                String.valueOf(rs.getInt("id")),
                                rs.getString("numero") == null ? "" : rs.getString("numero"),
                                rs.getObject("commande_id") == null ? "" : rs.getString("commande_id"),
                                rs.getObject("employe_id") == null ? "" : rs.getString("employe_id"),
                                rs.getString("livreur") == null ? "" : rs.getString("livreur"),
                                rs.getString("lieu") == null ? "" : rs.getString("lieu"),
                                rs.getBigDecimal("frais") == null ? "" : rs.getBigDecimal("frais").toPlainString(),
                                rs.getString("statut") == null ? "" : rs.getString("statut"),
                                rs.getDate("date_livraison") == null ? "" : rs.getDate("date_livraison").toString()
                        );
                    }
                }
            }
            if (title != null) {
                saveEntry(conn, "livraison", id, title, payload);
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM livraison WHERE id = ?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
            }
            conn.commit();
        }
    }

    public void archiverSalaire(int id) throws SQLException {
        ensureTable();
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            String title = null;
            String payload = null;
            try (PreparedStatement ps = conn.prepareStatement("SELECT id, employe_id, mois, salaire_brut, salaire_net, statut FROM salaire WHERE id = ?")) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        title = "Salaire #" + rs.getInt("id");
                        payload = String.join("|",
                                String.valueOf(rs.getInt("id")),
                                rs.getObject("employe_id") == null ? "" : rs.getString("employe_id"),
                                rs.getDate("mois") == null ? "" : rs.getDate("mois").toString(),
                                rs.getBigDecimal("salaire_brut") == null ? "" : rs.getBigDecimal("salaire_brut").toPlainString(),
                                rs.getBigDecimal("salaire_net") == null ? "" : rs.getBigDecimal("salaire_net").toPlainString(),
                                rs.getString("statut") == null ? "" : rs.getString("statut")
                        );
                    }
                }
            }
            if (title != null) {
                saveEntry(conn, "salaire", id, title, payload);
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM salaire WHERE id = ?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
            }
            conn.commit();
        }
    }

    public void archiverCommande(int id) throws SQLException {
        ensureTable();
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            String title = null;
            String payload = null;
            try (PreparedStatement ps = conn.prepareStatement("SELECT id, numero, client_id, statut, montant_total, date_commande FROM commande WHERE id = ?")) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        title = rs.getString("numero");
                        payload = String.join("|",
                                String.valueOf(rs.getInt("id")),
                                rs.getString("numero") == null ? "" : rs.getString("numero"),
                                rs.getObject("client_id") == null ? "" : rs.getString("client_id"),
                                rs.getString("statut") == null ? "" : rs.getString("statut"),
                                rs.getBigDecimal("montant_total") == null ? "" : rs.getBigDecimal("montant_total").toPlainString(),
                                rs.getTimestamp("date_commande") == null ? "" : rs.getTimestamp("date_commande").toString()
                        );
                    }
                }
            }
            if (title != null) {
                saveEntry(conn, "commande", id, title, payload);
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM ligne_commande WHERE commande_id = ?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM commande WHERE id = ?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
            }
            conn.commit();
        }
    }

    public List<CorbeilleEntry> lister(String section) throws SQLException {
        ensureTable();
        List<CorbeilleEntry> items = new ArrayList<>();
        String sql = "SELECT id, entity_type, entity_id, title, payload, deleted_at FROM deleted_items";
        List<String> filters = new ArrayList<>();
        if (section != null && !section.isBlank() && !"all".equalsIgnoreCase(section)) {
            sql += " WHERE entity_type = ?";
            filters.add(section);
        }
        sql += " ORDER BY deleted_at DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < filters.size(); i++) {
                ps.setString(i + 1, filters.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CorbeilleEntry entry = new CorbeilleEntry();
                    entry.setId(rs.getInt("id"));
                    entry.setEntityType(rs.getString("entity_type"));
                    entry.setEntityId(rs.getInt("entity_id"));
                    entry.setTitle(rs.getString("title"));
                    entry.setPayload(rs.getString("payload"));
                    entry.setDeletedAt(rs.getTimestamp("deleted_at"));
                    items.add(entry);
                }
            }
        }
        return items;
    }

    public boolean restaurer(int deletedItemId) throws SQLException {
        ensureTable();
        CorbeilleEntry entry = null;
        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("SELECT id, entity_type, entity_id, title, payload FROM deleted_items WHERE id = ?")) {
                ps.setInt(1, deletedItemId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        entry = new CorbeilleEntry();
                        entry.setId(rs.getInt("id"));
                        entry.setEntityType(rs.getString("entity_type"));
                        entry.setEntityId(rs.getInt("entity_id"));
                        entry.setTitle(rs.getString("title"));
                        entry.setPayload(rs.getString("payload"));
                    }
                }
            }
            if (entry == null) {
                return false;
            }
            conn.setAutoCommit(false);
            boolean restored = false;
            if ("employe".equals(entry.getEntityType())) {
                restored = restaurerEmploye(conn, entry.getPayload());
            } else if ("produit".equals(entry.getEntityType())) {
                restored = restaurerProduit(conn, entry.getPayload());
            } else if ("livraison".equals(entry.getEntityType())) {
                restored = restaurerLivraison(conn, entry.getPayload());
            } else if ("salaire".equals(entry.getEntityType())) {
                restored = restaurerSalaire(conn, entry.getPayload());
            } else if ("commande".equals(entry.getEntityType())) {
                restored = restaurerCommande(conn, entry.getPayload());
            }
            if (restored) {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM deleted_items WHERE id = ?")) {
                    ps.setInt(1, deletedItemId);
                    ps.executeUpdate();
                }
            }
            conn.commit();
            return restored;
        }
    }

    private boolean restaurerProduit(Connection conn, String payload) throws SQLException {
        String[] parts = payload.split("\\|", -1);
        if (parts.length < 9) return false;
        if (hasSupprimeColumn(conn)) {
            String sql = "UPDATE produit SET nom = ?, categorie = ?, taille = ?, couleur = ?, prix = ?, statut = ?, collection_id = ?, image = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, parts[1]);
                ps.setString(2, parts[2]);
                ps.setString(3, parts[3]);
                ps.setString(4, parts[4]);
                if (parts[5].isBlank()) {
                    ps.setNull(5, Types.DECIMAL);
                } else {
                    ps.setBigDecimal(5, new BigDecimal(parts[5]));
                }
                ps.setString(6, parts[6]);
                if (parts[7].isBlank()) {
                    ps.setNull(7, Types.INTEGER);
                } else {
                    ps.setInt(7, Integer.parseInt(parts[7]));
                }
                ps.setString(8, parts[8]);
                ps.setInt(9, Integer.parseInt(parts[0]));
                ps.executeUpdate();
                try (PreparedStatement psReset = conn.prepareStatement("UPDATE produit SET supprime = 0 WHERE id = ?")) {
                    psReset.setInt(1, Integer.parseInt(parts[0]));
                    psReset.executeUpdate();
                }
            }
            return true;
        }
        String sql = "INSERT INTO produit (id, nom, categorie, taille, couleur, prix, statut, collection_id, image) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(parts[0]));
            ps.setString(2, parts[1]);
            ps.setString(3, parts[2]);
            ps.setString(4, parts[3]);
            ps.setString(5, parts[4]);
            if (parts[5].isBlank()) {
                ps.setNull(6, Types.DECIMAL);
            } else {
                ps.setBigDecimal(6, new BigDecimal(parts[5]));
            }
            ps.setString(7, parts[6]);
            if (parts[7].isBlank()) {
                ps.setNull(8, Types.INTEGER);
            } else {
                ps.setInt(8, Integer.parseInt(parts[7]));
            }
            ps.setString(9, parts[8]);
            ps.executeUpdate();
        }
        return true;
    }

    private boolean restaurerEmploye(Connection conn, String payload) throws SQLException {
        String[] parts = payload.split("\\|", -1);
        if (parts.length < 9) return false;
        String sql = "UPDATE employe SET utilisateur_id = ?, nom = ?, email = ?, telephone = ?, role = ?, salaire_brut = ?, statut = ?, date_embauche = ? WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            if (parts[1].isBlank()) {
                ps.setNull(1, Types.INTEGER);
            } else {
                ps.setInt(1, Integer.parseInt(parts[1]));
            }
            ps.setString(2, parts[2]);
            ps.setString(3, parts[3]);
            ps.setString(4, parts[4]);
            ps.setString(5, parts[5]);
            if (parts[6].isBlank()) {
                ps.setNull(6, Types.DECIMAL);
            } else {
                ps.setBigDecimal(6, new BigDecimal(parts[6]));
            }
            ps.setString(7, parts[7].isBlank() ? "ACTIF" : parts[7]);
            if (parts[8].isBlank()) {
                ps.setNull(8, Types.DATE);
            } else {
                ps.setDate(8, Date.valueOf(parts[8]));
            }
            ps.setInt(9, Integer.parseInt(parts[0]));
            ps.executeUpdate();
        }
        return true;
    }

    private boolean restaurerLivraison(Connection conn, String payload) throws SQLException {
        String[] parts = payload.split("\\|", -1);
        if (parts.length < 9) return false;
        String sql = "INSERT INTO livraison (id, numero, commande_id, employe_id, livreur, lieu, frais, statut, date_livraison) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(parts[0]));
            ps.setString(2, parts[1]);
            if (parts[2].isBlank()) { ps.setNull(3, Types.INTEGER); } else { ps.setInt(3, Integer.parseInt(parts[2])); }
            if (parts[3].isBlank()) { ps.setNull(4, Types.INTEGER); } else { ps.setInt(4, Integer.parseInt(parts[3])); }
            ps.setString(5, parts[4]);
            ps.setString(6, parts[5]);
            if (parts[6].isBlank()) { ps.setNull(7, Types.DECIMAL); } else { ps.setBigDecimal(7, new BigDecimal(parts[6])); }
            ps.setString(8, parts[7]);
            if (parts[8].isBlank()) { ps.setNull(9, Types.DATE); } else { ps.setDate(9, Date.valueOf(parts[8])); }
            ps.executeUpdate();
        }
        return true;
    }

    private boolean restaurerSalaire(Connection conn, String payload) throws SQLException {
        String[] parts = payload.split("\\|", -1);
        if (parts.length < 6) return false;
        String sql = "INSERT INTO salaire (id, employe_id, mois, salaire_brut, salaire_net, statut) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(parts[0]));
            if (parts[1].isBlank()) { ps.setNull(2, Types.INTEGER); } else { ps.setInt(2, Integer.parseInt(parts[1])); }
            if (parts[2].isBlank()) { ps.setNull(3, Types.DATE); } else { ps.setDate(3, Date.valueOf(parts[2])); }
            if (parts[3].isBlank()) { ps.setNull(4, Types.DECIMAL); } else { ps.setBigDecimal(4, new BigDecimal(parts[3])); }
            if (parts[4].isBlank()) { ps.setNull(5, Types.DECIMAL); } else { ps.setBigDecimal(5, new BigDecimal(parts[4])); }
            ps.setString(6, parts[5]);
            ps.executeUpdate();
        }
        return true;
    }

    private boolean restaurerCommande(Connection conn, String payload) throws SQLException {
        String[] parts = payload.split("\\|", -1);
        if (parts.length < 6) return false;
        String sql = "INSERT INTO commande (id, numero, client_id, statut, montant_total, date_commande) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(parts[0]));
            ps.setString(2, parts[1]);
            if (parts[2].isBlank()) { ps.setNull(3, Types.INTEGER); } else { ps.setInt(3, Integer.parseInt(parts[2])); }
            ps.setString(4, parts[3]);
            if (parts[4].isBlank()) { ps.setNull(5, Types.DECIMAL); } else { ps.setBigDecimal(5, new BigDecimal(parts[4])); }
            if (parts[5].isBlank()) { ps.setNull(6, Types.TIMESTAMP); } else { ps.setTimestamp(6, Timestamp.valueOf(parts[5])); }
            ps.executeUpdate();
        }
        return true;
    }
}

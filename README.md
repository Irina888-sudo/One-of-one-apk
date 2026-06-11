# One-of-one-apk

/opt/tomcat/bin/shutdown.sh
/opt/tomcat/bin/startup.sh

OneOfOne/
├── src/
│   ├── model/
│   │   ├── Utilisateur.java
│   │   ├── Matiere.java
│   │   ├── Client.java
│   │   ├── Employe.java
│   │   ├── Conge.java
│   │   ├── Commande.java
│   │   ├── LigneCommande.java
│   │   ├── Livraison.java
│   │   ├── Finance.java
│   │   ├── Produit.java
│   │   ├── Collection.java
│   │   ├── Salaire.java
│   │   ├── Fournisseur.java
│   │   └── Notification.java

│   ├── dao/
│   │   ├── UtilisateurDAO.java
│   │   ├── MatiereDAO.java
│   │   ├── ClientDAO.java
│   │   ├── EmployeDAO.java
│   │   ├── CongeDAO.java
│   │   ├── CommandeDAO.java
│   │   ├── LivraisonDAO.java
│   │   ├── FinanceDAO.java
│   │   ├── ProduitDAO.java
│   │   ├── CollectionDAO.java
│   │   ├── SalaireDAO.java
│   │   └── FournisseurDAO.java

│   └── util/
│       └── DBConnection.java

├── WebContent/
│   ├── WEB-INF/
│   │   └── web.xml

│   ├── css/
│   │   ├── global.css
│   │   ├── components.css
│   │   ├── dashboard.css
│   │   ├── stock.css
│   │   ├── commande.css
│   │   ├── livraison.css
│   │   ├── client.css
│   │   ├── employe.css
│   │   ├── finance.css
│   │   ├── salaire.css
│   │   ├── graphiques.css
│   │   └── ia.css

│   ├── includes/
│   │   └── session_check.jsp

│   ├── jsp/
│   │   ├── login.jsp
│   │   ├── logout.jsp
│   │   ├── dashboard-admin.jsp
│   │   ├── dashboard-comptable.jsp
│   │   ├── dashboard-employe.jsp
│   │   ├── stock-list.jsp
│   │   ├── stock-form.jsp
│   │   ├── stock-mouvements.jsp
│   │   ├── client-list.jsp
│   │   ├── client-form.jsp
│   │   ├── employe-list.jsp
│   │   ├── employe-form.jsp
│   │   ├── commande-list.jsp
│   │   ├── commande-form.jsp
│   │   ├── livraison-list.jsp
│   │   ├── livraison-form.jsp
│   │   ├── finance-list.jsp
│   │   ├── ia.jsp
│   │   ├── produit-list.jsp
│   │   ├── produit-form.jsp
│   │   ├── collection-list.jsp
│   │   ├── salaire-list.jsp
│   │   ├── graphiques.jsp
│   │   └── notification-list.jsp

│   └── js/
│       └── chart.min.js

└── sql/
    └── oneofone.sql
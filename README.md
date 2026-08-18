# 🜟️ AuditPrep IA — Préparation Intelligente des Audits (Convergence)

*jAuditPrep IA** est une application d'aide à la décision conçue pour assister les auditeurs dans le ciblage, la priorisation et la génération des check-lists d'audit qualité et conformité (**ISO 9001:2015**).

---

## 🌟 Fonctionnalités Principales

- **3 Modes de Génération de Check-lists :**
  - 🔄 **Historique recommandé** : Sélection automatique et pondérée des constats historiques les plus pertinents.
  - 🎯 **Historique manuel** : Choix personnalisé de la mission source de référence.
  - 🙩 **Premier audit / Sans historique** : Amorçage contextuel basé sur le référentiel ISO 9001 et les processus cibles.
- **Moteur IA & Machine Learning Supervisé (Scikit-learn) :**
  - Classification de priorité **Haute**, **Moyenne**, **Faible**).
  - Régression et scoring de criticité des clauses et processus (0 à 100).
  - Matrice de confusion et analyse d'importance des variables.
  - Explicabilité complète supervisée par l'auditeur humain.
- **Interface Convergence :**
  - Thème épuré avec compatibilité mode clair / mode sombre.
  - Tableaux de bord de vigilance par clause et par processus en temps réel.
  - Export consolidé vers Excel (.xlsx).
- **Mode Démonstration / Cloud Automatique :
  * Fonctionne à 100% avec une base **PostgreSQL** réelle (locale ou Cloud).
  * Mode Démo interactif intégré permettant de tester toute l'application sur le Web sans base de données externe.

---

## 🚀 Déploiement en Ligne (Streamlit Community Cloud)

Pour obtenir votre lien web public :

1. Connectez-vous sur **[
share.streamlit.io](https://share.streamlit.io)** avec votre compte GitHub.
2. Cliquez sur **"New app"** (ou "Create app").
3. Renseignez :
- **Repository :** `zoussefhedhiri7-sketch/AuditPrep-IA`
- **Branch :** `main`
- **Main file path :** `streamlit_app.py`
4. Cliquez sur **"Deploy!"**.

---

## 👨 Auteur & Crédits

- **Projet :** Projet de Fin d'Études (PFE) – Solution AuditPrep IA
- **Entreprise :** Convergence

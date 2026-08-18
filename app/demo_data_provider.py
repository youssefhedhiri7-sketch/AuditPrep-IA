# -*- coding: utf-8 -*-
# AuditPrep IA - Fournisseur de Donnees Demonstration / Cloud
from datetime import datetime
import pandas as pd

def get_demo_target_missions():
    return pd.DataFrame([
        {'mission_id': 101, 'mission_code': 'MIS-2026-001', 'mission_title': 'Audit Qualite Usine & Lignes Montage', 'client_name': 'Groupe Convergence Industrie', 'site_name': 'Site Nord - Lille', 'audit_date': '2026-09-15', 'standard_name': 'ISO 9001:2015'},
        {'mission_id': 102, 'mission_code': 'MIS-2026-002', 'mission_title': 'Audit Achats & Fournisseurs', 'client_name': 'Convergence Supply Chain', 'site_name': 'Plateforme Nantes', 'audit_date': '2026-10-02', 'standard_name': 'ISO 9001:2015'},
        {'mission_id': 103, 'mission_code': 'MIS-2026-003', 'mission_title': 'Audit Management & Leadership', 'client_name': 'Convergence Holding', 'site_name': 'Siege Paris', 'audit_date': '2026-11-20', 'standard_name': 'ISO 9001:2015'},
        {'mission_id': 104, 'mission_code': 'MIS-2026-004', 'mission_title': 'Audit Service Client & SAV', 'client_name': 'Convergence Customer Care', 'site_name': 'Centre Lyon', 'audit_date': '2026-12-05', 'standard_name': 'ISO 9001:2015'},
    ])

def get_demo_historical_missions():
    return pd.DataFrame([
        {'mission_id': 201, 'mission_code': 'MIS-2025-010', 'mission_title': 'Audit Interne Production 2025', 'client_name': 'Groupe Convergence Industrie', 'site_name': 'Site Nord - Lille', 'audit_date': '2025-10-12', 'findings_count': 14},
        {'mission_id': 202, 'mission_code': 'MIS-2025-004', 'mission_title': 'Audit Fournisseurs 2025', 'client_name': 'Convergence Supply Chain', 'site_name': 'Plateforme Nantes', 'audit_date': '2025-05-18', 'findings_count': 9},
        {'mission_id': 203, 'mission_code': 'MIS-2024-012', 'mission_title': 'Audit Systeme Qualite 2024', 'client_name': 'Convergence Holding', 'site_name': 'Siege Paris', 'audit_date': '2024-11-14', 'findings_count': 18},
    ])

def get_demo_mission_contexts():
    return pd.DataFrame([
        {'mission_id': 101, 'sector': 'Industrie Mecanique', 'audited_process': 'Production & Assemblage', 'audit_objective': 'Verifier conformite operationnelle et tracabilite', 'audit_scope': 'Ateliers A et B', 'specific_requirements': 'ISO 9001:2015 8.5', 'known_risks': 'Derives usinage, tracabilite', 'keywords': 'production, tracabilite, gamme', 'created_at': datetime.now(), 'updated_at': datetime.now()},
        {'mission_id': 102, 'sector': 'Logistique & Achats', 'audited_process': 'Achats & Fournisseurs', 'audit_objective': 'Evaluer selection et surveillance prestataires', 'audit_scope': 'Service Achats', 'specific_requirements': 'ISO 9001:2015 8.4', 'known_risks': 'Ruptures, prestataires sans evaluation', 'keywords': 'achats, fournisseurs', 'created_at': datetime.now(), 'updated_at': datetime.now()},
        {'mission_id': 103, 'sector': 'Management', 'audited_process': 'Direction & Pilotage', 'audit_objective': 'Gouvernance et revue de direction', 'audit_scope': 'Siege', 'specific_requirements': 'ISO 9001:2015 5 et 6', 'known_risks': 'Indicateurs non actualises', 'keywords': 'leadership, revue', 'created_at': datetime.now(), 'updated_at': datetime.now()},
        {'mission_id': 104, 'sector': 'Relation Client', 'audited_process': 'Service Client & SAV', 'audit_objective': 'Traitement des reclamations', 'audit_scope': 'SAV', 'specific_requirements': 'ISO 9001:2015 8.2', 'known_risks': 'Delais de traitement', 'keywords': 'reclamation, SAV', 'created_at': datetime.now(), 'updated_at': datetime.now()},
    ])

def get_demo_history_signals(source_codes=None):
    df = pd.DataFrame([
        {'source_mission_code': 'MIS-2025-010', 'history_process_signals': 'Production (6 NC), Maintenance (4 NC)', 'history_clause_signals': '8.5 Tracabilite, 7.1.5 Metrologie', 'history_top_signal': 'Production (85/100)'},
        {'source_mission_code': 'MIS-2025-004', 'history_process_signals': 'Achats (5 NC), Reception (4 NC)', 'history_clause_signals': '8.4 Prestataires', 'history_top_signal': 'Achats (78/100)'},
        {'source_mission_code': 'MIS-2024-012', 'history_process_signals': 'Direction (7 NC), RH (6 NC)', 'history_clause_signals': '5.1 Leadership, 7.2 Competences', 'history_top_signal': 'Direction (72/100)'},
    ])
    if source_codes:
        df = df[df['source_mission_code'].isin(source_codes)]
    return df

def get_demo_supervised_dataset():
    data = [
        ('MIS-2025-010', '8.5', 'Maitrise des operations', 'Production', 'Non-conformite', 'Majeure', 'Fiches suiveuses non renseignees sur la ligne B assemblage.', 'Haute', 88),
        ('MIS-2025-010', '7.1.5', 'Ressources de surveillance', 'Maintenance', 'Non-conformite', 'Moyenne', 'Cles dynamometriques utilisees au-dela date etalonnage.', 'Haute', 82),
        ('MIS-2025-010', '8.7', 'Elements non conformes', 'Production', 'Non-conformite', 'Majeure', 'Pieces rebutees stockees sans etiquetage rouge.', 'Haute', 85),
        ('MIS-2025-010', '7.2', 'Competences', 'RH', 'Remarque', 'Faible', 'Attestation formation securite operateur non signee.', 'Faible', 35),
        ('MIS-2025-010', '8.5.1', 'Maitrise de la production', 'Production', 'Non-conformite', 'Moyenne', 'Parametres soudure non conformes aux gammes.', 'Haute', 78),
        ('MIS-2025-010', '7.5', 'Informations documentees', 'Qualite', 'Remarque', 'Faible', 'Procedure autocontrole affichee en version perimee.', 'Moyenne', 55),
        ('MIS-2025-010', '6.1', 'Actions face aux risques', 'Direction', 'Remarque', 'Faible', 'Mise a jour cartographie des risques non finalisee.', 'Moyenne', 50),
        ('MIS-2025-010', '9.1', 'Surveillance et mesure', 'Qualite', 'Piste de progres', 'Faible', 'Optimiser tableau de bord des rebuts.', 'Faible', 25),
        ('MIS-2025-004', '8.4', 'Prestataires externes', 'Achats', 'Non-conformite', 'Majeure', 'Transporteurs critiques utilises sans homologation.', 'Haute', 86),
        ('MIS-2025-004', '8.4.2', 'Type et etendue du controle', 'Achats', 'Non-conformite', 'Moyenne', 'Absence grille evaluation periodique fournisseurs.', 'Haute', 79),
        ('MIS-2025-004', '8.6', 'Liberation des produits', 'Reception', 'Non-conformite', 'Moyenne', 'Controle conformite livraison non signe.', 'Haute', 74),
        ('MIS-2025-004', '8.4.3', 'Informations prestataires', 'Achats', 'Remarque', 'Faible', 'Cahier des charges envoye sans accuse reception.', 'Faible', 40),
        ('MIS-2025-004', '10.2', 'Action corrective', 'Qualite', 'Non-conformite', 'Moyenne', 'Reclamation fournisseur restee ouverte 90 jours.', 'Haute', 76),
        ('MIS-2024-012', '5.1', 'Leadership', 'Direction', 'Non-conformite', 'Majeure', 'Objectifs qualite non declines aux responsables.', 'Haute', 80),
        ('MIS-2024-012', '9.3', 'Revue de direction', 'Direction', 'Non-conformite', 'Moyenne', 'Revue direction sans analyse efficacite actions.', 'Haute', 75),
        ('MIS-2024-012', '7.2', 'Competences', 'RH', 'Non-conformite', 'Moyenne', 'Habilitations electriques arrivees a echeance.', 'Haute', 77),
        ('MIS-2024-012', '4.2', 'Parties interessees', 'Direction', 'Remarque', 'Faible', 'Matrice exigences reglementaires non actualisee.', 'Moyenne', 52),
        ('MIS-2024-012', '9.2', 'Audit interne', 'Qualite', 'Remarque', 'Faible', 'Planning annuel audits decale sans justification.', 'Moyenne', 48),
        ('MIS-2024-012', '10.3', 'Amelioration continue', 'Qualite', 'Piste de progres', 'Faible', 'Digitaliser recueil suggestions personnel.', 'Faible', 20),
        ('MIS-2024-012', '8.2', 'Exigences produits', 'Commercial', 'Remarque', 'Faible', 'Validation avenants contrats sans double signature.', 'Moyenne', 58),
    ]
    rows = []
    for i, (m, c, ct, p, ft, s, desc, prio, crit) in enumerate(data, start=1):
        model_text = f'Mission: {m} | Processus: {p} | Clause {c} {ct} | Type: {ft} | Gravite: {s} | Constat: {desc}'
        rows.append({
            'finding_id': i, 'mission_code': m, 'clause_code': c, 'clause_title': ct, 'process_name': p,
            'finding_type': ft, 'severity': s, 'finding_description': desc, 'model_text': model_text,
            'target_priority': prio, 'target_criticality': crit, 'target_source': 'expert_validated',
        })
    return pd.DataFrame(rows)

def get_demo_process_vigilance(source_code='MIS-2025-010'):
    return pd.DataFrame([
        {'process_name': 'Production & Assemblage', 'findings_count': 6, 'nonconformities_count': 4, 'remarks_count': 1, 'improvements_count': 1, 'capped_score': 85, 'vigilance_level': 'Elevee', 'explanation_summary': 'Non-conformites majeures sur la tracabilite.'},
        {'process_name': 'Achats & Prestataires', 'findings_count': 5, 'nonconformities_count': 3, 'remarks_count': 1, 'improvements_count': 1, 'capped_score': 78, 'vigilance_level': 'Elevee', 'explanation_summary': 'Evaluations annuelles de transporteurs manquantes.'},
        {'process_name': 'Maintenance & Metrologie', 'findings_count': 4, 'nonconformities_count': 2, 'remarks_count': 2, 'improvements_count': 0, 'capped_score': 72, 'vigilance_level': 'Elevee', 'explanation_summary': 'Instruments de mesure hors date etalonnage.'},
        {'process_name': 'Qualite & Amelioration', 'findings_count': 4, 'nonconformities_count': 1, 'remarks_count': 2, 'improvements_count': 1, 'capped_score': 55, 'vigilance_level': 'Moyenne', 'explanation_summary': 'Procedures autocontrole a harmoniser.'},
        {'process_name': 'Direction & Pilotage', 'findings_count': 2, 'nonconformities_count': 0, 'remarks_count': 2, 'improvements_count': 0, 'capped_score': 42, 'vigilance_level': 'Faible', 'explanation_summary': 'Cartographie des risques a finaliser.'},
    ])

def get_demo_clause_vigilance(source_code='MIS-2025-010'):
    return pd.DataFrame([
        {'clause_code': '8.5', 'clause_title': 'Production et prestation de service', 'findings_count': 4, 'nonconformities_count': 3, 'remarks_count': 1, 'improvements_count': 0, 'capped_score': 88, 'vigilance_level': 'Elevee', 'explanation_summary': 'Defauts instructions et fiches suiveuses.'},
        {'clause_code': '8.4', 'clause_title': 'Prestataires externes', 'findings_count': 3, 'nonconformities_count': 2, 'remarks_count': 1, 'improvements_count': 0, 'capped_score': 82, 'vigilance_level': 'Elevee', 'explanation_summary': 'Absence agrement formel sous-traitants.'},
        {'clause_code': '7.1.5', 'clause_title': 'Ressources de mesure', 'findings_count': 2, 'nonconformities_count': 2, 'remarks_count': 0, 'improvements_count': 0, 'capped_score': 78, 'vigilance_level': 'Elevee', 'explanation_summary': 'Etalonnages metrologie expires.'},
        {'clause_code': '8.7', 'clause_title': 'Elements non conformes', 'findings_count': 2, 'nonconformities_count': 1, 'remarks_count': 1, 'improvements_count': 0, 'capped_score': 74, 'vigilance_level': 'Elevee', 'explanation_summary': 'Zone rebuts non delimitee.'},
        {'clause_code': '10.2', 'clause_title': 'Actions correctives', 'findings_count': 2, 'nonconformities_count': 1, 'remarks_count': 1, 'improvements_count': 0, 'capped_score': 68, 'vigilance_level': 'Moyenne', 'explanation_summary': 'Actions cloturees sans preuve efficacite.'},
        {'clause_code': '7.2', 'clause_title': 'Competences', 'findings_count': 2, 'nonconformities_count': 1, 'remarks_count': 1, 'improvements_count': 0, 'capped_score': 58, 'vigilance_level': 'Moyenne', 'explanation_summary': 'Habilitations en retard.'},
        {'clause_code': '6.1', 'clause_title': 'Actions face aux risques', 'findings_count': 1, 'nonconformities_count': 0, 'remarks_count': 1, 'improvements_count': 0, 'capped_score': 45, 'vigilance_level': 'Faible', 'explanation_summary': 'Cartographie des risques a actualiser.'},
    ])

def get_demo_top_alerts(source_code='MIS-2025-010'):
    return pd.DataFrame([
        {'alert_label': '8.5 - Production et prestation de service', 'alert_dimension': 'Clause ISO', 'alert_key': '8.5', 'capped_score': 88, 'vigilance_level': 'Elevee', 'explanation_summary': '3 non-conformites historiques sur la tracabilite.'},
        {'alert_label': 'Processus Production & Assemblage', 'alert_dimension': 'Processus', 'alert_key': 'Production', 'capped_score': 85, 'vigilance_level': 'Elevee', 'explanation_summary': 'Score vigilance eleve suite a 6 constats.'},
        {'alert_label': '8.4 - Maitrise prestataires externes', 'alert_dimension': 'Clause ISO', 'alert_key': '8.4', 'capped_score': 82, 'vigilance_level': 'Elevee', 'explanation_summary': 'Transporteurs sans evaluation annuelle.'},
        {'alert_label': '7.1.5 - Etalonnage equipements de mesure', 'alert_dimension': 'Clause ISO', 'alert_key': '7.1.5', 'capped_score': 78, 'vigilance_level': 'Elevee', 'explanation_summary': 'Instruments metrologie hors echeance.'},
        {'alert_label': 'Processus Achats & Fournisseurs', 'alert_dimension': 'Processus', 'alert_key': 'Achats', 'capped_score': 78, 'vigilance_level': 'Elevee', 'explanation_summary': 'Non-conformites reception et agrement.'},
    ])

def generate_demo_smart_checklist(batch_code, target_code='MIS-2026-001', source_code='MIS-2025-010'):
    questions = [
        ('8.5', 'Production et prestation de service', 'Tracabilite', 'Les fiches suiveuses et numeros de lots sont-ils completes a chaque etape ?', 'Haute', 'Fiches suiveuses signees, tracabilite ERP', 'Historique : 3 NC tracabilite.'),
        ('7.1.5', 'Ressources de surveillance et mesure', 'Metrologie', 'Tous les instruments de mesure disposent-ils dun certificat etalonnage valide ?', 'Haute', 'Registre metrologie, etiquettes validite', 'Historique : outils hors validite en 2025.'),
        ('8.7', 'Elements non conformes', 'Rebuts', 'Les pieces non conformes sont-elles isolees en zone rouge avec fiche anomalie ?', 'Haute', 'Zone rouge balisee, fiches rebut', 'Historique : pieces stockees sans marquage.'),
        ('8.4', 'Prestataires externes', 'Sous-traitance', 'Les sous-traitants font-ils lobjet dune evaluation annuelle selon les criteres ?', 'Haute', 'Grilles evaluation fournisseurs, audits', 'Historique : absence evaluation periodique.'),
        ('10.2', 'Action corrective', 'Actions correctives', 'Les actions correctives issues de laudit precedent ont-elles ete verifiees en efficacite ?', 'Haute', 'Plans actions clotures, preuves efficacite', 'Historique : actions restees ouvertes.'),
        ('7.2', 'Competences', 'Habilitations', 'Les habilitations des operateurs soudure et controle sont-elles a jour ?', 'Moyenne', 'Matrice competences, plannings formations', 'Regle metier ISO 9001 7.2.'),
        ('8.1', 'Planification operationnelle', 'Gammes fabrication', 'Les instructions operatoires correspondent-elles a la derniere version validee ?', 'Moyenne', 'Instructions poste, indice revision', 'Regle metier ISO 9001 8.1.'),
        ('8.6', 'Liberation des produits', 'Controle final', 'Les proces-verbaux de controle final sont-ils signes par le controleur habilite ?', 'Moyenne', 'PV controle, signatures, bordereaux', 'Regle metier ISO 9001 8.6.'),
        ('6.1', 'Actions face aux risques', 'Gestion des risques', 'Les risques operationnels ont-ils ete reevalues suite aux aleas ?', 'Moyenne', 'Cartographie risques atelier', 'Regle metier ISO 9001 6.1.'),
        ('7.5', 'Informations documentees', 'Documentation', 'Les enregistrements qualite sont-ils archives et proteges ?', 'Faible', 'Classeurs atelier, sauvegarde reseau', 'Regle standard ISO 9001 7.5.'),
        ('9.1', 'Surveillance et mesure', 'Indicateurs', 'Le taux de rebut hebdomadaire est-il affiche et analyse lors des briefs ?', 'Faible', 'Tableau affichage, compte-rendu brief', 'Regle standard ISO 9001 9.1.'),
        ('5.1', 'Leadership', 'Engagement direction', 'La politique qualite et objectifs sont-ils communiques aux equipes ?', 'Faible', 'Affichage politique qualite', 'Regle standard ISO 9001 5.1.'),
    ]
    rows = []
    run_id = f'RUN-{batch_code}'
    for i, (clause_c, clause_t, theme, q_text, prio, evidence, reco) in enumerate(questions, start=1):
        rows.append({
            'generation_run_id': run_id,
            'generation_batch_code': batch_code,
            'target_mission_code': target_code,
            'target_mission_title': 'Audit Qualite Usine & Lignes Montage',
            'source_mission_code': source_code,
            'source_mission_title': 'Audit Interne Production 2025',
            'display_order': i,
            'clause_code': clause_c,
            'clause_title': clause_t,
            'theme': theme,
            'question_text': q_text,
            'generated_priority': prio,
            'recommendation_label': reco,
            'expected_evidence': evidence,
            'conformity_status': 'A verifier',
            'generation_mode': 'Historique recommande',
            'context_sector': 'Industrie Mecanique',
            'context_process': 'Production & Assemblage',
            'context_objective': 'Verifier maitrise et tracabilite',
            'context_scope': 'Lignes de montage A et B',
        })
    return pd.DataFrame(rows)

def get_demo_generation_runs(active_batches=None):
    runs = [
        {
            'generation_run_id': 'RUN-DEMO-001',
            'generation_batch_code': 'BATCH-DEMO-PRODUCTION',
            'target_mission_code': 'MIS-2026-001',
            'target_mission_title': 'Audit Qualite Usine & Lignes Montage',
            'source_mission_code': 'MIS-2025-010',
            'source_mission_title': 'Audit Interne Production 2025',
            'generated_at': '2026-08-18 10:30:00',
            'recommendations_count': 8,
            'checklist_items_count': 12,
            'generation_mode': 'Historique recommande',
            'status': 'Termine',
        }
    ]
    if active_batches:
        for b in active_batches:
            if b['generation_batch_code'] != 'BATCH-DEMO-PRODUCTION':
                runs.insert(0, b)
    return pd.DataFrame(runs)

def get_demo_kpi_by_priority(checklist_df):
    if checklist_df is None or checklist_df.empty:
        return pd.DataFrame([
            {'generated_priority': 'Haute', 'questions_count': 5},
            {'generated_priority': 'Moyenne', 'questions_count': 4},
            {'generated_priority': 'Faible', 'questions_count': 3},
        ])
    kpi = checklist_df.groupby('generated_priority').size().reset_index(name='questions_count')
    order = {'Haute': 1, 'Moyenne': 2, 'Faible': 3}
    kpi['_order'] = kpi['generated_priority'].map(order).fillna(9)
    return kpi.sort_values('_order').drop(columns=['_order']).reset_index(drop=True)

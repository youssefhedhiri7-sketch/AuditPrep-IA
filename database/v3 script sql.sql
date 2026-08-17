-- ============================================================
-- PROJET : AuditPrep IA
-- SCRIPT : Mise à niveau métier V2 de la base PostgreSQL
-- OBJECTIF : Enrichir la base V1 avec les objets réels issus
--            des documents d'audit fournis par l'entreprise.
--
-- IMPORTANT :
-- - Ce script s'exécute APRÈS le script SQL V1.
-- - Il ne supprime pas la base existante.
-- - Il ajoute de nouvelles tables et enrichit certaines tables.
-- ============================================================

SET search_path TO auditprep;

-- ============================================================
-- 1. RÉFÉRENTIEL DES NORMES ET CLAUSES ISO
-- ============================================================

CREATE TABLE IF NOT EXISTS standards (
    standard_id SERIAL PRIMARY KEY,
    standard_code VARCHAR(80) NOT NULL,
    standard_version VARCHAR(40) NOT NULL,
    standard_title VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_standard_code_version UNIQUE (standard_code, standard_version)
);

CREATE TABLE IF NOT EXISTS standard_clauses (
    clause_id SERIAL PRIMARY KEY,
    standard_id INT NOT NULL REFERENCES standards(standard_id) ON DELETE CASCADE,
    clause_code VARCHAR(40) NOT NULL,
    clause_title VARCHAR(255) NOT NULL,
    parent_clause_id INT REFERENCES standard_clauses(clause_id) ON DELETE SET NULL,
    clause_level INT NOT NULL DEFAULT 1 CHECK (clause_level >= 1),
    is_auditable BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_standard_clause UNIQUE (standard_id, clause_code)
);

CREATE INDEX IF NOT EXISTS idx_standard_clauses_standard_id
    ON standard_clauses(standard_id);

CREATE INDEX IF NOT EXISTS idx_standard_clauses_clause_code
    ON standard_clauses(clause_code);

-- ============================================================
-- 2. CLIENTS ET SITES AUDITÉS
-- ============================================================

CREATE TABLE IF NOT EXISTS clients (
    client_id SERIAL PRIMARY KEY,
    client_name VARCHAR(255) NOT NULL UNIQUE,
    sector VARCHAR(180),
    country VARCHAR(120),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS client_sites (
    site_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    site_name VARCHAR(255) NOT NULL,
    address TEXT,
    city VARCHAR(150),
    country VARCHAR(120),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_client_site UNIQUE (client_id, site_name)
);

CREATE INDEX IF NOT EXISTS idx_client_sites_client_id
    ON client_sites(client_id);

-- ============================================================
-- 3. ENRICHISSEMENT DES MISSIONS D'AUDIT
-- ============================================================

ALTER TABLE audit_missions
    ADD COLUMN IF NOT EXISTS client_id INT REFERENCES clients(client_id) ON DELETE SET NULL;

ALTER TABLE audit_missions
    ADD COLUMN IF NOT EXISTS site_id INT REFERENCES client_sites(site_id) ON DELETE SET NULL;

ALTER TABLE audit_missions
    ADD COLUMN IF NOT EXISTS primary_standard_id INT REFERENCES standards(standard_id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_audit_missions_client_id
    ON audit_missions(client_id);

CREATE INDEX IF NOT EXISTS idx_audit_missions_site_id
    ON audit_missions(site_id);

CREATE INDEX IF NOT EXISTS idx_audit_missions_primary_standard_id
    ON audit_missions(primary_standard_id);

-- ============================================================
-- 4. ÉQUIPE D'AUDIT ET PROCESSUS AUDITÉS
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_team_members (
    audit_team_member_id SERIAL PRIMARY KEY,
    mission_id INT NOT NULL REFERENCES audit_missions(mission_id) ON DELETE CASCADE,
    person_name VARCHAR(255) NOT NULL,
    role_in_audit VARCHAR(120) NOT NULL,
    internal_user_id INT REFERENCES users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_audit_team_member UNIQUE (mission_id, person_name, role_in_audit)
);

CREATE INDEX IF NOT EXISTS idx_audit_team_members_mission_id
    ON audit_team_members(mission_id);

CREATE TABLE IF NOT EXISTS processes (
    process_id SERIAL PRIMARY KEY,
    process_code VARCHAR(80),
    process_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS mission_processes (
    mission_process_id SERIAL PRIMARY KEY,
    mission_id INT NOT NULL REFERENCES audit_missions(mission_id) ON DELETE CASCADE,
    process_id INT NOT NULL REFERENCES processes(process_id),
    priority_level_id INT REFERENCES priority_levels(priority_level_id) ON DELETE SET NULL,
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_mission_process UNIQUE (mission_id, process_id)
);

CREATE INDEX IF NOT EXISTS idx_mission_processes_mission_id
    ON mission_processes(mission_id);

CREATE INDEX IF NOT EXISTS idx_mission_processes_process_id
    ON mission_processes(process_id);

-- ============================================================
-- 5. PLAN D'AUDIT ET PROGRAMME HORAIRE
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_plans (
    audit_plan_id SERIAL PRIMARY KEY,
    mission_id INT NOT NULL UNIQUE REFERENCES audit_missions(mission_id) ON DELETE CASCADE,
    plan_reference VARCHAR(120),
    plan_revision VARCHAR(80),
    plan_issue_date DATE,
    audit_date DATE,
    scope_text TEXT,
    objectives_text TEXT,
    general_notes TEXT,
    plan_status VARCHAR(80) NOT NULL DEFAULT 'Brouillon',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_audit_plan_status CHECK (plan_status IN ('Brouillon', 'Validé', 'Archivé'))
);

CREATE TABLE IF NOT EXISTS audit_plan_sessions (
    audit_plan_session_id SERIAL PRIMARY KEY,
    audit_plan_id INT NOT NULL REFERENCES audit_plans(audit_plan_id) ON DELETE CASCADE,
    start_time TIME,
    end_time TIME,
    session_title VARCHAR(255) NOT NULL,
    process_id INT REFERENCES processes(process_id) ON DELETE SET NULL,
    function_label VARCHAR(255),
    assigned_auditor_label VARCHAR(255),
    session_notes TEXT,
    display_order INT NOT NULL CHECK (display_order >= 1),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_audit_plan_session_order UNIQUE (audit_plan_id, display_order)
);

CREATE TABLE IF NOT EXISTS audit_plan_session_clauses (
    session_clause_id SERIAL PRIMARY KEY,
    audit_plan_session_id INT NOT NULL REFERENCES audit_plan_sessions(audit_plan_session_id) ON DELETE CASCADE,
    clause_id INT NOT NULL REFERENCES standard_clauses(clause_id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_session_clause UNIQUE (audit_plan_session_id, clause_id)
);

CREATE INDEX IF NOT EXISTS idx_audit_plans_mission_id
    ON audit_plans(mission_id);

CREATE INDEX IF NOT EXISTS idx_audit_plan_sessions_plan_id
    ON audit_plan_sessions(audit_plan_id);

CREATE INDEX IF NOT EXISTS idx_audit_plan_sessions_process_id
    ON audit_plan_sessions(process_id);

CREATE INDEX IF NOT EXISTS idx_audit_plan_session_clauses_session_id
    ON audit_plan_session_clauses(audit_plan_session_id);

CREATE INDEX IF NOT EXISTS idx_audit_plan_session_clauses_clause_id
    ON audit_plan_session_clauses(clause_id);

-- ============================================================
-- 6. ENRICHISSEMENT DU RÉFÉRENTIEL DE POINTS DE CONTRÔLE
-- ============================================================

ALTER TABLE control_points_repository
    ADD COLUMN IF NOT EXISTS clause_id INT REFERENCES standard_clauses(clause_id) ON DELETE SET NULL;

ALTER TABLE control_points_repository
    ADD COLUMN IF NOT EXISTS process_id INT REFERENCES processes(process_id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_control_points_repository_clause_id
    ON control_points_repository(clause_id);

CREATE INDEX IF NOT EXISTS idx_control_points_repository_process_id
    ON control_points_repository(process_id);

-- ============================================================
-- 7. ENRICHISSEMENT DES CHECK-LISTS
-- ============================================================

ALTER TABLE checklist_items
    ADD COLUMN IF NOT EXISTS clause_id INT REFERENCES standard_clauses(clause_id) ON DELETE SET NULL;

ALTER TABLE checklist_items
    ADD COLUMN IF NOT EXISTS conformity_status VARCHAR(80);

ALTER TABLE checklist_items
    ADD COLUMN IF NOT EXISTS finding_comment TEXT;

ALTER TABLE checklist_items
    ADD COLUMN IF NOT EXISTS examined_evidence TEXT;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_checklist_item_conformity_status'
    ) THEN
        ALTER TABLE checklist_items
            ADD CONSTRAINT chk_checklist_item_conformity_status
            CHECK (
                conformity_status IS NULL
                OR conformity_status IN ('Conforme', 'Non conforme', 'Non évalué')
            );
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_checklist_items_clause_id
    ON checklist_items(clause_id);

-- ============================================================
-- 8. RAPPORTS D'AUDIT, TYPES DE CONSTATS ET CONSTATS
-- ============================================================

CREATE TABLE IF NOT EXISTS finding_types (
    finding_type_id SERIAL PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    label VARCHAR(180) NOT NULL,
    description TEXT,
    risk_weight NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (risk_weight >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit_reports (
    audit_report_id SERIAL PRIMARY KEY,
    mission_id INT NOT NULL UNIQUE REFERENCES audit_missions(mission_id) ON DELETE CASCADE,
    report_title VARCHAR(255) NOT NULL,
    report_date DATE,
    methodology_text TEXT,
    conclusion_text TEXT,
    recommendations_text TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit_findings (
    finding_id SERIAL PRIMARY KEY,
    audit_report_id INT NOT NULL REFERENCES audit_reports(audit_report_id) ON DELETE CASCADE,
    process_id INT REFERENCES processes(process_id) ON DELETE SET NULL,
    finding_type_id INT NOT NULL REFERENCES finding_types(finding_type_id),
    clause_id INT REFERENCES standard_clauses(clause_id) ON DELETE SET NULL,
    finding_description TEXT NOT NULL,
    finding_status VARCHAR(80) NOT NULL DEFAULT 'Ouvert',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_finding_status CHECK (finding_status IN ('Ouvert', 'Traité', 'À suivre', 'Clôturé'))
);

CREATE INDEX IF NOT EXISTS idx_audit_reports_mission_id
    ON audit_reports(mission_id);

CREATE INDEX IF NOT EXISTS idx_audit_findings_report_id
    ON audit_findings(audit_report_id);

CREATE INDEX IF NOT EXISTS idx_audit_findings_process_id
    ON audit_findings(process_id);

CREATE INDEX IF NOT EXISTS idx_audit_findings_type_id
    ON audit_findings(finding_type_id);

CREATE INDEX IF NOT EXISTS idx_audit_findings_clause_id
    ON audit_findings(clause_id);

-- ============================================================
-- 9. NON-CONFORMITÉS ET ACTIONS CORRECTIVES
-- ============================================================

CREATE TABLE IF NOT EXISTS nonconformities (
    nonconformity_id SERIAL PRIMARY KEY,
    finding_id INT UNIQUE REFERENCES audit_findings(finding_id) ON DELETE SET NULL,
    source_label VARCHAR(180),
    description TEXT NOT NULL,
    cause_analysis TEXT,
    detected_date DATE,
    severity_level VARCHAR(80),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS corrective_actions (
    corrective_action_id SERIAL PRIMARY KEY,
    nonconformity_id INT NOT NULL REFERENCES nonconformities(nonconformity_id) ON DELETE CASCADE,
    action_type VARCHAR(120) NOT NULL,
    action_description TEXT NOT NULL,
    responsible_name VARCHAR(255),
    planned_due_date DATE,
    actual_completion_date DATE,
    action_status VARCHAR(80) NOT NULL DEFAULT 'Envisagée',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_corrective_action_type CHECK (
        action_type IN ('Correction immédiate', 'Action corrective')
    ),
    CONSTRAINT chk_corrective_action_status CHECK (
        action_status IN ('Envisagée', 'Planifiée', 'Réalisée', 'Non réalisée', 'Annulée')
    )
);

CREATE TABLE IF NOT EXISTS corrective_action_effectiveness_reviews (
    effectiveness_review_id SERIAL PRIMARY KEY,
    corrective_action_id INT NOT NULL REFERENCES corrective_actions(corrective_action_id) ON DELETE CASCADE,
    review_date DATE,
    reviewer_name VARCHAR(255),
    is_effective BOOLEAN,
    conclusion_text TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_nonconformities_finding_id
    ON nonconformities(finding_id);

CREATE INDEX IF NOT EXISTS idx_corrective_actions_nonconformity_id
    ON corrective_actions(nonconformity_id);

CREATE INDEX IF NOT EXISTS idx_effectiveness_reviews_action_id
    ON corrective_action_effectiveness_reviews(corrective_action_id);

-- ============================================================
-- 10. ENRICHISSEMENT DES TABLES HISTORIQUES POUR L'IA
-- ============================================================

ALTER TABLE historical_audit_outcomes
    ADD COLUMN IF NOT EXISTS process_id INT REFERENCES processes(process_id) ON DELETE SET NULL;

ALTER TABLE historical_audit_outcomes
    ADD COLUMN IF NOT EXISTS dominant_clause_id INT REFERENCES standard_clauses(clause_id) ON DELETE SET NULL;

ALTER TABLE historical_audit_outcomes
    ADD COLUMN IF NOT EXISTS nonconformities_count INT NOT NULL DEFAULT 0 CHECK (nonconformities_count >= 0);

ALTER TABLE historical_audit_outcomes
    ADD COLUMN IF NOT EXISTS remarks_count INT NOT NULL DEFAULT 0 CHECK (remarks_count >= 0);

ALTER TABLE historical_audit_outcomes
    ADD COLUMN IF NOT EXISTS improvements_count INT NOT NULL DEFAULT 0 CHECK (improvements_count >= 0);

CREATE INDEX IF NOT EXISTS idx_historical_outcomes_process_id
    ON historical_audit_outcomes(process_id);

CREATE INDEX IF NOT EXISTS idx_historical_outcomes_dominant_clause_id
    ON historical_audit_outcomes(dominant_clause_id);

-- ============================================================
-- 11. DONNÉES DE RÉFÉRENCE : NORME ISO 9001:2015
-- ============================================================

INSERT INTO standards (
    standard_code,
    standard_version,
    standard_title,
    description
)
VALUES (
    'ISO 9001',
    '2015',
    'Systèmes de management de la qualité — Exigences',
    'Référentiel principal utilisé pour les audits qualité et les check-lists du projet AuditPrep IA.'
)
ON CONFLICT (standard_code, standard_version) DO NOTHING;

-- ============================================================
-- 12. DONNÉES DE RÉFÉRENCE : CLAUSES ISO 9001 UTILISÉES
-- ============================================================

-- Clauses principales 4 à 10 et clauses opérationnelles utiles
INSERT INTO standard_clauses (standard_id, clause_code, clause_title, clause_level, is_auditable)
SELECT s.standard_id, v.clause_code, v.clause_title, v.clause_level, TRUE
FROM standards s
CROSS JOIN (
    VALUES
        ('4', 'Contexte de l’organisme', 1),
        ('4.1', 'Compréhension de l’organisme et de son contexte', 2),
        ('4.2', 'Compréhension des besoins et attentes des parties intéressées', 2),
        ('4.3', 'Détermination du domaine d’application du SMQ', 2),
        ('4.4', 'Système de management de la qualité et ses processus', 2),
        ('5', 'Leadership', 1),
        ('5.1', 'Leadership et engagement', 2),
        ('5.2', 'Politique qualité', 2),
        ('5.3', 'Rôles, responsabilités et autorités', 2),
        ('6', 'Planification', 1),
        ('6.1', 'Actions face aux risques et opportunités', 2),
        ('6.2', 'Objectifs qualité et planification', 2),
        ('6.3', 'Planification des modifications', 2),
        ('7', 'Support', 1),
        ('7.1', 'Ressources', 2),
        ('7.1.3', 'Infrastructure', 3),
        ('7.1.4', 'Environnement pour la mise en œuvre des processus', 3),
        ('7.1.5', 'Ressources pour la surveillance et la mesure', 3),
        ('7.1.6', 'Connaissances organisationnelles', 3),
        ('7.2', 'Compétences', 2),
        ('7.3', 'Sensibilisation', 2),
        ('7.4', 'Communication', 2),
        ('7.5', 'Informations documentées', 2),
        ('8', 'Réalisation des activités opérationnelles', 1),
        ('8.1', 'Planification et maîtrise opérationnelles', 2),
        ('8.2', 'Exigences relatives aux produits et services', 2),
        ('8.4', 'Maîtrise des processus, produits et services fournis par des prestataires externes', 2),
        ('8.5', 'Production et prestation de service', 2),
        ('8.6', 'Libération des produits et services', 2),
        ('8.7', 'Maîtrise des éléments de sortie non conformes', 2),
        ('9', 'Évaluation des performances', 1),
        ('9.1', 'Surveillance, mesure, analyse et évaluation', 2),
        ('9.1.2', 'Satisfaction du client', 3),
        ('9.2', 'Audit interne', 2),
        ('9.3', 'Revue de direction', 2),
        ('10', 'Amélioration', 1),
        ('10.2', 'Non-conformité et action corrective', 2),
        ('10.3', 'Amélioration continue', 2)
) AS v(clause_code, clause_title, clause_level)
WHERE s.standard_code = 'ISO 9001'
  AND s.standard_version = '2015'
ON CONFLICT (standard_id, clause_code) DO NOTHING;

-- Mise à jour de la hiérarchie des clauses principales
UPDATE standard_clauses child
SET parent_clause_id = parent.clause_id
FROM standard_clauses parent
JOIN standards s ON s.standard_id = parent.standard_id
WHERE child.standard_id = s.standard_id
  AND child.standard_id = parent.standard_id
  AND child.parent_clause_id IS NULL
  AND child.clause_code LIKE parent.clause_code || '.%'
  AND parent.clause_level = child.clause_level - 1;

-- ============================================================
-- 13. DONNÉES DE RÉFÉRENCE : PROCESSUS AUDITÉS
-- ============================================================

INSERT INTO processes (process_code, process_name, description)
VALUES
    ('DIR', 'Direction', 'Pilotage de la direction et décisions stratégiques.'),
    ('MQ', 'Management qualité et amélioration', 'SMQ, pilotage qualité, amélioration continue et revue de direction.'),
    ('LOG', 'Logistique', 'Processus logistique, flux, achats et maîtrise opérationnelle associée.'),
    ('MAINT', 'Maintenance', 'Maintenance, infrastructures et moyens de surveillance.'),
    ('GRH', 'Gestion des Ressources Humaines', 'Compétences, sensibilisation et gestion RH.'),
    ('PROD', 'Réalisation du produit', 'Production, maîtrise opérationnelle, libération et non-conformités produit.'),
    ('HSE', 'HSE', 'Hygiène, sécurité, environnement et exigences associées.'),
    ('MANUF', 'Manufacturing', 'Processus industriels et activités de fabrication.')
ON CONFLICT (process_name) DO NOTHING;

-- ============================================================
-- 14. DONNÉES DE RÉFÉRENCE : TYPES DE CONSTATS
-- ============================================================

INSERT INTO finding_types (code, label, description, risk_weight)
VALUES
    ('NC', 'Non-conformité', 'Écart avéré à une exigence normative, réglementaire ou interne.', 3.00),
    ('RQ', 'Remarque', 'Point nécessitant une attention ou une clarification.', 1.50),
    ('AM', 'Amélioration', 'Opportunité d’amélioration identifiée.', 1.00),
    ('PS', 'Point sensible', 'Point pouvant évoluer vers un écart s’il n’est pas traité.', 2.00)
ON CONFLICT (code) DO NOTHING;

-- ============================================================
-- 15. EXEMPLE D'INTÉGRATION D'UN PLAN D'AUDIT RÉEL STRUCTURÉ
--     Basé sur le document "Plan audit Renew_SECURE 2026"
-- ============================================================

INSERT INTO clients (client_name, sector, country)
VALUES ('SECURE', 'Confection textile et articles techniques', 'Tunisie')
ON CONFLICT (client_name) DO NOTHING;

INSERT INTO client_sites (client_id, site_name, address, city, country)
SELECT
    c.client_id,
    'Site de Monastir',
    'Boulevard de l’environnement, 5042 Mesjed Aissa',
    'Monastir',
    'Tunisie'
FROM clients c
WHERE c.client_name = 'SECURE'
ON CONFLICT (client_id, site_name) DO NOTHING;

-- Création d'une mission de démonstration dédiée au plan SECURE
INSERT INTO audit_missions (
    mission_code,
    mission_title,
    client_name,
    audit_type_id,
    planned_audit_date,
    created_by,
    owner_id,
    mission_status_id,
    description,
    client_id,
    site_id,
    primary_standard_id
)
SELECT
    'AUD-SECURE-2026-RENOUV',
    'Audit de renouvellement ISO 9001:2015 – SECURE',
    c.client_name,
    at.audit_type_id,
    DATE '2026-05-12',
    u.user_id,
    u.user_id,
    ms.mission_status_id,
    'Mission structurée à partir du plan d’audit de renouvellement ISO 9001 fourni comme exemple métier.',
    c.client_id,
    cs.site_id,
    s.standard_id
FROM clients c
JOIN client_sites cs ON cs.client_id = c.client_id AND cs.site_name = 'Site de Monastir'
JOIN audit_types at ON at.label = 'Audit de conformité'
JOIN mission_statuses ms ON ms.label = 'En cours'
JOIN users u ON u.email = 'omar.pfe@auditprep.local'
JOIN standards s ON s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE c.client_name = 'SECURE'
ON CONFLICT (mission_code) DO NOTHING;

-- Équipe d'audit
INSERT INTO audit_team_members (mission_id, person_name, role_in_audit)
SELECT am.mission_id, 'Imed BEN YEDDER', 'Responsable d’audit'
FROM audit_missions am
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
ON CONFLICT (mission_id, person_name, role_in_audit) DO NOTHING;

INSERT INTO audit_team_members (mission_id, person_name, role_in_audit)
SELECT am.mission_id, 'Mohamed WALHA', 'Auditeur'
FROM audit_missions am
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
ON CONFLICT (mission_id, person_name, role_in_audit) DO NOTHING;

-- Périmètre de la mission
INSERT INTO audit_scopes (
    mission_id,
    main_objective,
    secondary_objectives,
    audit_perimeter,
    concerned_processes,
    concerned_departments,
    known_constraints,
    initial_criticality_level_id,
    completed
)
SELECT
    am.mission_id,
    'Déterminer la conformité du système de management aux critères de l’audit ISO 9001:2015.',
    'Évaluer la capacité du système à satisfaire les exigences applicables, apprécier son efficacité et identifier les opportunités d’amélioration.',
    'Confection des articles textiles et des articles techniques destinés à l’automobile et à l’aéronautique, articles de transport et de levage.',
    'Direction ; Management qualité ; Logistique ; Maintenance ; Gestion des Ressources Humaines ; Réalisation du produit',
    'Direction Générale ; RMQ ; Pilotes de processus',
    'Programme modulable selon les contraintes de l’audité. Confidentialité des documents examinés.',
    cl.criticality_level_id,
    TRUE
FROM audit_missions am
JOIN criticality_levels cl ON cl.label = 'Élevée'
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
ON CONFLICT (mission_id) DO NOTHING;

-- Association mission/processus
INSERT INTO mission_processes (mission_id, process_id, priority_level_id, comment)
SELECT am.mission_id, p.process_id, pl.priority_level_id, 'Processus prévu dans le plan d’audit de renouvellement.'
FROM audit_missions am
CROSS JOIN processes p
JOIN priority_levels pl ON pl.label = 'Haute'
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
  AND p.process_name IN (
      'Direction',
      'Management qualité et amélioration',
      'Logistique',
      'Maintenance',
      'Gestion des Ressources Humaines',
      'Réalisation du produit'
  )
ON CONFLICT (mission_id, process_id) DO NOTHING;

-- Plan d'audit
INSERT INTO audit_plans (
    mission_id,
    plan_reference,
    plan_revision,
    plan_issue_date,
    audit_date,
    scope_text,
    objectives_text,
    general_notes,
    plan_status
)
SELECT
    am.mission_id,
    'QF 23',
    'Rev.02 du 06/05/2024',
    DATE '2026-05-08',
    DATE '2026-05-12',
    'Domaine d’application couvrant les activités de confection des articles textiles, articles techniques destinés à l’automobile et à l’aéronautique, ainsi que les articles de transport et de levage.',
    'Conformité du système, capacité à satisfaire les exigences applicables, efficacité du système et identification des opportunités d’amélioration.',
    'Documentation confidentielle. Audit modulable en fonction des contraintes. Les procédures de sécurité doivent être communiquées à l’équipe d’audit.',
    'Validé'
FROM audit_missions am
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
ON CONFLICT (mission_id) DO NOTHING;

-- Séquences du programme d'audit
INSERT INTO audit_plan_sessions (
    audit_plan_id,
    start_time,
    end_time,
    session_title,
    process_id,
    function_label,
    assigned_auditor_label,
    session_notes,
    display_order
)
SELECT ap.audit_plan_id, v.start_time::TIME, v.end_time::TIME, v.session_title, p.process_id,
       v.function_label, v.assigned_auditor_label, v.session_notes, v.display_order
FROM audit_plans ap
JOIN audit_missions am ON am.mission_id = ap.mission_id
CROSS JOIN (
    VALUES
        ('08:00', '08:15', 'Réunion d’ouverture', NULL, 'Direction Générale, Représentant de la Direction, RMQ', 'Équipe d’audit', 'Objectifs et déroulement de l’audit.', 1),
        ('08:15', '10:00', 'Leadership', 'Direction', 'DG / RMQ', 'Imed BEN YEDDER & Mohamed WALHA', 'Leadership, contexte, politique, objectifs, ressources et revue de direction.', 2),
        ('10:00', '11:30', 'Management qualité et amélioration', 'Management qualité et amélioration', 'RMQ', 'Imed BEN YEDDER', 'SMQ, audits internes, amélioration continue et clôture des NC antérieures.', 3),
        ('10:00', '11:30', 'Processus Logistique', 'Logistique', 'Pilote Processus', 'Mohamed WALHA', 'Risques, maîtrise opérationnelle, exigences clients, achats et sorties non conformes.', 4),
        ('11:30', '13:00', 'Processus Maintenance', 'Maintenance', 'Pilote Processus', 'Imed BEN YEDDER', 'Infrastructure, environnement de travail, surveillance et mesure.', 5),
        ('11:30', '13:00', 'Processus Gestion des Ressources Humaines', 'Gestion des Ressources Humaines', 'Pilote Processus', 'Mohamed WALHA', 'Compétence et sensibilisation.', 6),
        ('14:00', '16:00', 'Processus Réalisation du produit', 'Réalisation du produit', 'Pilote Processus', 'Imed BEN YEDDER & Mohamed WALHA', 'Production, libération, maîtrise opérationnelle et sorties non conformes.', 7),
        ('16:00', '16:30', 'Préparation de la réunion de clôture', NULL, 'Équipe d’audit', 'Équipe d’audit', 'Préparation des éléments de restitution.', 8),
        ('16:30', '17:00', 'Réunion de clôture', NULL, 'Direction Générale, Représentant de la Direction, responsables', 'Équipe d’audit', 'Présentation des résultats et analyse des éventuelles non-conformités.', 9)
) AS v(start_time, end_time, session_title, process_name, function_label, assigned_auditor_label, session_notes, display_order)
LEFT JOIN processes p ON p.process_name = v.process_name
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
ON CONFLICT (audit_plan_id, display_order) DO NOTHING;

-- ============================================================
-- 16. ASSOCIATION DES CLAUSES ISO AUX SÉQUENCES DU PLAN
-- ============================================================

-- Leadership
INSERT INTO audit_plan_session_clauses (audit_plan_session_id, clause_id)
SELECT aps.audit_plan_session_id, sc.clause_id
FROM audit_plan_sessions aps
JOIN audit_plans ap ON ap.audit_plan_id = aps.audit_plan_id
JOIN audit_missions am ON am.mission_id = ap.mission_id
JOIN standard_clauses sc ON sc.clause_code IN ('4.1', '4.2', '5.1', '5.2', '5.3', '6.2', '7.1', '9.3')
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
  AND aps.session_title = 'Leadership'
ON CONFLICT (audit_plan_session_id, clause_id) DO NOTHING;

-- Management qualité et amélioration
INSERT INTO audit_plan_session_clauses (audit_plan_session_id, clause_id)
SELECT aps.audit_plan_session_id, sc.clause_id
FROM audit_plan_sessions aps
JOIN audit_plans ap ON ap.audit_plan_id = aps.audit_plan_id
JOIN audit_missions am ON am.mission_id = ap.mission_id
JOIN standard_clauses sc ON sc.clause_code IN ('4.3', '4.4', '6.1', '6.3', '7.4', '7.1.6', '7.5', '9.1', '9.2', '9.3', '10.2', '10.3')
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
  AND aps.session_title = 'Management qualité et amélioration'
ON CONFLICT (audit_plan_session_id, clause_id) DO NOTHING;

-- Logistique
INSERT INTO audit_plan_session_clauses (audit_plan_session_id, clause_id)
SELECT aps.audit_plan_session_id, sc.clause_id
FROM audit_plan_sessions aps
JOIN audit_plans ap ON ap.audit_plan_id = aps.audit_plan_id
JOIN audit_missions am ON am.mission_id = ap.mission_id
JOIN standard_clauses sc ON sc.clause_code IN ('6.1', '8.1', '8.2', '8.4', '8.7')
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
  AND aps.session_title = 'Processus Logistique'
ON CONFLICT (audit_plan_session_id, clause_id) DO NOTHING;

-- Maintenance
INSERT INTO audit_plan_session_clauses (audit_plan_session_id, clause_id)
SELECT aps.audit_plan_session_id, sc.clause_id
FROM audit_plan_sessions aps
JOIN audit_plans ap ON ap.audit_plan_id = aps.audit_plan_id
JOIN audit_missions am ON am.mission_id = ap.mission_id
JOIN standard_clauses sc ON sc.clause_code IN ('6.1', '7.1.3', '7.1.4', '7.1.5')
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
  AND aps.session_title = 'Processus Maintenance'
ON CONFLICT (audit_plan_session_id, clause_id) DO NOTHING;

-- GRH
INSERT INTO audit_plan_session_clauses (audit_plan_session_id, clause_id)
SELECT aps.audit_plan_session_id, sc.clause_id
FROM audit_plan_sessions aps
JOIN audit_plans ap ON ap.audit_plan_id = aps.audit_plan_id
JOIN audit_missions am ON am.mission_id = ap.mission_id
JOIN standard_clauses sc ON sc.clause_code IN ('6.1', '7.2', '7.3')
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
  AND aps.session_title = 'Processus Gestion des Ressources Humaines'
ON CONFLICT (audit_plan_session_id, clause_id) DO NOTHING;

-- Réalisation du produit
INSERT INTO audit_plan_session_clauses (audit_plan_session_id, clause_id)
SELECT aps.audit_plan_session_id, sc.clause_id
FROM audit_plan_sessions aps
JOIN audit_plans ap ON ap.audit_plan_id = aps.audit_plan_id
JOIN audit_missions am ON am.mission_id = ap.mission_id
JOIN standard_clauses sc ON sc.clause_code IN ('6.1', '8.1', '8.2', '8.4', '8.5', '8.6', '8.7')
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
  AND aps.session_title = 'Processus Réalisation du produit'
ON CONFLICT (audit_plan_session_id, clause_id) DO NOTHING;

-- ============================================================
-- 17. VUES MÉTIER UTILES POUR L'APPLICATION ET LE DASHBOARD
-- ============================================================

CREATE OR REPLACE VIEW vw_audit_plan_schedule AS
SELECT
    am.mission_code,
    am.mission_title,
    ap.audit_date,
    aps.display_order,
    aps.start_time,
    aps.end_time,
    aps.session_title,
    p.process_name,
    aps.function_label,
    aps.assigned_auditor_label,
    STRING_AGG(sc.clause_code, ', ' ORDER BY sc.clause_code) AS iso_clauses
FROM audit_missions am
JOIN audit_plans ap ON ap.mission_id = am.mission_id
JOIN audit_plan_sessions aps ON aps.audit_plan_id = ap.audit_plan_id
LEFT JOIN processes p ON p.process_id = aps.process_id
LEFT JOIN audit_plan_session_clauses apsc ON apsc.audit_plan_session_id = aps.audit_plan_session_id
LEFT JOIN standard_clauses sc ON sc.clause_id = apsc.clause_id
GROUP BY
    am.mission_code,
    am.mission_title,
    ap.audit_date,
    aps.display_order,
    aps.start_time,
    aps.end_time,
    aps.session_title,
    p.process_name,
    aps.function_label,
    aps.assigned_auditor_label;

CREATE OR REPLACE VIEW vw_clause_usage_in_plan AS
SELECT
    am.mission_code,
    sc.clause_code,
    sc.clause_title,
    COUNT(DISTINCT aps.audit_plan_session_id) AS number_of_sessions
FROM audit_missions am
JOIN audit_plans ap ON ap.mission_id = am.mission_id
JOIN audit_plan_sessions aps ON aps.audit_plan_id = ap.audit_plan_id
JOIN audit_plan_session_clauses apsc ON apsc.audit_plan_session_id = aps.audit_plan_session_id
JOIN standard_clauses sc ON sc.clause_id = apsc.clause_id
GROUP BY
    am.mission_code,
    sc.clause_code,
    sc.clause_title;

-- ============================================================
-- 18. REQUÊTES DE VÉRIFICATION À LANCER APRÈS LE SCRIPT
-- ============================================================

-- Vérifier les normes
-- SELECT * FROM standards;

-- Vérifier les clauses ISO chargées
-- SELECT clause_code, clause_title, clause_level FROM standard_clauses ORDER BY clause_code;

-- Vérifier les processus
-- SELECT process_code, process_name FROM processes ORDER BY process_name;

-- Vérifier le plan d'audit reconstitué
-- SELECT * FROM vw_audit_plan_schedule ORDER BY display_order;

-- Vérifier les clauses utilisées dans le plan
-- SELECT * FROM vw_clause_usage_in_plan ORDER BY clause_code;

-- ============================================================
-- FIN DU SCRIPT SQL V2
-- ============================================================

SELECT *
FROM auditprep.vw_audit_plan_schedule
ORDER BY display_order;
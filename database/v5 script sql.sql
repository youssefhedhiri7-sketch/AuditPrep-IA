-- ============================================================
-- PROJET : AuditPrep IA
-- SCRIPT : SQL V4 - Score de vigilance métier
-- OBJECTIF : Exploiter les constats d'audit pour calculer
--            des scores de vigilance par clause ISO et par processus.
--
-- IMPORTANT :
-- - Ce script s'exécute APRÈS le script SQL V3.
-- - Il ne supprime aucune donnée existante.
-- - Il ajoute une couche d'analyse métier utile au dashboard.
-- ============================================================

SET search_path TO auditprep;

-- ============================================================
-- 1. TABLE DE PARAMÉTRAGE DU SCORING
-- ============================================================

CREATE TABLE IF NOT EXISTS vigilance_scoring_rules (
    scoring_rule_id SERIAL PRIMARY KEY,
    rule_code VARCHAR(80) NOT NULL UNIQUE,
    rule_label VARCHAR(255) NOT NULL,
    rule_description TEXT,
    weight_value NUMERIC(8,2) NOT NULL CHECK (weight_value >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Règles initiales du scoring métier
INSERT INTO vigilance_scoring_rules (
    rule_code,
    rule_label,
    rule_description,
    weight_value,
    is_active
)
VALUES
    (
        'WEIGHT_NC',
        'Poids d’une non-conformité',
        'Chaque constat de type NC contribue fortement au score de vigilance.',
        30.00,
        TRUE
    ),
    (
        'WEIGHT_RQ',
        'Poids d’une remarque',
        'Chaque remarque contribue de manière intermédiaire au score de vigilance.',
        12.00,
        TRUE
    ),
    (
        'WEIGHT_AM',
        'Poids d’une amélioration',
        'Chaque amélioration contribue légèrement au score de vigilance.',
        8.00,
        TRUE
    ),
    (
        'BONUS_REPEAT_CLAUSE',
        'Bonus de répétition sur une même clause',
        'Lorsque plusieurs constats concernent une même clause ISO, un bonus est ajouté pour refléter une zone de fragilité récurrente.',
        10.00,
        TRUE
    ),
    (
        'BONUS_REPEAT_PROCESS',
        'Bonus de répétition sur un même processus',
        'Lorsque plusieurs constats concernent un même processus, un bonus est ajouté pour refléter une fragilité opérationnelle répétée.',
        10.00,
        TRUE
    ),
    (
        'WEIGHT_OPEN_CORRECTIVE_ACTION',
        'Poids d’une action corrective non finalisée',
        'Une action corrective envisagée ou planifiée mais non finalisée augmente le niveau de vigilance.',
        15.00,
        TRUE
    )
ON CONFLICT (rule_code) DO NOTHING;

-- ============================================================
-- 2. TABLE D'HISTORISATION DES SCORES DE VIGILANCE PAR CLAUSE
-- ============================================================

CREATE TABLE IF NOT EXISTS clause_vigilance_scores (
    clause_vigilance_score_id SERIAL PRIMARY KEY,
    mission_id INT NOT NULL REFERENCES audit_missions(mission_id) ON DELETE CASCADE,
    clause_id INT REFERENCES standard_clauses(clause_id) ON DELETE SET NULL,
    findings_count INT NOT NULL DEFAULT 0 CHECK (findings_count >= 0),
    nonconformities_count INT NOT NULL DEFAULT 0 CHECK (nonconformities_count >= 0),
    remarks_count INT NOT NULL DEFAULT 0 CHECK (remarks_count >= 0),
    improvements_count INT NOT NULL DEFAULT 0 CHECK (improvements_count >= 0),
    open_corrective_actions_count INT NOT NULL DEFAULT 0 CHECK (open_corrective_actions_count >= 0),
    raw_score NUMERIC(8,2) NOT NULL DEFAULT 0 CHECK (raw_score >= 0),
    capped_score NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (capped_score >= 0 AND capped_score <= 100),
    risk_level_id INT REFERENCES risk_levels(risk_level_id) ON DELETE SET NULL,
    explanation_summary TEXT,
    computed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_clause_vigilance_mission_clause UNIQUE (mission_id, clause_id)
);

CREATE INDEX IF NOT EXISTS idx_clause_vigilance_mission_id
    ON clause_vigilance_scores(mission_id);

CREATE INDEX IF NOT EXISTS idx_clause_vigilance_clause_id
    ON clause_vigilance_scores(clause_id);

CREATE INDEX IF NOT EXISTS idx_clause_vigilance_risk_level_id
    ON clause_vigilance_scores(risk_level_id);

-- ============================================================
-- 3. TABLE D'HISTORISATION DES SCORES DE VIGILANCE PAR PROCESSUS
-- ============================================================

CREATE TABLE IF NOT EXISTS process_vigilance_scores (
    process_vigilance_score_id SERIAL PRIMARY KEY,
    mission_id INT NOT NULL REFERENCES audit_missions(mission_id) ON DELETE CASCADE,
    process_id INT REFERENCES processes(process_id) ON DELETE SET NULL,
    findings_count INT NOT NULL DEFAULT 0 CHECK (findings_count >= 0),
    nonconformities_count INT NOT NULL DEFAULT 0 CHECK (nonconformities_count >= 0),
    remarks_count INT NOT NULL DEFAULT 0 CHECK (remarks_count >= 0),
    improvements_count INT NOT NULL DEFAULT 0 CHECK (improvements_count >= 0),
    open_corrective_actions_count INT NOT NULL DEFAULT 0 CHECK (open_corrective_actions_count >= 0),
    raw_score NUMERIC(8,2) NOT NULL DEFAULT 0 CHECK (raw_score >= 0),
    capped_score NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (capped_score >= 0 AND capped_score <= 100),
    risk_level_id INT REFERENCES risk_levels(risk_level_id) ON DELETE SET NULL,
    explanation_summary TEXT,
    computed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_process_vigilance_mission_process UNIQUE (mission_id, process_id)
);

CREATE INDEX IF NOT EXISTS idx_process_vigilance_mission_id
    ON process_vigilance_scores(mission_id);

CREATE INDEX IF NOT EXISTS idx_process_vigilance_process_id
    ON process_vigilance_scores(process_id);

CREATE INDEX IF NOT EXISTS idx_process_vigilance_risk_level_id
    ON process_vigilance_scores(risk_level_id);

-- ============================================================
-- 4. NETTOYAGE DES SCORES EXISTANTS POUR LA MISSION XYZ
--    Permet de relancer proprement le script V4.
-- ============================================================

DELETE FROM clause_vigilance_scores cvs
USING audit_missions am
WHERE cvs.mission_id = am.mission_id
  AND am.mission_code = 'AUD-XYZ-2026-INT';

DELETE FROM process_vigilance_scores pvs
USING audit_missions am
WHERE pvs.mission_id = am.mission_id
  AND am.mission_code = 'AUD-XYZ-2026-INT';

-- ============================================================
-- 5. CALCUL DU SCORE DE VIGILANCE PAR CLAUSE ISO
-- ============================================================

WITH active_rules AS (
    SELECT
        MAX(CASE WHEN rule_code = 'WEIGHT_NC' THEN weight_value END) AS weight_nc,
        MAX(CASE WHEN rule_code = 'WEIGHT_RQ' THEN weight_value END) AS weight_rq,
        MAX(CASE WHEN rule_code = 'WEIGHT_AM' THEN weight_value END) AS weight_am,
        MAX(CASE WHEN rule_code = 'BONUS_REPEAT_CLAUSE' THEN weight_value END) AS bonus_repeat_clause,
        MAX(CASE WHEN rule_code = 'WEIGHT_OPEN_CORRECTIVE_ACTION' THEN weight_value END) AS weight_open_action
    FROM vigilance_scoring_rules
    WHERE is_active = TRUE
),
clause_findings AS (
    SELECT
        am.mission_id,
        af.clause_id,
        COUNT(*) AS findings_count,
        COUNT(*) FILTER (WHERE ft.code = 'NC') AS nonconformities_count,
        COUNT(*) FILTER (WHERE ft.code = 'RQ') AS remarks_count,
        COUNT(*) FILTER (WHERE ft.code = 'AM') AS improvements_count
    FROM audit_findings af
    JOIN audit_reports ar ON ar.audit_report_id = af.audit_report_id
    JOIN audit_missions am ON am.mission_id = ar.mission_id
    JOIN finding_types ft ON ft.finding_type_id = af.finding_type_id
    WHERE am.mission_code = 'AUD-XYZ-2026-INT'
    GROUP BY am.mission_id, af.clause_id
),
clause_open_actions AS (
    SELECT
        am.mission_id,
        af.clause_id,
        COUNT(ca.corrective_action_id) FILTER (
            WHERE ca.action_status IN ('Envisagée', 'Planifiée')
        ) AS open_corrective_actions_count
    FROM audit_findings af
    JOIN audit_reports ar ON ar.audit_report_id = af.audit_report_id
    JOIN audit_missions am ON am.mission_id = ar.mission_id
    LEFT JOIN nonconformities nc ON nc.finding_id = af.finding_id
    LEFT JOIN corrective_actions ca ON ca.nonconformity_id = nc.nonconformity_id
    WHERE am.mission_code = 'AUD-XYZ-2026-INT'
    GROUP BY am.mission_id, af.clause_id
),
scoring_base AS (
    SELECT
        cf.mission_id,
        cf.clause_id,
        cf.findings_count,
        cf.nonconformities_count,
        cf.remarks_count,
        cf.improvements_count,
        COALESCE(coa.open_corrective_actions_count, 0) AS open_corrective_actions_count,
        ar.weight_nc,
        ar.weight_rq,
        ar.weight_am,
        ar.bonus_repeat_clause,
        ar.weight_open_action,
        (
            cf.nonconformities_count * ar.weight_nc
            + cf.remarks_count * ar.weight_rq
            + cf.improvements_count * ar.weight_am
            + CASE WHEN cf.findings_count >= 2 THEN ar.bonus_repeat_clause ELSE 0 END
            + COALESCE(coa.open_corrective_actions_count, 0) * ar.weight_open_action
        ) AS raw_score
    FROM clause_findings cf
    CROSS JOIN active_rules ar
    LEFT JOIN clause_open_actions coa
        ON coa.mission_id = cf.mission_id
       AND coa.clause_id IS NOT DISTINCT FROM cf.clause_id
)
INSERT INTO clause_vigilance_scores (
    mission_id,
    clause_id,
    findings_count,
    nonconformities_count,
    remarks_count,
    improvements_count,
    open_corrective_actions_count,
    raw_score,
    capped_score,
    risk_level_id,
    explanation_summary
)
SELECT
    sb.mission_id,
    sb.clause_id,
    sb.findings_count,
    sb.nonconformities_count,
    sb.remarks_count,
    sb.improvements_count,
    sb.open_corrective_actions_count,
    sb.raw_score,
    LEAST(sb.raw_score, 100.00) AS capped_score,
    rl.risk_level_id,
    CONCAT(
        'Score calculé à partir de ', sb.findings_count, ' constat(s) : ',
        sb.nonconformities_count, ' NC, ',
        sb.remarks_count, ' remarque(s), ',
        sb.improvements_count, ' amélioration(s), ',
        sb.open_corrective_actions_count, ' action(s) corrective(s) non finalisée(s).'
    ) AS explanation_summary
FROM scoring_base sb
LEFT JOIN risk_levels rl
    ON LEAST(sb.raw_score, 100.00) BETWEEN rl.min_score AND rl.max_score;

-- ============================================================
-- 6. CALCUL DU SCORE DE VIGILANCE PAR PROCESSUS
-- ============================================================

WITH active_rules AS (
    SELECT
        MAX(CASE WHEN rule_code = 'WEIGHT_NC' THEN weight_value END) AS weight_nc,
        MAX(CASE WHEN rule_code = 'WEIGHT_RQ' THEN weight_value END) AS weight_rq,
        MAX(CASE WHEN rule_code = 'WEIGHT_AM' THEN weight_value END) AS weight_am,
        MAX(CASE WHEN rule_code = 'BONUS_REPEAT_PROCESS' THEN weight_value END) AS bonus_repeat_process,
        MAX(CASE WHEN rule_code = 'WEIGHT_OPEN_CORRECTIVE_ACTION' THEN weight_value END) AS weight_open_action
    FROM vigilance_scoring_rules
    WHERE is_active = TRUE
),
process_findings AS (
    SELECT
        am.mission_id,
        af.process_id,
        COUNT(*) AS findings_count,
        COUNT(*) FILTER (WHERE ft.code = 'NC') AS nonconformities_count,
        COUNT(*) FILTER (WHERE ft.code = 'RQ') AS remarks_count,
        COUNT(*) FILTER (WHERE ft.code = 'AM') AS improvements_count
    FROM audit_findings af
    JOIN audit_reports ar ON ar.audit_report_id = af.audit_report_id
    JOIN audit_missions am ON am.mission_id = ar.mission_id
    JOIN finding_types ft ON ft.finding_type_id = af.finding_type_id
    WHERE am.mission_code = 'AUD-XYZ-2026-INT'
    GROUP BY am.mission_id, af.process_id
),
process_open_actions AS (
    SELECT
        am.mission_id,
        af.process_id,
        COUNT(ca.corrective_action_id) FILTER (
            WHERE ca.action_status IN ('Envisagée', 'Planifiée')
        ) AS open_corrective_actions_count
    FROM audit_findings af
    JOIN audit_reports ar ON ar.audit_report_id = af.audit_report_id
    JOIN audit_missions am ON am.mission_id = ar.mission_id
    LEFT JOIN nonconformities nc ON nc.finding_id = af.finding_id
    LEFT JOIN corrective_actions ca ON ca.nonconformity_id = nc.nonconformity_id
    WHERE am.mission_code = 'AUD-XYZ-2026-INT'
    GROUP BY am.mission_id, af.process_id
),
scoring_base AS (
    SELECT
        pf.mission_id,
        pf.process_id,
        pf.findings_count,
        pf.nonconformities_count,
        pf.remarks_count,
        pf.improvements_count,
        COALESCE(poa.open_corrective_actions_count, 0) AS open_corrective_actions_count,
        ar.weight_nc,
        ar.weight_rq,
        ar.weight_am,
        ar.bonus_repeat_process,
        ar.weight_open_action,
        (
            pf.nonconformities_count * ar.weight_nc
            + pf.remarks_count * ar.weight_rq
            + pf.improvements_count * ar.weight_am
            + CASE WHEN pf.findings_count >= 2 THEN ar.bonus_repeat_process ELSE 0 END
            + COALESCE(poa.open_corrective_actions_count, 0) * ar.weight_open_action
        ) AS raw_score
    FROM process_findings pf
    CROSS JOIN active_rules ar
    LEFT JOIN process_open_actions poa
        ON poa.mission_id = pf.mission_id
       AND poa.process_id IS NOT DISTINCT FROM pf.process_id
)
INSERT INTO process_vigilance_scores (
    mission_id,
    process_id,
    findings_count,
    nonconformities_count,
    remarks_count,
    improvements_count,
    open_corrective_actions_count,
    raw_score,
    capped_score,
    risk_level_id,
    explanation_summary
)
SELECT
    sb.mission_id,
    sb.process_id,
    sb.findings_count,
    sb.nonconformities_count,
    sb.remarks_count,
    sb.improvements_count,
    sb.open_corrective_actions_count,
    sb.raw_score,
    LEAST(sb.raw_score, 100.00) AS capped_score,
    rl.risk_level_id,
    CONCAT(
        'Score calculé à partir de ', sb.findings_count, ' constat(s) : ',
        sb.nonconformities_count, ' NC, ',
        sb.remarks_count, ' remarque(s), ',
        sb.improvements_count, ' amélioration(s), ',
        sb.open_corrective_actions_count, ' action(s) corrective(s) non finalisée(s).'
    ) AS explanation_summary
FROM scoring_base sb
LEFT JOIN risk_levels rl
    ON LEAST(sb.raw_score, 100.00) BETWEEN rl.min_score AND rl.max_score;

-- ============================================================
-- 7. VUE DASHBOARD : VIGILANCE PAR CLAUSE ISO
-- ============================================================

CREATE OR REPLACE VIEW vw_clause_vigilance_dashboard AS
SELECT
    am.mission_code,
    am.mission_title,
    COALESCE(sc.clause_code, 'Sans clause') AS clause_code,
    COALESCE(sc.clause_title, 'Aucune référence ISO enregistrée') AS clause_title,
    cvs.findings_count,
    cvs.nonconformities_count,
    cvs.remarks_count,
    cvs.improvements_count,
    cvs.open_corrective_actions_count,
    cvs.raw_score,
    cvs.capped_score,
    rl.label AS vigilance_level,
    cvs.explanation_summary,
    cvs.computed_at
FROM clause_vigilance_scores cvs
JOIN audit_missions am ON am.mission_id = cvs.mission_id
LEFT JOIN standard_clauses sc ON sc.clause_id = cvs.clause_id
LEFT JOIN risk_levels rl ON rl.risk_level_id = cvs.risk_level_id
WHERE am.mission_code = 'AUD-XYZ-2026-INT';

-- ============================================================
-- 8. VUE DASHBOARD : VIGILANCE PAR PROCESSUS
-- ============================================================

CREATE OR REPLACE VIEW vw_process_vigilance_dashboard AS
SELECT
    am.mission_code,
    am.mission_title,
    COALESCE(p.process_name, 'Processus non renseigné') AS process_name,
    pvs.findings_count,
    pvs.nonconformities_count,
    pvs.remarks_count,
    pvs.improvements_count,
    pvs.open_corrective_actions_count,
    pvs.raw_score,
    pvs.capped_score,
    rl.label AS vigilance_level,
    pvs.explanation_summary,
    pvs.computed_at
FROM process_vigilance_scores pvs
JOIN audit_missions am ON am.mission_id = pvs.mission_id
LEFT JOIN processes p ON p.process_id = pvs.process_id
LEFT JOIN risk_levels rl ON rl.risk_level_id = pvs.risk_level_id
WHERE am.mission_code = 'AUD-XYZ-2026-INT';

-- ============================================================
-- 9. VUE SYNTHÈSE : TOP DES ZONES À SURVEILLER
-- ============================================================

CREATE OR REPLACE VIEW vw_top_vigilance_alerts AS
SELECT
    'Clause ISO' AS alert_dimension,
    clause_code AS alert_key,
    clause_title AS alert_label,
    capped_score,
    vigilance_level,
    explanation_summary
FROM vw_clause_vigilance_dashboard

UNION ALL

SELECT
    'Processus' AS alert_dimension,
    process_name AS alert_key,
    process_name AS alert_label,
    capped_score,
    vigilance_level,
    explanation_summary
FROM vw_process_vigilance_dashboard;

-- ============================================================
-- 10. REQUÊTES DE VÉRIFICATION APRÈS EXÉCUTION
-- ============================================================

-- A. Voir la vigilance par clause ISO
-- SELECT *
-- FROM auditprep.vw_clause_vigilance_dashboard
-- ORDER BY capped_score DESC, clause_code;

-- B. Voir la vigilance par processus
-- SELECT *
-- FROM auditprep.vw_process_vigilance_dashboard
-- ORDER BY capped_score DESC, process_name;

-- C. Voir les alertes prioritaires mélangées clauses + processus
-- SELECT *
-- FROM auditprep.vw_top_vigilance_alerts
-- ORDER BY capped_score DESC, alert_dimension, alert_key;

-- ============================================================
-- FIN DU SCRIPT SQL V4
-- ============================================================
SELECT *
FROM auditprep.vw_clause_vigilance_dashboard
ORDER BY capped_score DESC, clause_code;

SELECT *
FROM auditprep.vw_process_vigilance_dashboard
ORDER BY capped_score DESC, process_name;

SELECT *
FROM auditprep.vw_top_vigilance_alerts
ORDER BY capped_score DESC, alert_dimension, alert_key;
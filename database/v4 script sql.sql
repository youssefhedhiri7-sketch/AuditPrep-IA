-- ============================================================
-- PROJET : AuditPrep IA
-- SCRIPT : SQL V3 - Alimentation métier réaliste
-- OBJECTIF :
--   1) Intégrer une check-list ISO 9001 dans le référentiel
--   2) Créer un exemple de rapport d'audit interne XYZ
--   3) Insérer les constats NC / RQ / AM issus du rapport
--   4) Structurer une fiche de non-conformité et ses actions correctives
--
-- IMPORTANT :
-- - Ce script s'exécute APRÈS le script V2.
-- - Il est conçu pour être relançable sans créer de doublons majeurs.
-- ============================================================

SET search_path TO auditprep;

-- ============================================================
-- 1. CONTRÔLES PRÉALABLES
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM standards
        WHERE standard_code = 'ISO 9001'
          AND standard_version = '2015'
    ) THEN
        RAISE EXCEPTION 'La norme ISO 9001:2015 n''existe pas. Exécuter d''abord le script SQL V2.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM finding_types WHERE code IN ('NC', 'RQ', 'AM')
    ) THEN
        RAISE EXCEPTION 'Les types de constats NC/RQ/AM ne sont pas disponibles. Exécuter d''abord le script SQL V2.';
    END IF;
END $$;

-- ============================================================
-- 2. AJOUT DE LA CLAUSE 5.4 COMME RÉFÉRENCE HISTORIQUE DU RAPPORT
--    Remarque : cette référence apparaît dans le rapport fourni.
--    Elle est enregistrée comme clause de référence documentaire,
--    sans modifier la structure normative principale ISO 9001:2015.
-- ============================================================

INSERT INTO standard_clauses (
    standard_id,
    clause_code,
    clause_title,
    clause_level,
    is_auditable
)
SELECT
    s.standard_id,
    '5.4',
    'Référence historique mentionnée dans un rapport d’audit transmis',
    2,
    TRUE
FROM standards s
WHERE s.standard_code = 'ISO 9001'
  AND s.standard_version = '2015'
ON CONFLICT (standard_id, clause_code) DO NOTHING;

-- ============================================================
-- 3. RÉFÉRENTIEL DE QUESTIONS DE CHECK-LIST ISO 9001
--    Reprise structurée du document checklist_audit_iso9001.pdf
-- ============================================================

-- Utilisation d'une priorité par défaut "Moyenne"

-- 3.1 Contexte de l'organisation
INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier la prise en compte des parties intéressées pertinentes.',
    'L’organisation a-t-elle identifié les parties intéressées ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Moyenne'
JOIN standard_clauses sc ON sc.clause_code = '4.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Maîtrise documentaire'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'L’organisation a-t-elle identifié les parties intéressées ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier la définition des enjeux internes et externes.',
    'Les enjeux internes et externes sont-ils définis ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Moyenne'
JOIN standard_clauses sc ON sc.clause_code = '4.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Maîtrise documentaire'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Les enjeux internes et externes sont-ils définis ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier la formalisation du domaine d’application du système de management de la qualité.',
    'Le périmètre du SMQ est-il documenté ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Moyenne'
JOIN standard_clauses sc ON sc.clause_code = '4.3'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Maîtrise documentaire'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Le périmètre du SMQ est-il documenté ?'
        AND cpr.clause_id = sc.clause_id
  );

-- 3.2 Leadership
INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier l’engagement de la direction dans le système de management de la qualité.',
    'La direction démontre-t-elle son engagement ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    p.process_id
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Haute'
JOIN standard_clauses sc ON sc.clause_code = '5.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
LEFT JOIN processes p ON p.process_name = 'Direction'
WHERE ct.theme_name = 'Maîtrise documentaire'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'La direction démontre-t-elle son engagement ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier que la politique qualité est définie et communiquée.',
    'La politique qualité est-elle définie et communiquée ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    p.process_id
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Haute'
JOIN standard_clauses sc ON sc.clause_code = '5.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
LEFT JOIN processes p ON p.process_name = 'Direction'
WHERE ct.theme_name = 'Maîtrise documentaire'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'La politique qualité est-elle définie et communiquée ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier l’attribution des responsabilités et autorités.',
    'Les responsabilités sont-elles attribuées ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    p.process_id
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Haute'
JOIN standard_clauses sc ON sc.clause_code = '5.3'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
LEFT JOIN processes p ON p.process_name = 'Direction'
WHERE ct.theme_name = 'Maîtrise documentaire'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Les responsabilités sont-elles attribuées ?'
        AND cpr.clause_id = sc.clause_id
  );

-- 3.3 Planification
INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier l’identification des risques et opportunités.',
    'Les risques et opportunités sont-ils identifiés ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Haute'
JOIN standard_clauses sc ON sc.clause_code = '6.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Maîtrise documentaire'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Les risques et opportunités sont-ils identifiés ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier l’existence d’objectifs qualité mesurables.',
    'Des objectifs qualité mesurables sont-ils établis ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Moyenne'
JOIN standard_clauses sc ON sc.clause_code = '6.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Maîtrise documentaire'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Des objectifs qualité mesurables sont-ils établis ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier la planification des actions nécessaires à l’atteinte des objectifs qualité.',
    'Les actions pour atteindre les objectifs sont-elles planifiées ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Moyenne'
JOIN standard_clauses sc ON sc.clause_code = '6.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Maîtrise documentaire'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Les actions pour atteindre les objectifs sont-elles planifiées ?'
        AND cpr.clause_id = sc.clause_id
  );

-- 3.4 Support
INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier la disponibilité des ressources nécessaires.',
    'Les ressources nécessaires sont-elles disponibles ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Moyenne'
JOIN standard_clauses sc ON sc.clause_code = '7.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Maîtrise documentaire'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Les ressources nécessaires sont-elles disponibles ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier les compétences nécessaires des personnels concernés.',
    'Le personnel est-il compétent ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    p.process_id
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Haute'
JOIN standard_clauses sc ON sc.clause_code = '7.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
LEFT JOIN processes p ON p.process_name = 'Gestion des Ressources Humaines'
WHERE ct.theme_name = 'Compétences et formation'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Le personnel est-il compétent ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier la maîtrise des informations documentées.',
    'La documentation est-elle maîtrisée ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Haute'
JOIN standard_clauses sc ON sc.clause_code = '7.5'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Maîtrise documentaire'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'La documentation est-elle maîtrisée ?'
        AND cpr.clause_id = sc.clause_id
  );

-- 3.5 Réalisation des activités opérationnelles
INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier la maîtrise des processus opérationnels.',
    'Les processus sont-ils maîtrisés ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Haute'
JOIN standard_clauses sc ON sc.clause_code = '8.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Gestion des enregistrements'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Les processus sont-ils maîtrisés ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier la prise en compte des exigences clients.',
    'Les exigences clients sont-elles respectées ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Moyenne'
JOIN standard_clauses sc ON sc.clause_code = '8.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Réclamations clients'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Les exigences clients sont-elles respectées ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier l’identification et la traçabilité lorsque cela est applicable.',
    'La traçabilité est-elle assurée ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Moyenne'
JOIN standard_clauses sc ON sc.clause_code = '8.5'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Gestion des enregistrements'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'La traçabilité est-elle assurée ?'
        AND cpr.clause_id = sc.clause_id
  );

-- 3.6 Évaluation des performances
INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier le suivi des indicateurs de performance.',
    'Les indicateurs sont-ils suivis ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Moyenne'
JOIN standard_clauses sc ON sc.clause_code = '9.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Gestion des enregistrements'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Les indicateurs sont-ils suivis ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier la réalisation des audits internes.',
    'Des audits internes sont-ils réalisés ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Moyenne'
JOIN standard_clauses sc ON sc.clause_code = '9.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Gestion des enregistrements'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Des audits internes sont-ils réalisés ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier la mesure de la satisfaction client.',
    'La satisfaction client est-elle mesurée ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Moyenne'
JOIN standard_clauses sc ON sc.clause_code = '9.1.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Réclamations clients'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'La satisfaction client est-elle mesurée ?'
        AND cpr.clause_id = sc.clause_id
  );

-- 3.7 Amélioration
INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier le traitement des non-conformités.',
    'Les non-conformités sont-elles traitées ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Haute'
JOIN standard_clauses sc ON sc.clause_code = '10.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Actions correctives'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Les non-conformités sont-elles traitées ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier la mise en œuvre des actions correctives.',
    'Des actions correctives sont-elles mises en œuvre ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Haute'
JOIN standard_clauses sc ON sc.clause_code = '10.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Actions correctives'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Des actions correctives sont-elles mises en œuvre ?'
        AND cpr.clause_id = sc.clause_id
  );

INSERT INTO control_points_repository (
    theme_id,
    audit_type_id,
    requirement_text,
    question_template,
    expected_evidence,
    default_priority_level_id,
    is_active,
    clause_id,
    process_id
)
SELECT
    ct.theme_id,
    at.audit_type_id,
    'Vérifier la présence d’une démarche d’amélioration continue.',
    'Une démarche d’amélioration continue est-elle en place ?',
    NULL,
    pl.priority_level_id,
    TRUE,
    sc.clause_id,
    NULL
FROM control_themes ct
JOIN audit_types at ON at.label = 'Audit interne'
JOIN priority_levels pl ON pl.label = 'Moyenne'
JOIN standard_clauses sc ON sc.clause_code = '10.3'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE ct.theme_name = 'Actions correctives'
  AND NOT EXISTS (
      SELECT 1
      FROM control_points_repository cpr
      WHERE cpr.question_template = 'Une démarche d’amélioration continue est-elle en place ?'
        AND cpr.clause_id = sc.clause_id
  );

-- ============================================================
-- 4. CRÉATION D'UNE CHECK-LIST GÉNÉRÉE POUR LA MISSION SECURE
-- ============================================================

INSERT INTO checklists (
    mission_id,
    checklist_title,
    checklist_status,
    generated_at
)
SELECT
    am.mission_id,
    'Check-list ISO 9001:2015 – base générique de préparation',
    'Brouillon',
    CURRENT_TIMESTAMP
FROM audit_missions am
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
  AND NOT EXISTS (
      SELECT 1
      FROM checklists c
      WHERE c.mission_id = am.mission_id
        AND c.checklist_title = 'Check-list ISO 9001:2015 – base générique de préparation'
  );

INSERT INTO checklist_items (
    checklist_id,
    theme,
    requirement_text,
    question_text,
    expected_evidence,
    priority_level_id,
    display_order,
    is_manually_modified,
    clause_id,
    conformity_status,
    finding_comment,
    examined_evidence
)
SELECT
    c.checklist_id,
    COALESCE(ct.theme_name, 'Référentiel ISO 9001'),
    cpr.requirement_text,
    cpr.question_template,
    cpr.expected_evidence,
    cpr.default_priority_level_id,
    ROW_NUMBER() OVER (ORDER BY sc.clause_code, cpr.repository_point_id),
    FALSE,
    cpr.clause_id,
    'Non évalué',
    NULL,
    NULL
FROM checklists c
JOIN audit_missions am ON am.mission_id = c.mission_id
JOIN control_points_repository cpr ON cpr.is_active = TRUE
LEFT JOIN control_themes ct ON ct.theme_id = cpr.theme_id
LEFT JOIN standard_clauses sc ON sc.clause_id = cpr.clause_id
WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
  AND c.checklist_title = 'Check-list ISO 9001:2015 – base générique de préparation'
  AND NOT EXISTS (
      SELECT 1
      FROM checklist_items ci
      WHERE ci.checklist_id = c.checklist_id
  );

-- ============================================================
-- 5. CLIENT ET MISSION D'AUDIT INTERNE XYZ
--    Basés sur le rapport transmis
-- ============================================================

INSERT INTO clients (client_name, sector, country)
VALUES ('XYZ', 'Industrie / fabrication', 'Tunisie')
ON CONFLICT (client_name) DO NOTHING;

INSERT INTO client_sites (
    client_id,
    site_name,
    address,
    city,
    country
)
SELECT
    c.client_id,
    'Sites audités XYZ',
    'Zone Industrielle Enfidha',
    'Sousse / Enfidha',
    'Tunisie'
FROM clients c
WHERE c.client_name = 'XYZ'
ON CONFLICT (client_id, site_name) DO NOTHING;

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
    'AUD-XYZ-2026-INT',
    'Audit interne QSE – XYZ – avril 2026',
    c.client_name,
    at.audit_type_id,
    DATE '2026-04-13',
    u.user_id,
    u.user_id,
    ms.mission_status_id,
    'Mission reconstituée à partir du rapport d’audit interne transmis. Le rapport mentionne ISO 9001, ISO 14001 et ISO 45001 ; la norme principale structurée ici reste ISO 9001:2015.',
    c.client_id,
    cs.site_id,
    s.standard_id
FROM clients c
JOIN client_sites cs ON cs.client_id = c.client_id AND cs.site_name = 'Sites audités XYZ'
JOIN audit_types at ON at.label = 'Audit interne'
JOIN mission_statuses ms ON ms.label = 'Archivé'
JOIN users u ON u.email = 'omar.pfe@auditprep.local'
JOIN standards s ON s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE c.client_name = 'XYZ'
ON CONFLICT (mission_code) DO NOTHING;

INSERT INTO audit_team_members (
    mission_id,
    person_name,
    role_in_audit
)
SELECT
    am.mission_id,
    'Imed BEN YEDDER',
    'Auditeur'
FROM audit_missions am
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
ON CONFLICT (mission_id, person_name, role_in_audit) DO NOTHING;

-- ============================================================
-- 6. PROCESSUS XYZ COMPLÉMENTAIRES
-- ============================================================

INSERT INTO processes (process_code, process_name, description)
VALUES
    ('MANUF-L', 'Manufacturing Leather', 'Processus de fabrication Leather.'),
    ('MANUF-S', 'Manufacturing Safety', 'Processus de fabrication Safety.'),
    ('MANUF-AIR', 'Manufacturing D’AIR', 'Processus de fabrication D’AIR.'),
    ('QSE', 'Management QSE', 'Management intégré qualité, sécurité et environnement.')
ON CONFLICT (process_name) DO NOTHING;

INSERT INTO mission_processes (mission_id, process_id, priority_level_id, comment)
SELECT
    am.mission_id,
    p.process_id,
    pl.priority_level_id,
    'Processus mentionné dans le rapport d’audit interne XYZ.'
FROM audit_missions am
CROSS JOIN processes p
JOIN priority_levels pl ON pl.label = 'Haute'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND p.process_name IN (
      'Direction',
      'Management QSE',
      'HSE',
      'Manufacturing Leather',
      'Logistique',
      'Gestion des Ressources Humaines',
      'Manufacturing Safety',
      'Manufacturing D’AIR',
      'Maintenance'
  )
ON CONFLICT (mission_id, process_id) DO NOTHING;

-- ============================================================
-- 7. RAPPORT D'AUDIT INTERNE XYZ
-- ============================================================

INSERT INTO audit_reports (
    mission_id,
    report_title,
    report_date,
    methodology_text,
    conclusion_text,
    recommendations_text
)
SELECT
    am.mission_id,
    'Rapport d’audit interne XYZ – ISO 9001 / 14001 / 45001',
    DATE '2026-04-14',
    'Audit réalisé par échantillonnage, entretiens, vérification des pratiques et examen des informations documentées disponibles.',
    'Le rapport conclut que les objectifs de l’audit ont été atteints et que le système audité est jugé conforme, capable et efficace, tout en identifiant plusieurs écarts et améliorations.',
    'Il est recommandé de remédier aux écarts soulevés dans le rapport d’audit.'
FROM audit_missions am
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1
      FROM audit_reports ar
      WHERE ar.mission_id = am.mission_id
  );

-- ============================================================
-- 8. CONSTATS DU RAPPORT XYZ
-- ============================================================

-- 8.1 NC - Gestion des produits chimiques - clause 8.1
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'Des exigences relatives à la gestion des produits chimiques ne sont pas appliquées de manière systématique ; des fiches de données de sécurité sont absentes pour certains produits.',
    'Ouvert'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'HSE'
JOIN finding_types ft ON ft.code = 'NC'
JOIN standard_clauses sc ON sc.clause_code = '8.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'Des exigences relatives à la gestion des produits chimiques%'
  );

-- 8.2 AM - Analyse des risques HSE
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    NULL,
    'L’analyse des risques HSE de certains postes de travail devrait être approfondie afin d’assurer une identification plus exhaustive des dangers.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'HSE'
JOIN finding_types ft ON ft.code = 'AM'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'L’analyse des risques HSE%'
  );

-- 8.3 RQ - Luminosité de certains postes - 6.1
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'Le niveau de luminosité de certains postes de travail nécessite une réévaluation afin de garantir des conditions opérationnelles appropriées.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'HSE'
JOIN finding_types ft ON ft.code = 'RQ'
JOIN standard_clauses sc ON sc.clause_code = '6.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'Le niveau de luminosité%'
  );

-- 8.4 RQ - Communication avec prestataires externes - 7.4
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'La communication relative aux aspects environnementaux significatifs et aux risques SST vers les prestataires externes n’est pas systématique.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'HSE'
JOIN finding_types ft ON ft.code = 'RQ'
JOIN standard_clauses sc ON sc.clause_code = '7.4'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'La communication relative aux aspects environnementaux%'
  );

-- 8.5 RQ - Formation / sensibilisation HSE - 7.2
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'Les actions de formation et de sensibilisation HSE ne couvrent pas suffisamment tous les domaines pertinents.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'Gestion des Ressources Humaines'
JOIN finding_types ft ON ft.code = 'RQ'
JOIN standard_clauses sc ON sc.clause_code = '7.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'Les actions de formation et de sensibilisation HSE%'
  );

-- 8.6 AM - Risques et opportunités - 6.1
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'L’identification et l’évaluation des risques et opportunités devraient être davantage développées et systématisées.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'Management QSE'
JOIN finding_types ft ON ft.code = 'AM'
JOIN standard_clauses sc ON sc.clause_code = '6.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'L’identification et l’évaluation des risques et opportunités%'
  );

-- 8.7 AM - Indicateurs qualité - 9.1
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'Les indicateurs qualité ne sont pas intégrés de manière systématique dans l’outil de pilotage utilisé.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'Management QSE'
JOIN finding_types ft ON ft.code = 'AM'
JOIN standard_clauses sc ON sc.clause_code = '9.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'Les indicateurs qualité ne sont pas intégrés%'
  );

-- 8.8 NC - Preuves de contrôles en production - 8.1
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'Les preuves des contrôles en cours de production ne sont pas systématiquement conservées conformément aux dispositions planifiées.',
    'Ouvert'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'Manufacturing Leather'
JOIN finding_types ft ON ft.code = 'NC'
JOIN standard_clauses sc ON sc.clause_code = '8.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'Les preuves des contrôles en cours de production%'
  );

-- 8.9 RQ - Kits LOTO - 7.1
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'La mise à disposition des kits de consignation et déconsignation pour les maintenanciers n’est pas systématiquement assurée.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'Maintenance'
JOIN finding_types ft ON ft.code = 'RQ'
JOIN standard_clauses sc ON sc.clause_code = '7.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'La mise à disposition des kits de consignation%'
  );

-- 8.10 RQ - Stockage de l’alcool - 8.1
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'Les conditions de stockage de l’alcool ne respectent pas systématiquement les exigences de rétention.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'HSE'
JOIN finding_types ft ON ft.code = 'RQ'
JOIN standard_clauses sc ON sc.clause_code = '8.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'Les conditions de stockage de l’alcool%'
  );

-- 8.11 RQ - Plans d’évacuation - 8.2
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'Les plans d’évacuation de sécurité incendie ne sont pas systématiquement mis à jour.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'HSE'
JOIN finding_types ft ON ft.code = 'RQ'
JOIN standard_clauses sc ON sc.clause_code = '8.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'Les plans d’évacuation de sécurité incendie%'
  );

-- 8.12 NC - Actions correctives issues des contrôles réglementaires - 10.2
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'Les actions correctives ou préventives issues de contrôles périodiques réglementaires ne sont pas systématiquement planifiées et suivies.',
    'Ouvert'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'Management QSE'
JOIN finding_types ft ON ft.code = 'NC'
JOIN standard_clauses sc ON sc.clause_code = '10.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'Les actions correctives ou préventives issues de contrôles périodiques%'
  );

-- 8.13 RQ - Contrôle réglementaire du chariot - 9.1
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'Le contrôle réglementaire d’un chariot élévateur n’est pas systématiquement assuré.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'Maintenance'
JOIN finding_types ft ON ft.code = 'RQ'
JOIN standard_clauses sc ON sc.clause_code = '9.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'Le contrôle réglementaire d’un chariot élévateur%'
  );

-- 8.14 RQ - Certificats d’aptitude - 7.2
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'Les certificats d’aptitude ne sont pas systématiquement disponibles.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'Gestion des Ressources Humaines'
JOIN finding_types ft ON ft.code = 'RQ'
JOIN standard_clauses sc ON sc.clause_code = '7.2'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'Les certificats d’aptitude%'
  );

-- 8.15 RQ - Rapports d’étalonnage - 7.1
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'Les rapports d’étalonnage de certains équipements de mesure ne sont pas systématiquement disponibles.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'Maintenance'
JOIN finding_types ft ON ft.code = 'RQ'
JOIN standard_clauses sc ON sc.clause_code = '7.1'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'Les rapports d’étalonnage de certains équipements%'
  );

-- 8.16 AM - Satisfaction des employés - 5.4
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'Les actions issues de l’enquête de satisfaction des employés ne sont pas systématiquement engagées.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'Gestion des Ressources Humaines'
JOIN finding_types ft ON ft.code = 'AM'
JOIN standard_clauses sc ON sc.clause_code = '5.4'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'Les actions issues de l’enquête de satisfaction des employés%'
  );

-- 8.17 RQ - Liste équipe sécurité - 5.3
INSERT INTO audit_findings (
    audit_report_id,
    process_id,
    finding_type_id,
    clause_id,
    finding_description,
    finding_status
)
SELECT
    ar.audit_report_id,
    p.process_id,
    ft.finding_type_id,
    sc.clause_id,
    'La liste de l’équipe sécurité n’est pas systématiquement mise à jour.',
    'À suivre'
FROM audit_reports ar
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN processes p ON p.process_name = 'HSE'
JOIN finding_types ft ON ft.code = 'RQ'
JOIN standard_clauses sc ON sc.clause_code = '5.3'
JOIN standards s ON s.standard_id = sc.standard_id AND s.standard_code = 'ISO 9001' AND s.standard_version = '2015'
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND NOT EXISTS (
      SELECT 1 FROM audit_findings af
      WHERE af.audit_report_id = ar.audit_report_id
        AND af.finding_description LIKE 'La liste de l’équipe sécurité%'
  );

-- ============================================================
-- 9. TRANSFORMATION DES NC DU RAPPORT XYZ EN NON-CONFORMITÉS FORMELLES
-- ============================================================

INSERT INTO nonconformities (
    finding_id,
    source_label,
    description,
    cause_analysis,
    detected_date,
    severity_level
)
SELECT
    af.finding_id,
    'Rapport d’audit interne XYZ',
    af.finding_description,
    NULL,
    DATE '2026-04-14',
    'À qualifier'
FROM audit_findings af
JOIN audit_reports ar ON ar.audit_report_id = af.audit_report_id
JOIN audit_missions am ON am.mission_id = ar.mission_id
JOIN finding_types ft ON ft.finding_type_id = af.finding_type_id
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
  AND ft.code = 'NC'
  AND NOT EXISTS (
      SELECT 1
      FROM nonconformities nc
      WHERE nc.finding_id = af.finding_id
  );

-- ============================================================
-- 10. FICHE DE NON-CONFORMITÉ ET ACTION CORRECTIVE FOURNIE
--     Enregistrement autonome, non rattaché à un rapport XYZ.
-- ============================================================

INSERT INTO nonconformities (
    finding_id,
    source_label,
    description,
    cause_analysis,
    detected_date,
    severity_level
)
SELECT
    NULL,
    'Audit de certification',
    'La recherche et l’analyse des causes, ainsi que les actions correctives de certaines réclamations clients, ne sont pas réalisées conformément à la procédure PR18.',
    'L’application utilisée pour le processus assurance de personnes ne permet pas de faire ressortir les réclamations des lots de feedback clients.',
    DATE '2024-04-16',
    'À qualifier'
WHERE NOT EXISTS (
    SELECT 1
    FROM nonconformities nc
    WHERE nc.source_label = 'Audit de certification'
      AND nc.description LIKE 'La recherche et l’analyse des causes%'
);

-- 10.1 Correction immédiate issue de la fiche
INSERT INTO corrective_actions (
    nonconformity_id,
    action_type,
    action_description,
    responsible_name,
    planned_due_date,
    actual_completion_date,
    action_status
)
SELECT
    nc.nonconformity_id,
    'Correction immédiate',
    'Trier les feedbacks clients pour identifier les réclamations et les traiter conformément à la procédure PR18.',
    'Équipe Assurance de personnes',
    DATE '2024-05-03',
    NULL,
    'Planifiée'
FROM nonconformities nc
WHERE nc.source_label = 'Audit de certification'
  AND nc.description LIKE 'La recherche et l’analyse des causes%'
  AND NOT EXISTS (
      SELECT 1
      FROM corrective_actions ca
      WHERE ca.nonconformity_id = nc.nonconformity_id
        AND ca.action_type = 'Correction immédiate'
        AND ca.action_description LIKE 'Trier les feedbacks clients%'
  );

-- 10.2 Action corrective structurelle issue de la fiche
INSERT INTO corrective_actions (
    nonconformity_id,
    action_type,
    action_description,
    responsible_name,
    planned_due_date,
    actual_completion_date,
    action_status
)
SELECT
    nc.nonconformity_id,
    'Action corrective',
    'Préparer un cahier des charges de mise à jour de l’application, mettre à jour l’application et communiquer aux clients la nouvelle modalité de traitement.',
    'Noureddine Msahli',
    DATE '2024-05-03',
    NULL,
    'Envisagée'
FROM nonconformities nc
WHERE nc.source_label = 'Audit de certification'
  AND nc.description LIKE 'La recherche et l’analyse des causes%'
  AND NOT EXISTS (
      SELECT 1
      FROM corrective_actions ca
      WHERE ca.nonconformity_id = nc.nonconformity_id
        AND ca.action_type = 'Action corrective'
        AND ca.action_description LIKE 'Préparer un cahier des charges%'
  );

-- ============================================================
-- 11. VUES MÉTIER POUR LA DÉMONSTRATION
-- ============================================================

CREATE OR REPLACE VIEW vw_checklist_repository_iso9001 AS
SELECT
    cpr.repository_point_id,
    sc.clause_code,
    sc.clause_title,
    ct.theme_name,
    cpr.question_template,
    pl.label AS priority_level
FROM control_points_repository cpr
LEFT JOIN standard_clauses sc ON sc.clause_id = cpr.clause_id
LEFT JOIN control_themes ct ON ct.theme_id = cpr.theme_id
LEFT JOIN priority_levels pl ON pl.priority_level_id = cpr.default_priority_level_id
JOIN audit_types at ON at.audit_type_id = cpr.audit_type_id
WHERE at.label = 'Audit interne'
  AND sc.standard_id = (
      SELECT standard_id
      FROM standards
      WHERE standard_code = 'ISO 9001'
        AND standard_version = '2015'
      LIMIT 1
  );

CREATE OR REPLACE VIEW vw_xyz_findings_summary AS
SELECT
    am.mission_code,
    am.mission_title,
    ft.code AS finding_code,
    ft.label AS finding_type,
    p.process_name,
    sc.clause_code,
    af.finding_description,
    af.finding_status
FROM audit_findings af
JOIN audit_reports ar ON ar.audit_report_id = af.audit_report_id
JOIN audit_missions am ON am.mission_id = ar.mission_id
JOIN finding_types ft ON ft.finding_type_id = af.finding_type_id
LEFT JOIN processes p ON p.process_id = af.process_id
LEFT JOIN standard_clauses sc ON sc.clause_id = af.clause_id
WHERE am.mission_code = 'AUD-XYZ-2026-INT';

CREATE OR REPLACE VIEW vw_nonconformities_corrective_actions AS
SELECT
    nc.nonconformity_id,
    nc.source_label,
    nc.description AS nonconformity_description,
    nc.cause_analysis,
    ca.corrective_action_id,
    ca.action_type,
    ca.action_description,
    ca.responsible_name,
    ca.planned_due_date,
    ca.actual_completion_date,
    ca.action_status
FROM nonconformities nc
LEFT JOIN corrective_actions ca ON ca.nonconformity_id = nc.nonconformity_id;

CREATE OR REPLACE VIEW vw_findings_kpi_by_type AS
SELECT
    ft.code,
    ft.label,
    COUNT(*) AS findings_count
FROM audit_findings af
JOIN finding_types ft ON ft.finding_type_id = af.finding_type_id
JOIN audit_reports ar ON ar.audit_report_id = af.audit_report_id
JOIN audit_missions am ON am.mission_id = ar.mission_id
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
GROUP BY ft.code, ft.label
ORDER BY findings_count DESC;

CREATE OR REPLACE VIEW vw_findings_kpi_by_clause AS
SELECT
    COALESCE(sc.clause_code, 'Sans clause') AS clause_code,
    COALESCE(sc.clause_title, 'Aucune référence ISO enregistrée') AS clause_title,
    COUNT(*) AS findings_count
FROM audit_findings af
JOIN audit_reports ar ON ar.audit_report_id = af.audit_report_id
JOIN audit_missions am ON am.mission_id = ar.mission_id
LEFT JOIN standard_clauses sc ON sc.clause_id = af.clause_id
WHERE am.mission_code = 'AUD-XYZ-2026-INT'
GROUP BY sc.clause_code, sc.clause_title
ORDER BY findings_count DESC, clause_code;

-- ============================================================
-- 12. REQUÊTES DE VÉRIFICATION À EXÉCUTER APRÈS LE SCRIPT
-- ============================================================

-- A. Vérifier le référentiel de check-list intégré
-- SELECT *
-- FROM auditprep.vw_checklist_repository_iso9001
-- ORDER BY clause_code, repository_point_id;

-- B. Vérifier la check-list générée pour SECURE
-- SELECT
--     c.checklist_title,
--     ci.display_order,
--     sc.clause_code,
--     ci.question_text,
--     ci.conformity_status
-- FROM auditprep.checklists c
-- JOIN auditprep.audit_missions am ON am.mission_id = c.mission_id
-- JOIN auditprep.checklist_items ci ON ci.checklist_id = c.checklist_id
-- LEFT JOIN auditprep.standard_clauses sc ON sc.clause_id = ci.clause_id
-- WHERE am.mission_code = 'AUD-SECURE-2026-RENOUV'
-- ORDER BY ci.display_order;

-- C. Vérifier les constats du rapport XYZ
-- SELECT *
-- FROM auditprep.vw_xyz_findings_summary
-- ORDER BY finding_code, clause_code;

-- D. Compter les constats NC / RQ / AM
-- SELECT *
-- FROM auditprep.vw_findings_kpi_by_type;

-- E. Voir les clauses ISO générant le plus de constats
-- SELECT *
-- FROM auditprep.vw_findings_kpi_by_clause;

-- F. Vérifier la fiche de non-conformité et ses actions
-- SELECT *
-- FROM auditprep.vw_nonconformities_corrective_actions
-- WHERE source_label = 'Audit de certification';

-- ============================================================
-- FIN DU SCRIPT SQL V3
-- ============================================================
SELECT *
FROM auditprep.vw_findings_kpi_by_type;
SELECT *
FROM auditprep.vw_findings_kpi_by_clause;


SELECT *
FROM auditprep.vw_nonconformities_corrective_actions
WHERE source_label = 'Audit de certification';
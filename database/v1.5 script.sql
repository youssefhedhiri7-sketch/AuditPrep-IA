SET search_path TO auditprep;

SELECT
    mission_code,
    mission_title,
    client_name,
    planned_audit_date
FROM audit_missions;

SELECT
    am.mission_code,
    pa.historical_nonconformities_count,
    pa.open_corrective_actions_count,
    pa.complaints_count,
    pa.missing_documents_count,
    rs.score_value,
    rl.label AS risk_level
FROM audit_missions am
JOIN preparation_analysis pa ON pa.mission_id = am.mission_id
JOIN risk_scores rs ON rs.mission_id = am.mission_id
JOIN risk_levels rl ON rl.risk_level_id = rs.risk_level_id;
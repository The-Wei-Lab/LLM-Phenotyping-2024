SELECT DISTINCT p.person_id
FROM person AS p
LEFT JOIN condition_occurrence AS co ON p.person_id = co.person_id
LEFT JOIN observation AS obs ON p.person_id = obs.person_id
LEFT JOIN drug_exposure AS de ON p.person_id = de.person_id
LEFT JOIN measurement AS m ON p.person_id = m.person_id
WHERE 
    -- Diagnosis
    co.condition_concept_id IN (SELECT concept_id FROM concept WHERE concept_code IN ('244.0', '244.1', '244.2', '244.3', '244.8', '244.9', 'E03.8', 'E03.9', 'E02', 'E89.0'))
    OR
    (
        -- Symptoms
        obs.observation_concept_id IN (SELECT concept_id FROM concept WHERE concept_name IN ('Fatigue', 'Weight gain', 'Cold intolerance', 'Dry skin', 'Bradycardia', 'Hair loss'))
        AND
        -- Laboratory findings
        (
            (m.measurement_concept_id = (SELECT concept_id FROM concept WHERE concept_name = 'Serum TSH') AND m.value_as_number > m.range_high)
            OR 
            (m.measurement_concept_id = (SELECT concept_id FROM concept WHERE concept_name = 'Serum Free T4') AND m.value_as_number < m.range_low)
        )
    )
    OR
    (
        -- Medications for hypothyroidism treatment and those causing hypothyroidism
        de.drug_concept_id IN (SELECT concept_id FROM concept WHERE concept_name IN ('Levothyroxine', 'Synthroid', 'Levoxyl', 'Euthyrox', 'Eltroxin', 'Liothyronine', 'Cytomel', 'Desiccated thyroid', 'Armour Thyroid', 'Nature-Throid', 'WP Thyroid', 'lithium', 'amiodarone', 'Lithobid', 'Cordarone', 'Nexterone', 'Pacerone'))
    )
AND
    -- Exclusion criteria
    NOT EXISTS 
    (
        SELECT 1 FROM procedure_occurrence AS po WHERE p.person_id = po.person_id AND po.procedure_concept_id IN (SELECT concept_id FROM concept WHERE concept_name IN ('Thyroid surgery', 'Radioactive Iodine treatment'))
    );

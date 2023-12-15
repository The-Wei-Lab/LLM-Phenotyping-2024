SELECT DISTINCT person_id 
FROM condition_occurrence AS co
JOIN concept AS c ON co.condition_concept_id = c.concept_id
LEFT JOIN measurement AS m ON co.person_id = m.person_id
LEFT JOIN drug_exposure AS de ON co.person_id = de.person_id
WHERE 
(
    -- Diagnosis of Type 2 Diabetes
    c.concept_code IN ('250.x0', '250.x2', 'E11.x') AND c.vocabulary_id IN ('ICD9CM', 'ICD10CM')
    AND 
    (
        -- Lab Tests
        (m.measurement_concept_id = (SELECT concept_id FROM concept WHERE concept_name = 'Fasting blood sugar') AND m.value_as_number > 126)
        OR
        (m.measurement_concept_id = (SELECT concept_id FROM concept WHERE concept_name = 'Hemoglobin A1c') AND m.value_as_number > 6.5)
        OR
        -- Medications
        (
            de.drug_concept_id IN 
            (
                SELECT concept_id FROM concept 
                WHERE concept_name IN ('Metformin', 'Glipizide', 'Glucophage', 'Glucotrol')
            )
        )
    )
)
AND NOT 
(
    -- Excluding Diagnosis of Type 1 Diabetes
    c.concept_code IN ('250.x1', '250.x3', 'E10.x') AND c.vocabulary_id IN ('ICD9CM', 'ICD10CM')
);

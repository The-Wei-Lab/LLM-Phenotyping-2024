SELECT DISTINCT p.person_id
FROM person AS p
WHERE (
    -- Diagnosis Criteria
    (p.person_id IN (
        SELECT DISTINCT dx.person_id
        FROM condition_occurrence AS dx
        WHERE dx.condition_concept_id IN (
            SELECT concept_id
            FROM concept
            WHERE (
                -- Dementia ICD9CM codes
                (vocabulary_id = 'ICD9CM' AND concept_code IN (
                    '290.0', '290.10', '290.11', '290.12', '290.13',
                    '290.20', '290.21', '290.3', '290.40', '290.41',
                    '294.0', '294.1', '331.0'
                )) OR
                -- Dementia ICD10CM codes
                (vocabulary_id = 'ICD10CM' AND concept_code IN (
                    'F00', 'F01', 'F02', 'F03', 'F04',
                    'G30', 'G31', 'G32', 'G33', 'G35', 'G36', 'G37'
                ))
            )
        )
    )) OR

    -- Symptoms Criteria
    (p.person_id IN (
        SELECT DISTINCT sx.person_id
        FROM condition_occurrence AS sx
        JOIN concept AS sym ON sx.condition_concept_id = sym.concept_id
        WHERE sym.concept_name IN ('Memory Loss', 'Cognitive Impairment')
    )) OR

    -- Laboratory Tests Criteria
    (p.person_id IN (
        SELECT DISTINCT lr.person_id
        FROM measurement AS lr
        WHERE (
            lr.measurement_concept_id IN (
                SELECT concept_id
                FROM concept
                WHERE concept_name IN ('Abnormal Cognitive Function Test Results', 'Positive Biomarker Result')
            )
            AND lr.value_as_number = 1 -- Assuming '1' indicates abnormal or positive results
        )
    )) OR

    -- Medication Criteria
    (p.person_id IN (
        SELECT DISTINCT med.person_id
        FROM drug_exposure AS med
        WHERE (
            -- Dementia Medication (Generic and Brand) Names
            (med.drug_concept_id IN (
                SELECT concept_id
                FROM concept
                WHERE concept_name IN ('Dementia Medication Generic Name', 'Dementia Medication Brand Name')
            ))
        )
    )) OR

    -- Procedures Criteria
    (p.person_id IN (
        SELECT DISTINCT proc.person_id
        FROM procedure_occurrence AS proc
        WHERE (
            proc.procedure_concept_id IN (
                SELECT concept_id
                FROM concept
                WHERE concept_name = 'Neuropsychological Testing'
            )
        )
    ))
);

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
                (vocabulary_id = 'ICD9CM' AND concept_code LIKE '290%') OR
                -- Dementia ICD10CM codes
                (vocabulary_id = 'ICD10CM' AND concept_code IN ('F00', 'F01'))
            )
        )
    )) OR

    -- Symptoms Criteria
    (p.person_id IN (
        SELECT DISTINCT sx.person_id
        FROM condition_occurrence AS sx
        JOIN concept AS sym ON sx.condition_concept_id = sym.concept_id
        WHERE sym.concept_name IN ('Memory Loss', 'Cognitive Impairment', 'Disorientation', 'Language problems', 'Behavioral changes')
    )) OR

    -- Procedures Criteria
    (p.person_id IN (
        SELECT DISTINCT proc.person_id
        FROM procedure_occurrence AS proc
        WHERE (
            proc.procedure_concept_id IN (
                SELECT concept_id
                FROM concept
                WHERE concept_name IN ('Neuropsychological Testing', 'MRI scan', 'CT scan')
            )
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
                WHERE concept_name IN ('Donepezil', 'Memantine', 'Aricept', 'Namenda')
            ))
        )
    ))
);

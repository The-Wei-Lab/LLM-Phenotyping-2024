SELECT DISTINCT p.person_id
FROM person p
JOIN condition_occurrence co ON p.person_id = co.person_id
LEFT JOIN drug_exposure de ON p.person_id = de.person_id
LEFT JOIN procedure_occurrence po ON p.person_id = po.procedure_concept_id
LEFT JOIN observation o ON p.person_id = o.person_id
WHERE 
    -- Diagnosis Codes for Dementia
    (co.condition_concept_id IN (
        -- ICD9CM and ICD10CM codes for dementia diagnosis
        'ICD9CM:290', 
        'ICD9CM:294.1', 
        'ICD9CM:331.0', 
        'ICD10CM:G30', 
        'ICD10CM:F00', 
        'ICD10CM:F03'
    ) OR 
    -- Symptoms and Signs of Dementia
    o.observation_concept_id IN (
        'OMOP:memory_loss', 
        'OMOP:impaired_reasoning', 
        'OMOP:impaired_communication'
    ) OR 
    -- Cognitive Assessment Tests or Procedures
    po.procedure_concept_id IN (
        'OMOP:MMSE', 
        'OMOP:MoCA', 
        'OMOP:neuropsychological_testing'
    )) AND 
    -- Exclusionary Laboratory Tests
    NOT EXISTS (
        SELECT 1 
        FROM measurement m
        WHERE p.person_id = m.person_id AND m.measurement_concept_id IN (
            'OMOP:thyroid_function_test', 
            'OMOP:B12_level', 
            'OMOP:syphilis_test'
        )
    ) AND
    -- Medications, both generic and brand names
    de.drug_concept_id IN (
        'OMOP:donepezil', 
        'OMOP:Aricept', 
        'OMOP:memantine', 
        'OMOP:Namenda'
    );

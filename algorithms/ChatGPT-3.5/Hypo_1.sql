SELECT DISTINCT person_id
FROM condition_occurrence c
JOIN person p ON p.person_id = c.person_id
JOIN drug_exposure d ON d.person_id = c.person_id
JOIN concept con_diag ON c.condition_concept_id = con_diag.concept_id
JOIN concept con_med ON d.drug_concept_id = con_med.concept_id
WHERE (
    -- Diagnosis Criteria (ICD-9-CM and ICD-10-CM codes)
    (con_diag.vocabulary_id IN ('ICD9CM', 'ICD10CM') AND
    (con_diag.concept_code IN ('244.9', 'E03.9', 'E03.8'))) AND
    
    -- Symptom Criteria (Using OMOP concept names)
    (c.condition_concept_id IN (
        SELECT concept_id FROM concept
        WHERE concept_name IN (
            'Fatigue',
            'Cold intolerance',
            'Weight gain',
            'Dry skin',
            'Constipation',
            'Bradycardia'
        )
    )) AND
    
    -- Laboratory Test Criteria (Assuming lab results are in measurement table)
    ((SELECT COUNT(*) FROM measurement m
      WHERE m.person_id = c.person_id
      AND m.measurement_concept_id IN (
          SELECT concept_id FROM concept
          WHERE concept_name = 'Thyroid-stimulating hormone (TSH)'
      )
      AND m.value_as_number > 4.5) > 0 OR
    
     (SELECT COUNT(*) FROM measurement m
      WHERE m.person_id = c.person_id
      AND m.measurement_concept_id IN (
          SELECT concept_id FROM concept
          WHERE concept_name = 'Free thyroxine (T4)'
      )
      AND m.value_as_number < lower_reference_range) > 0) AND
    
    -- Medication Criteria (Generic and brand names)
    (con_med.vocabulary_id IN ('RxNorm', 'Multum')
    AND con_med.concept_name IN ('Levothyroxine', 'Synthroid'))
);

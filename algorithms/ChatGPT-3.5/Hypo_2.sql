SELECT DISTINCT c.person_id
FROM condition_occurrence c
WHERE (
  -- Diagnosis criteria (ICD-9-CM and ICD-10-CM codes)
  c.condition_concept_id IN (
    SELECT concept_id
    FROM concept
    WHERE (
      (vocabulary_id IN ('ICD9CM', 'ICD10CM') AND
      concept_code IN ('244.9', 'E03.9', 'E03.8', 'E03.2', 'E03.1', 'E03.0', 'E03.5', 'E03.3', 'E03.89', 'E03.89', 'E03.9', 'E03.8'))
    )
  )
  OR
  -- Symptom criteria (Using OMOP concept names)
  c.condition_concept_id IN (
    SELECT concept_id
    FROM concept
    WHERE concept_name IN (
      'Fatigue', 'Cold intolerance', 'Weight gain', 'Dry skin', 'Constipation', 'Bradycardia'
    )
  )
  OR
  -- Laboratory test criteria (Assuming lab results are in measurement table)
  EXISTS (
    SELECT 1
    FROM measurement m
    WHERE m.person_id = c.person_id
    AND m.measurement_concept_id IN (
      SELECT concept_id
      FROM concept
      WHERE concept_name = 'Thyroid-stimulating hormone (TSH)'
    )
    AND m.value_as_number > 4.5
  )
  OR
  -- Medication criteria (Generic and brand names)
  EXISTS (
    SELECT 1
    FROM drug_exposure d
    WHERE d.person_id = c.person_id
    AND d.drug_concept_id IN (
      SELECT concept_id
      FROM concept
      WHERE (
        (vocabulary_id IN ('RxNorm', 'Multum') AND
        concept_name IN ('Levothyroxine', 'Synthroid'))
      )
    )
  )
);

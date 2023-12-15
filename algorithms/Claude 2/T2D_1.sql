SELECT distinct person_id  
FROM `Condition_occurrence` co
JOIN `Drug_exposure` de ON co.person_id = de.person_id
JOIN `Measurement` m ON co.person_id = m.person_id
WHERE 
  (
    co.condition_concept_id IN ('ICD9CM:250.x0','ICD9CM:250.x2')
    OR co.condition_concept_id IN ('ICD10CM:E11') 
  )
  AND 
  (
    de.drug_concept_id IN 
    (
      SELECT concept_id 
      FROM `Concept` 
      WHERE concept_name IN ('metformin','glipizide','rosiglitazone','sitagliptin',
      'exenatide','canagliflozin','insulin lispro','insulin glargine')
    )
    OR 
    de.drug_source_concept_id IN
    (
      SELECT concept_id  
      FROM `Concept`
      WHERE concept_name IN ('Glucophage','Amaryl','Avandia','Januvia',
      'Byetta','Invokana','Humalog','Lantus')
    )
  )
  OR
  (
    m.measurement_concept_id = '3023540' AND m.value_as_number >= 126
    AND m.measurement_type_concept_id = '44814721' 
  )
  OR 
  (
    m.measurement_concept_id = '45482322' AND m.value_as_number >= 6.5 
    AND m.measurement_type_concept_id = '45756327'
  )
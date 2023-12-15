SELECT distinct person_id
FROM condition_occurrence co
JOIN drug_exposure de ON co.person_id = de.person_id
JOIN measurement m ON co.person_id = m.person_id 
WHERE
  co.condition_concept_id IN 
  (
    SELECT concept_id FROM concept 
    WHERE concept_name = 'Diabetes mellitus' 
    AND vocabulary_id = 'ICD9CM' AND concept_code LIKE '250.%'
  )
  OR 
  co.condition_concept_id IN
  (
    SELECT concept_id FROM concept 
    WHERE concept_name = 'Diabetes mellitus' 
    AND vocabulary_id = 'ICD10CM' AND concept_code LIKE 'E11%'
  )
  OR
  m.measurement_concept_id IN 
  (
    SELECT concept_id FROM concept WHERE concept_name IN 
    ('Hemoglobin A1c/Hemoglobin.total in Blood', 'Fasting plasma glucose')
  ) 
  AND m.value_as_number >= 6.5
  OR
  de.drug_concept_id IN
  (
   SELECT concept_id FROM concept WHERE concept_name IN
   ('metformin','glipizide','rosiglitazone','pioglitazone',
   'sitagliptin','saxagliptin','linagliptin','vildagliptin', 
   'alogliptin','exenatide','liraglutide','dapagliflozin',
   'canagliflozin','empagliflozin','ertugliflozin','insulin')
  )
  OR
  de.drug_source_concept_id IN 
  (
   SELECT concept_id FROM concept WHERE concept_name IN
   ('Glucophage','Amaryl','Avandia','Actos',  
   'Januvia','Onglyza','Tradjenta','Galvus',
   'Nesina','Byetta','Victoza','Farxiga',
   'Invokana', 'Jardiance','Steglatro','Humulin','Novolin')
  )
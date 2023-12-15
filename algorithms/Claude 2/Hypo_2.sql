SELECT DISTINCT person_id 
FROM condition_occurrence
WHERE condition_concept_id IN 
  ('ICD9CM:244.0', 'ICD9CM:244.1', 'ICD9CM:244.3', 
   'ICD10CM:E03.0', 'ICD10CM:E03.1', 'ICD10CM:E03.2', 
   'ICD10CM:E03.3', 'ICD10CM:E03.4')
OR person_id IN
  (SELECT person_id 
   FROM drug_exposure 
   WHERE drug_concept_id IN 
     (' Levothyroxine generic codes', 'Liothyronine generic codes'))  
OR person_id IN 
  (SELECT person_id
   FROM measurement
   WHERE measurement_concept_id = '3023635' AND value_as_number > 4.5 -- TSH
   AND measurement_concept_id = '3022113' AND value_as_number < 0.8) -- Free T4
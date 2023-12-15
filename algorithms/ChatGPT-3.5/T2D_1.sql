SELECT DISTINCT p.person_id
FROM person p
JOIN condition_occurrence co
  ON p.person_id = co.person_id
  AND (
    (co.condition_concept_id IN (SELECT concept_id FROM concept WHERE vocabulary_id = 'ICD9CM' AND concept_code IN ('25000')) -- ICD-9-CM code for type 2 diabetes
    OR
    co.condition_concept_id IN (SELECT concept_id FROM concept WHERE vocabulary_id = 'ICD10CM' AND concept_code IN ('E11'))) -- ICD-10-CM code for type 2 diabetes
    OR
    co.condition_concept_id IN (SELECT concept_id FROM concept WHERE concept_name IN ('Type 2 Diabetes', 'DM2'))) -- OMOP concept names for type 2 diabetes

JOIN measurement m
  ON p.person_id = m.person_id
  AND m.measurement_concept_id IN (SELECT concept_id FROM concept WHERE concept_name IN ('HbA1c', 'Fasting Blood Glucose'))
  AND m.value_as_number >= 6.5 -- Threshold for abnormal blood glucose values

LEFT JOIN drug_exposure de
  ON p.person_id = de.person_id
  AND (
    de.drug_concept_id IN (SELECT concept_id FROM concept WHERE concept_name IN ('Metformin', 'Glipizide', 'Sitagliptin')) -- Common medication concepts for type 2 diabetes
    OR
    de.drug_concept_id IN (SELECT concept_id FROM concept WHERE concept_name IN ('BrandName1', 'BrandName2'))) -- Brand names of medications

LEFT JOIN observation o
  ON p.person_id = o.person_id
  AND o.observation_concept_id IN (SELECT concept_id FROM concept WHERE concept_name IN ('Polyuria', 'Polydipsia', 'Unexplained Weight Loss'))
  AND o.value_as_concept_id = 0 -- Absence of symptoms (negative observation)

LEFT JOIN (
  SELECT DISTINCT person_id, value_as_number AS bmi_value
  FROM measurement
  WHERE measurement_concept_id IN (SELECT concept_id FROM concept WHERE concept_name = 'BMI')
) bmi
  ON p.person_id = bmi.person_id
  AND bmi.bmi_value >= 25 -- BMI indicating overweight or obesity

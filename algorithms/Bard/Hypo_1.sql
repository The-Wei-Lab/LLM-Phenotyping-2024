SELECT
  person.person_id,
  condition_occurrence.condition_concept_id AS hypothyroidism_concept_id,
  condition_occurrence.condition_source_value AS hypothyroidism_source_value,
  condition_occurrence.condition_start_date AS hypothyroidism_start_date,
  condition_occurrence.condition_end_date AS hypothyroidism_end_date,
  measurement.measurement_concept_id AS thyroid_stimulating_hormone_lab_concept_id,
  measurement.value_as_number AS thyroid_stimulating_hormone_lab_result,
  measurement.measurement_date AS thyroid_stimulating_hormone_lab_date,
  drug_exposure.drug_concept_id AS levothyroxine_concept_id,
  drug_exposure.drug_exposure_start_date AS levothyroxine_start_date,
  drug_exposure.drug_exposure_end_date AS levothyroxine_end_date
FROM person
LEFT JOIN condition_occurrence ON person.person_id = condition_occurrence.person_id
LEFT JOIN measurement ON person.person_id = measurement.person_id
LEFT JOIN drug_exposure ON person.person_id = drug_exposure.person_id
WHERE
  (condition_occurrence.condition_concept_id IN (2449, 24490, 24491, 24492, 24493, E031, E032, E033, E038, E039))
  AND (measurement.measurement_concept_id = 38531048 AND measurement.value_as_number > 4.5)
  AND (drug_exposure.drug_concept_id IN (38531078, 38531079));

SELECT patient_id
FROM omop_cdm.condition_occurrence
WHERE condition_concept_id IN (
  SELECT concept_id
  FROM omop_cdm.concept
  WHERE concept_code IN ('250.xx', 'E11.xx')
)
AND occurrence_age >= 30
AND (
  SELECT COUNT(*) FROM omop_cdm.measurement
  WHERE concept_id IN (38000011, 37881693)
  AND value_as_number >= 126
  AND unit_concept_id = 38000064
) >= 1
OR (
  SELECT COUNT(*) FROM omop_cdm.measurement
  WHERE concept_id IN (38000012, 38198977)
  AND value_as_number >= 200
  AND unit_concept_id = 38000064
) >= 1
OR (
  SELECT COUNT(*) FROM omop_cdm.measurement
  WHERE concept_id IN (38000013, 38293464)
  AND value_as_number >= 6.5
) >= 1
GROUP BY patient_id
HAVING COUNT(*) >= 1;

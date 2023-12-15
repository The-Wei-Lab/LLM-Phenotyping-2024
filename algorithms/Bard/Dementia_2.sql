SELECT patient_id
FROM omop_cdm.condition_occurrence
WHERE condition_concept_id IN (
  -- ICD-9-CM codes for dementia
  '4039277', '4039278', '4039279',

  -- ICD-10-CM codes for dementia
  '36064491', '36064492', '36064493', '36064494', '36067881', '36067896'
)
AND condition_status_concept_id = 44715439 -- active
AND condition_start_date < (SELECT MAX(condition_start_date)
                             FROM omop_cdm.condition_occurrence
                             WHERE patient_id = omop_cdm.condition_occurrence.patient_id)
AND condition_type_concept_id = 44813908 -- diagnosis

AND (
  -- Symptoms of cognitive decline
  SELECT COUNT(*)
  FROM omop_cdm.observation
  WHERE patient_id = omop_cdm.condition_occurrence.patient_id
  AND observation_concept_id IN (
    -- ICD-9-CM codes for symptoms of cognitive decline
    '38580974', '38580975', '38580976', '38580977', '38580978',

    -- ICD-10-CM codes for symptoms of cognitive decline
    '38580974', '38580975', '38580976', '38580977', '38580978'
  )
  AND observation_concept_id != 44805810 -- NOT normal
) >= 1

AND (
  -- Worsening of cognitive function over time
  SELECT COUNT(*)
  FROM omop_cdm.observation
  WHERE patient_id = omop_cdm.condition_occurrence.patient_id
  AND observation_concept_id IN (
    -- ICD-9-CM codes for cognitive function tests
    '4039301', '4039302', '4039303', '38580979'

    -- ICD-10-CM codes for cognitive function tests
    '4039301', '4039302', '4039303', '38580979'
  )
  AND observation_value_numeric < (
    SELECT MAX(observation_value_numeric)
    FROM omop_cdm.observation
    WHERE patient_id = omop_cdm.condition_occurrence.patient_id
    AND observation_concept_id IN (
      '4039301', '4039302', '4039303', '38580979'
    )
  )
) >= 1

AND (
  -- Use of dementia medications
  SELECT COUNT(*)
  FROM omop_cdm.drug_exposure
  WHERE patient_id = omop_cdm.condition_occurrence.patient_id
  AND drug_concept_id IN (
    -- Generic names of dementia medications
    'Donepezil', 'Rivastigmine', 'Galantamine', 'Memantine',

    -- Brand names of dementia medications
    'Aricept', 'Razadyne', 'Razadyne ER', 'Exelon', 'Namenda'
  )
  AND drug_exposure_start_date <= omop_cdm.condition_occurrence.condition_start_date
) >= 1

GROUP BY patient_id
HAVING COUNT(*) >= 2;

-- ---------------------- --
-- LLM produced algorithm --
-- ---------------------- --

SELECT DISTINCT co.person_id 
FROM condition_occurrence AS co
JOIN concept AS c ON co.condition_concept_id = c.concept_id
LEFT JOIN measurement AS m ON co.person_id = m.person_id
LEFT JOIN drug_exposure AS de ON co.person_id = de.person_id
LEFT JOIN observation AS o ON co.person_id = o.person_id
WHERE 
(
    -- Diagnosis of Type 2 Diabetes
    c.concept_code IN ('250.x0', '250.x2', 'E11.x') AND c.vocabulary_id IN ('ICD9CM', 'ICD10CM')
    OR
    -- Lab Tests
    (
        (m.measurement_concept_id = (SELECT concept_id FROM concept WHERE concept_name = 'Fasting blood sugar') AND m.value_as_number > 126)
        OR (m.measurement_concept_id = (SELECT concept_id FROM concept WHERE concept_name = 'Hemoglobin A1c') AND m.value_as_number > 6.5)
        OR (m.measurement_concept_id = (SELECT concept_id FROM concept WHERE concept_name = 'Oral Glucose Tolerance Test') AND m.value_as_number > 200)
    )
    OR
    -- Symptoms
    o.observation_concept_id IN (
        SELECT concept_id FROM concept WHERE concept_name IN ('Polyuria', 'Polydipsia', 'Unexplained weight loss')
    )
    OR
    -- Medications
    de.drug_concept_id IN 
    (
        SELECT concept_id FROM concept 
        WHERE concept_name IN ('Metformin', 'Glipizide', 'Glucophage', 'Glucotrol', 'Glyburide', 'Diabeta', 'Glynase', 'Glucophage XR', 'Glucotrol XL')
    )
)
AND NOT 
(
    -- Excluding Diagnosis of Type 1 Diabetes
    c.concept_code IN ('250.x1', '250.x3', 'E10.x') AND c.vocabulary_id IN ('ICD9CM', 'ICD10CM')
);


-- ##############################################################################################################################################################

-- ------------------- --
-- Implemented version --
-- ------------------- --

create or replace table jamia_llm_v1.llm_a_t2d_2_code as
select distinct person_id from
(
select distinct person_id from jamia_llm_v1.phemap_t2d_gwas_v1 -- This table contains the patients from the eMERGE phenotype implementation
left join sd_omop_prod.condition_occurrence
using (person_id)
where (condition_source_value like '250.%0'
or condition_source_value like '250.%2'
or condition_source_value like 'E11%')
and year(condition_start_date) < 2020 -- Added to better match the temporal window of the eMERGE implementation

union
select distinct person_id from jamia_llm_v1.phemap_t2d_gwas_v1 -- This table contains the patients from the eMERGE phenotype implementation
left join sd_omop_prod.observation 
using (person_id)
where (
  lower(observation_source_value) like '%polyuria%'
  OR 
  lower(observation_source_value) like '%polydipsia%'
  OR
  lower(observation_source_value) like '%unexplained weight loss%'
  )
and year(observation_date) < 2020 -- Added to better match the temporal window of the eMERGE implementation

union
select distinct person_id  from jamia_llm_v1.phemap_t2d_gwas_v1 -- This table contains the patients from the eMERGE phenotype implementation
left join sd_omop_prod.measurement 
using (person_id)
        WHERE 
        (
        (lower(measurement_source_value) like lower('%Fasting blood sugar%') and value_as_number>126)
        OR 
        (lower(measurement_source_value) like lower('%Hemoglobin A1c%') and value_as_number>6.5)
        OR
        (lower(measurement_source_value) like lower('%Oral Glucose Tolerance Test%') and value_as_number>200)
        )
and year(measurement_datetime) < 2020 -- Added to better match the temporal window of the eMERGE implementation

union
select distinct person_id from jamia_llm_v1.phemap_t2d_gwas_v1 -- This table contains the patients from the eMERGE phenotype implementation
left join sd_omop_prod.drug_exposure
using (person_id)
where (
  lower(drug_source_value) like lower('%Metformin%')
  OR 
  lower(drug_source_value) like lower('%Glipizide%')
  OR
  lower(drug_source_value) like lower('%Glucophage%')
  OR
  lower(drug_source_value) like lower('%Glucotrol%')
  OR
  lower(drug_source_value) like lower('%Glyburide%')
  OR
  lower(drug_source_value) like lower('%Diabeta%')
  OR
  lower(drug_source_value) like lower('%Glynase%')
  OR
  lower(drug_source_value) like lower('%Glucophage XR%')
  OR
  lower(drug_source_value) like lower('%Glucotrol XL%')
  )
and year(drug_exposure_start_date) < 2020 -- Added to better match the temporal window of the eMERGE implementation


) 
where person_id not in (
  
select distinct person_id from jamia_llm_v1.phemap_t2d_gwas_v1
left join sd_omop_prod.condition_occurrence
using (person_id)
where (condition_source_value like '250.%1'
or condition_source_value like '250.%3'
or condition_source_value like 'E10%')

)
  ;
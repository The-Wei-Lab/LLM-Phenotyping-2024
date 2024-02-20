-- ---------------------- --
-- LLM produced algorithm --
-- ---------------------- --

SELECT DISTINCT p.person_id
FROM person p
LEFT JOIN condition_occurrence co
  ON p.person_id = co.person_id
  AND (
    (co.condition_concept_id IN (SELECT concept_id FROM concept WHERE vocabulary_id = 'ICD9CM' AND concept_code LIKE '250%')) -- ICD-9-CM code for type 2 diabetes
    OR
    (co.condition_concept_id IN (SELECT concept_id FROM concept WHERE vocabulary_id = 'ICD10CM' AND concept_code LIKE 'E11%')) -- ICD-10-CM code for type 2 diabetes
    OR
    (co.condition_concept_id IN (SELECT concept_id FROM concept WHERE concept_name IN ('Type 2 Diabetes', 'DM2'))) -- OMOP concept names for type 2 diabetes
  )
LEFT JOIN measurement m
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

-- ##############################################################################################################################################################

-- ------------------- --
-- Implemented version --
-- ------------------- --

create or replace table jamia_llm_v1.llm_a_t2d_2_code_drug as

select distinct person_id from (
  select distinct person_id from (
      select distinct person_id from (
              select distinct person_id from (
                  select distinct person_id from jamia_llm_v1.phemap_t2d_gwas_v1 -- This table contains the patients from the eMERGE phenotype implementation
                  left join sd_omop_prod.condition_occurrence
                  using (person_id)
                  where (condition_source_value like '250%'
                  or condition_source_value like 'E11%')
                  and year(condition_start_date) < 2020 -- Added to better match the temporal window of the eMERGE implementation

              ) as a left join hive_metastore.sd_omop_prod.measurement
              using (person_id)
                    WHERE
                    (
                    (lower(measurement_source_value) like lower('%Fasting blood sugar%') and value_as_number>6.5)
                    OR
                    (lower(measurement_source_value) like lower('%Hemoglobin A1c%') and value_as_number>6.5)
                    )
              and year(measurement_datetime) < 2020 -- Added to better match the temporal window of the eMERGE implementation

      ) as b left join sd_omop_prod.drug_exposure
      using (person_id)
      where (
        lower(drug_source_value) like lower('%Metformin%')
        OR
        lower(drug_source_value) like lower('%Glipizide%')
        OR
        lower(drug_source_value) like lower('%Sitagliptin%')
        )
      and year(drug_exposure_start_date) < 2020 -- Added to better match the temporal window of the eMERGE implementation

  ) as c left join sd_omop_prod.observation
  using (person_id)
  where (
    lower(observation_source_value) like '%polyuria%'
    OR
    lower(observation_source_value) like '%polydipsia%'
    OR
    lower(observation_source_value) like '%unexplained weight loss%'
    )
  and year(observation_date) < 2020 -- Added to better match the temporal window of the eMERGE implementation

) as d left join hive_metastore.sd_omop_prod.measurement
using (person_id)
        WHERE
        (lower(measurement_source_value) like lower('%BMI%') and value_as_number>25)
and year(measurement_datetime) < 2020 -- Added to better match the temporal window of the eMERGE implementation
;
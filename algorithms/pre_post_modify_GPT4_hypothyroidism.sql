-- ---------------------- --
-- LLM produced algorithm --
-- ---------------------- --

SELECT DISTINCT p.person_id
FROM person AS p
LEFT JOIN condition_occurrence AS co ON p.person_id = co.person_id
LEFT JOIN observation AS obs ON p.person_id = obs.person_id
LEFT JOIN drug_exposure AS de ON p.person_id = de.person_id
LEFT JOIN measurement AS m ON p.person_id = m.person_id
WHERE 
    -- Diagnosis
    co.condition_concept_id IN (SELECT concept_id FROM concept WHERE concept_code IN ('244.0', '244.1', '244.2', '244.3', '244.8', '244.9', 'E03.8', 'E03.9', 'E02', 'E89.0'))
    OR
    (
        -- Symptoms
        obs.observation_concept_id IN (SELECT concept_id FROM concept WHERE concept_name IN ('Fatigue', 'Weight gain', 'Cold intolerance', 'Dry skin', 'Bradycardia', 'Hair loss'))
        AND
        -- Laboratory findings
        (
            (m.measurement_concept_id = (SELECT concept_id FROM concept WHERE concept_name = 'Serum TSH') AND m.value_as_number > m.range_high)
            OR 
            (m.measurement_concept_id = (SELECT concept_id FROM concept WHERE concept_name = 'Serum Free T4') AND m.value_as_number < m.range_low)
        )
    )
    OR
    (
        -- Medications for hypothyroidism treatment and those causing hypothyroidism
        de.drug_concept_id IN (SELECT concept_id FROM concept WHERE concept_name IN ('Levothyroxine', 'Synthroid', 'Levoxyl', 'Euthyrox', 'Eltroxin', 'Liothyronine', 'Cytomel', 'Desiccated thyroid', 'Armour Thyroid', 'Nature-Throid', 'WP Thyroid', 'lithium', 'amiodarone', 'Lithobid', 'Cordarone', 'Nexterone', 'Pacerone'))
    )
AND
    -- Exclusion criteria
    NOT EXISTS 
    (
        SELECT 1 FROM procedure_occurrence AS po WHERE p.person_id = po.person_id AND po.procedure_concept_id IN (SELECT concept_id FROM concept WHERE concept_name IN ('Thyroid surgery', 'Radioactive Iodine treatment'))
    );



-- ##############################################################################################################################################################

-- ------------------- --
-- Implemented version --
-- ------------------- --

create or replace table jamia_llm_v1.llm_a_hypo_2_code as 
select distinct person_id from
(


select distinct person_id from jamia_llm_v1.phemap_hypo_gwas_v1 -- This table contains the patients from the eMERGE phenotype implementation
left join sd_omop_prod.condition_occurrence
using (person_id)
where condition_source_value in ('244.0', '244.1', '244.2', '244.3', '244.8', '244.9', 'E03.8', 'E03.9', 'E02', 'E89.0')
and year(condition_start_date) < 2020 -- Added to better match the temporal window of the eMERGE implementation


union
select distinct person_id from jamia_llm_v1.phemap_hypo_gwas_v1 -- This table contains the patients from the eMERGE phenotype implementation
left join sd_omop_prod.drug_exposure 
using (person_id)
where (
  lower(drug_source_value) like lower('%Levothyroxine%')
  OR 
  lower(drug_source_value) like lower('%Synthroid%')
  OR
  lower(drug_source_value) like lower('%Levoxyl%')
  OR
  lower(drug_source_value) like lower('%Euthyrox%')
  OR
  lower(drug_source_value) like lower('%Eltroxin%')
  OR
  lower(drug_source_value) like lower('%Liothyronine%')
  OR
  lower(drug_source_value) like lower('%Cytomel%')
  OR
  lower(drug_source_value) like lower('%Desiccated thyroid%')
  OR
  lower(drug_source_value) like lower('%Armour Thyroid%')  
  OR
  lower(drug_source_value) like lower('%Nature-Throid%')
  OR
  lower(drug_source_value) like lower('%WP Thyroid%')
  OR
  lower(drug_source_value) like lower('%lithium%')
  OR
  lower(drug_source_value) like lower('%amiodarone%')
  OR
  lower(drug_source_value) like lower('Lithobid%')
  OR
  lower(drug_source_value) like lower('%Cordarone%')
  OR
  lower(drug_source_value) like lower('Nexterone%')
  OR
  lower(drug_source_value) like lower('%Pacerone%')
  )
and year(drug_exposure_start_date) < 2020 -- Added to better match the temporal window of the eMERGE implementation

union
select distinct person_id from (
select distinct person_id from jamia_llm_v1.phemap_hypo_gwas_v1 -- This table contains the patients from the eMERGE phenotype implementation
left join sd_omop_prod.observation 
using (person_id)
where (
  lower(observation_source_value) like '%fatigue%'
  OR 
  lower(observation_source_value) like '%weight gain%'
  OR
  lower(observation_source_value) like '%cold intolerance%'
  or   
  lower(observation_source_value) like '%dry skin%'
  OR 
  lower(observation_source_value) like '%bradycardia%'
  OR
  lower(observation_source_value) like '%hair loss%'
  )
and year(observation_date) < 2020 -- Added to better match the temporal window of the eMERGE implementation
) as x left join sd_omop_prod.measurement
using (person_id)
        WHERE 
        (lower(measurement_source_value) like lower('%Serum TSH%') AND m.value_as_number > m.range_high) 
        OR
        (lower(measurement_source_value) like lower('%Oral Glucose Tolerance Test%') AND m.value_as_number < m.range_low) 
) 
where person_id not in (
  
select distinct person_id from jamia_llm_v1.phemap_hypo_gwas_v1
left join sd_omop_prod.procedure_occurrence
using (person_id)
where (
        lower(procedure_source_value) like lower('%Thyroid surgery%')
        OR 
        lower(procedure_source_value) like lower('%Radioactive Iodine treatment%')
    )

)
  ;
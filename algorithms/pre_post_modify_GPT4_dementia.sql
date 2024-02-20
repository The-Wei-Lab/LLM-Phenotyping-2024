-- ---------------------- --
-- LLM produced algorithm --
-- ---------------------- --

SELECT DISTINCT p.person_id 
FROM person p

LEFT JOIN condition_occurrence co ON p.person_id = co.person_id 
LEFT JOIN drug_exposure de ON p.person_id = de.person_id
LEFT JOIN procedure_occurrence po ON p.person_id = po.person_id
LEFT JOIN observation o ON p.person_id = o.person_id

WHERE 
    (
        -- Diagnosis Codes for Dementia
        co.condition_concept_id IN ('ICD9CM:290', 'ICD9CM:294.1', 'ICD9CM:331.0', 'ICD10CM:G30', 'ICD10CM:F00', 'ICD10CM:F03')
        OR
        -- Symptoms and Signs of Dementia
        o.observation_concept_id IN ('OMOP:memory_loss', 'OMOP:impaired_reasoning', 'OMOP:impaired_communication')
        OR
        -- Cognitive Assessment Tests or Procedures
        po.procedure_concept_id IN ('OMOP:MMSE', 'OMOP:MoCA', 'OMOP:neuropsychological_testing', 'OMOP:Brain Imaging Procedure')
    )
    AND 
    -- Medications, both generic and brand names
    de.drug_concept_id IN ('OMOP:donepezil', 'OMOP:Aricept', 'OMOP:memantine', 'OMOP:Namenda', 'OMOP:Rivastigmine', 'OMOP:Exelon', 'OMOP:Galantamine', 'OMOP:Razadyne')
    AND
    -- Exclusionary Criteria
    NOT EXISTS (
        SELECT 1 
        FROM measurement m
        WHERE p.person_id = m.person_id 
        AND m.measurement_concept_id IN ('OMOP:thyroid_function_test', 'OMOP:B12_level', 'OMOP:syphilis_test')
    );


-- ##############################################################################################################################################################

-- ------------------- --
-- Implemented version --
-- ------------------- --

create or replace table jamia_llm_v1.llm_a_dementia_2_code as 
select * from
(
select distinct person_id from jamia_llm_v1.phemap_dementia_gwas_v1 -- This table contains the patients from the eMERGE phenotype implementation
left join sd_omop_prod.condition_occurrence
using (person_id)
where condition_source_value in ('290', '294.1', '331.0', 'G30', 'F00', 'F03')
and year(condition_start_date) < 2020 -- Added to better match the temporal window of the eMERGE implementation

union
select distinct person_id from jamia_llm_v1.phemap_dementia_gwas_v1 -- This table contains the patients from the eMERGE phenotype implementation
left join sd_omop_prod.observation 
using (person_id)
where (
  lower(observation_source_value) like '%memory loss%'
  OR 
  lower(observation_source_value) like '%impaired reasoning%'
  OR
  lower(observation_source_value) like '%impaired communication%'
  )
and year(observation_date) < 2020 -- Added to better match the temporal window of the eMERGE implementation

union
select distinct person_id from jamia_llm_v1.phemap_dementia_gwas_v1 -- This table contains the patients from the eMERGE phenotype implementation
left join sd_omop_prod.procedure_occurrence
using (person_id)
where (
  lower(procedure_source_value) like lower('%mini-mental%')
  OR 
  lower(procedure_source_value) like lower('%montreal cog%')
  OR
  lower(procedure_source_value) like lower('%neuropsychological testing%')
  OR
  lower(procedure_source_value) like lower('%Brain Imaging Procedure%')
  )
and year(procedure_date) < 2020 -- Added to better match the temporal window of the eMERGE implementation

) as a left join sd_omop_prod.drug_exposure
using (person_id)
where (
  lower(drug_source_value) like lower('%donepezil%')
  OR 
  lower(drug_source_value) like lower('%Aricept%')
  OR
  lower(drug_source_value) like lower('%memantine%')
  OR
  lower(drug_source_value) like lower('%Namenda%')
  OR
  lower(drug_source_value) like lower('%Rivastigmine%')
  OR
  lower(drug_source_value) like lower('%Exelon%')
  OR
  lower(drug_source_value) like lower('%Galantamine%')
  OR
  lower(drug_source_value) like lower('%Razadyne%')
  )
and year(drug_exposure_start_date) < 2020 -- Added to better match the temporal window of the eMERGE implementation
and person_id not in (
  
 SELECT person_id  FROM sd_omop_prod.measurement 
        WHERE 
        (
        lower(measurement_source_value) like lower('%thyroid function test%')
        OR 
        lower(measurement_source_value) like lower('%B12 level%')
        OR
        lower(measurement_source_value) like lower('%syphilis test%')
        )
)
  ;

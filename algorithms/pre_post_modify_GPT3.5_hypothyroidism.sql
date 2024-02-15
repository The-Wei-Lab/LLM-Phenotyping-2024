### LLM produced algorithm

SELECT DISTINCT c.person_id
FROM condition_occurrence c
WHERE (
  -- Diagnosis criteria (ICD-9-CM and ICD-10-CM codes)
  c.condition_concept_id IN (
    SELECT concept_id
    FROM concept
    WHERE (
      (vocabulary_id IN ('ICD9CM', 'ICD10CM') AND
      concept_code IN ('244.9', 'E03.9', 'E03.8', 'E03.2', 'E03.1', 'E03.0', 'E03.5', 'E03.3', 'E03.89', 'E03.89', 'E03.9', 'E03.8'))
    )
  )
  OR
  -- Symptom criteria (Using OMOP concept names)
  c.condition_concept_id IN (
    SELECT concept_id
    FROM concept
    WHERE concept_name IN (
      'Fatigue', 'Cold intolerance', 'Weight gain', 'Dry skin', 'Constipation', 'Bradycardia'
    )
  )
  OR
  -- Laboratory test criteria (Assuming lab results are in measurement table)
  EXISTS (
    SELECT 1
    FROM measurement m
    WHERE m.person_id = c.person_id
    AND m.measurement_concept_id IN (
      SELECT concept_id
      FROM concept
      WHERE concept_name = 'Thyroid-stimulating hormone (TSH)'
    )
    AND m.value_as_number > 4.5
  )
  OR
  -- Medication criteria (Generic and brand names)
  EXISTS (
    SELECT 1
    FROM drug_exposure d
    WHERE d.person_id = c.person_id
    AND d.drug_concept_id IN (
      SELECT concept_id
      FROM concept
      WHERE (
        (vocabulary_id IN ('RxNorm', 'Multum') AND
        concept_name IN ('Levothyroxine', 'Synthroid'))
      )
    )
  )
);




### Implemented version

select * from jamia_llm_v1.phemap_hypo_gwas_v1; -- this table contains the GRIDs from the eMERGE phenotype implementation

create or replace table llm_b_hypo_2_code as -- these tables live in default
select distinct person_id from
(


select distinct person_id from jamia_llm_v1.phemap_hypo_gwas_v1 -- this table contains the GRIDs from the eMERGE phenotype implementation
left join sd_omop_prod.condition_occurrence
using (person_id)
where condition_source_value in ('244.9', 'E03.9', 'E03.8', 'E03.2', 'E03.1', 'E03.0', 'E03.5', 'E03.3', 'E03.89', 'E03.89', 'E03.9', 'E03.8')
and year(condition_start_date)<2020


union

select distinct person_id from jamia_llm_v1.phemap_hypo_gwas_v1
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
  lower(observation_source_value) like '%constipation%'
  OR
  lower(observation_source_value) like '%bradycardia%'
  )
and year(observation_date)<2020

union

select distinct person_id from jamia_llm_v1.phemap_hypo_gwas_v1
left join sd_omop_prod.drug_exposure
using (person_id)
where (
  lower(drug_source_value) like lower('%Levothyroxine%')
  OR 
  lower(drug_source_value) like lower('%Synthroid%')
  )
and year(drug_exposure_start_date)<2020

union


select distinct person_id from jamia_llm_v1.phemap_hypo_gwas_v1
left join sd_omop_prod.measurement 
using (person_id)
        WHERE 
        lower(measurement_source_value) like lower('%Thyroid-stimulating hormone (TSH)%')  and value_as_number>4.5
and year(measurement_datetime)<2020
  
)
  ;
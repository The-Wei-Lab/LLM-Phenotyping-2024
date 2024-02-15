### LLM produced algorithm

SELECT DISTINCT p.person_id
FROM person AS p
WHERE (
    -- Diagnosis Criteria
    (p.person_id IN (
        SELECT DISTINCT dx.person_id
        FROM condition_occurrence AS dx
        WHERE dx.condition_concept_id IN (
            SELECT concept_id
            FROM concept
            WHERE (
                -- Dementia ICD9CM codes
                (vocabulary_id = 'ICD9CM' AND concept_code LIKE '290%') OR
                -- Dementia ICD10CM codes
                (vocabulary_id = 'ICD10CM' AND concept_code IN ('F00', 'F01'))
            )
        )
    )) OR

    -- Symptoms Criteria
    (p.person_id IN (
        SELECT DISTINCT sx.person_id
        FROM condition_occurrence AS sx
        JOIN concept AS sym ON sx.condition_concept_id = sym.concept_id
        WHERE sym.concept_name IN ('Memory Loss', 'Cognitive Impairment', 'Disorientation', 'Language problems', 'Behavioral changes')
    )) OR

    -- Procedures Criteria
    (p.person_id IN (
        SELECT DISTINCT proc.person_id
        FROM procedure_occurrence AS proc
        WHERE (
            proc.procedure_concept_id IN (
                SELECT concept_id
                FROM concept
                WHERE concept_name IN ('Neuropsychological Testing', 'MRI scan', 'CT scan')
            )
        )
    )) OR

    -- Medication Criteria
    (p.person_id IN (
        SELECT DISTINCT med.person_id
        FROM drug_exposure AS med
        WHERE (
            -- Dementia Medication (Generic and Brand) Names
            (med.drug_concept_id IN (
                SELECT concept_id
                FROM concept
                WHERE concept_name IN ('Donepezil', 'Memantine', 'Aricept', 'Namenda')
            ))
        )
    ))
);




### Implemented version

select * from jamia_llm_v1.phemap_dementia_gwas_v1 -- this table contains the GRIDs from the eMERGE phenotype implementation

create or replace table llm_b_dementia_2_code as -- these tables live in default
select distinct person_id from
(
select distinct person_id from jamia_llm_v1.phemap_dementia_gwas_v1 -- this table contains the GRIDs from the eMERGE phenotype implementation
left join sd_omop_prod.condition_occurrence
using (person_id)
where condition_source_value like '290.%'
or condition_source_value in ('F00', 'F01')
and year(condition_start_date)<2020

union
select distinct person_id from jamia_llm_v1.phemap_dementia_gwas_v1
left join sd_omop_prod.observation 
using (person_id)
where (
  lower(observation_source_value) like '%memory loss%'
  OR 
  lower(observation_source_value) like '%cognitive impairment%'
  OR
  lower(observation_source_value) like '%disorientation%'
  OR 
  lower(observation_source_value) like '%language problems%'
  OR 
  lower(observation_source_value) like '%behavioral changes%'
  )
and year(observation_date)<2020


union
select distinct person_id from jamia_llm_v1.phemap_dementia_gwas_v1
left join sd_omop_prod.measurement 
using (person_id)
        WHERE 
        (
        lower(measurement_source_value) like lower('%Neuropsychological Testing%')
        OR 
        lower(measurement_source_value) like lower('%MRI scan%')
        OR
        lower(measurement_source_value) like lower('%CT scan%')
        )

and year(measurement_datetime)<2020


union
select distinct person_id from jamia_llm_v1.phemap_dementia_gwas_v1
left join sd_omop_prod.drug_exposure
using (person_id)
where (
  lower(drug_source_value) like lower('%donepezil%')
  OR 
  lower(drug_source_value) like lower('%Aricept%')
  OR
  lower(drug_source_value) like lower('%memantine%')
  OR
  lower(drug_source_value) like lower('%Namenda%')
  )
and year(drug_exposure_start_date)<2020
)

  ;

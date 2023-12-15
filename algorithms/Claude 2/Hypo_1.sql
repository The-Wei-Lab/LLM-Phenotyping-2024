SELECT DISTINCT person_id
FROM condition_occurrence
WHERE condition_concept_id IN (
SELECT concept_id
FROM concept
WHERE concept_code IN ('244.0', '244.1', '244.3', '244.8', '244.9', 'E03.0', 'E03.1', 'E03.2', 'E03.3', 'E03.4', 'E03.5', 'E03.8', 'E03.9')
)
OR person_id IN (
SELECT person_id
FROM drug_exposure
WHERE drug_concept_id IN (
SELECT concept_id
FROM concept
WHERE concept_name IN ('levothyroxine', 'liothyronine', 'thyroid desiccated', 'Synthroid', 'Levoxyl', 'Unithroid', 'Levothroid')
)

)
OR condition_concept_id IN (
SELECT concept_id
FROM concept
WHERE concept_code IN ('244.8', 'E03.5')

)
AND person_id IN (
SELECT person_id
FROM measurement
WHERE measurement_concept_id IN (
4543234, -- TSH
4567123  -- Free T4
)
AND value_as_number > 4.5 -- TSH
OR value_as_number < 0.8 -- Free T4
)


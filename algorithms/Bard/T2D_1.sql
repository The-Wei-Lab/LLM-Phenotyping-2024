SELECT person_id
FROM condition_occurrence
WHERE condition_concept_id IN ('250.x0', '250.x2', 'E11.x', 'E14.x')
AND condition_type_concept_id = 44816478 -- Diagnosis of type 2 diabetes

AND (
    SELECT COUNT(*)
    FROM observation_fact
    WHERE observation_concept_id IN ('45768284', '45768297', '45768305', '45768313')
    AND observation_type_concept_id = 44818372
    AND person_id = condition_occurrence.person_id
) > 0 -- Presence of at least one symptom of T2D

AND (
    SELECT COUNT(*)
    FROM measurement_fact
    WHERE measurement_concept_id IN ('38550393', '38550394', '38550395')
    AND measurement_type_concept_id = 44818372
    AND value_as_number >= 126
    AND person_id = condition_occurrence.person_id
) > 0 -- Presence of at least one laboratory finding suggestive of T2D

AND (
    SELECT COUNT(*)
    FROM condition_occurrence
    WHERE condition_concept_id IN ('373870294', '373870300')
    AND condition_type_concept_id = 44816478
    AND person_id = condition_occurrence.person_id
) = 0 -- Absence of type 1 diabetes

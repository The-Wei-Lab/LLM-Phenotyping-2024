SELECT DISTINCT person_id 
FROM condition_occurrence

-- Joining with concept table to map to standard concepts
JOIN concept ON condition_occurrence.condition_concept_id = concept.concept_id

WHERE 
(
    -- ICD9CM and ICD10CM codes for diagnosis
    concept_code IN ('244.0', '244.9') 
    OR 
    concept_code IN ('E03.9', 'E03.8')
)
OR 
(
    EXISTS 
    (
        -- Subquery for symptoms of hypothyroidism
        SELECT 1
        FROM observation
        JOIN concept ON observation.observation_concept_id = concept.concept_id
        WHERE 
        observation.person_id = condition_occurrence.person_id
        AND 
        concept.concept_name IN ('Fatigue', 'Cold intolerance', 'Weight gain', 'Constipation', 'Dry skin')
    )
    AND
    (
        EXISTS 
        (
            -- Subquery for laboratory findings supporting hypothyroidism
            SELECT 1
            FROM measurement
            JOIN concept ON measurement.measurement_concept_id = concept.concept_id
            WHERE 
            measurement.person_id = condition_occurrence.person_id
            AND 
            (
                (concept.concept_name = 'TSH' AND value_as_number > (SELECT MAX(range_high) FROM measurement WHERE measurement_concept_id = concept.concept_id))
                OR 
                (concept.concept_name = 'Free T4' AND value_as_number < (SELECT MIN(range_low) FROM measurement WHERE measurement_concept_id = concept.concept_id))
            )
        )
        OR 
        EXISTS 
        (
            -- Subquery for medications used for hypothyroidism
            SELECT 1
            FROM drug_exposure
            JOIN concept ON drug_exposure.drug_concept_id = concept.concept_id
            WHERE 
            drug_exposure.person_id = condition_occurrence.person_id
            AND 
            concept.concept_name IN ('Levothyroxine', 'Synthroid', 'Levoxyl', 'Euthyrox')
        )
    )
);

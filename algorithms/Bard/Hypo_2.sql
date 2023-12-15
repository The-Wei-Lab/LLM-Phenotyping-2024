SELECT
  p.person_id AS patient_id
FROM
  person p
  INNER JOIN condition_occurrence co ON p.person_id = co.person_id
  INNER JOIN measurement o ON p.person_id = o.person_id
WHERE
  co.concept_code IN (ICD9CM:244, ICD9CM:245, ICD10CM:E00, ICD10CM:E01, ICD10CM:E02, ICD10CM:E03)
  AND o.concept_id IN (
    OMOP:4114269, -- Fatigue
    OMOP:37351895, -- Weight gain
    OMOP:42774893, -- Constipation
    OMOP:38541417, -- Cold intolerance
    OMOP:38541574, -- Dry skin
    OMOP:45855702, -- Hair loss
    OMOP:37304639, -- Thyroid stimulating hormone (TSH)
    OMOP:37305284 -- Free thyroxine (T4)
  )
GROUP BY
  p.person_id
HAVING
  COUNT(*) >= 2;

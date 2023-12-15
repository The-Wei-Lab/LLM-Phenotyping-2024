SELECT distinct person_id

FROM condition_occurrence co
JOIN drug_exposure de ON co.person_id = de.person_id
WHERE co.condition_concept_id IN (38003564,38004432,40622007,43983002)
AND de.drug_concept_id IN
(
19132568, 19019009, 19126289, 1521642,
432823, 112607, 426862, 199675,
1346819, 1346843, 40231321, 1346820
)
SELECT patient_id
FROM omop_cdm.person
WHERE (
  (
    concept_id IN (
      '4039277', /* ICD-9-CM: 290.xx */
      '4039278', /* ICD-9-CM: 331.xx */
      '4039279' /* ICD-9-CM: 794.xx */
    )
  )
  OR (
    concept_id IN (
      '36064491', /* ICD-10-CM: F00 */
      '36064492', /* ICD-10-CM: F01 */
      '36064493', /* ICD-10-CM: F02 */
      '36064494', /* ICD-10-CM: F03 */
      '36067881', /* ICD-10-CM: G30 */
      '36067896' /* ICD-10-CM: G31.8 */
    )
  )
)
AND (
  concept_id IN (
    '38580974', /* Cognitive impairment */
    '38580975', /* Memory loss */
    '38580976', /* Difficulty with language */
    '38580977', /* Difficulty with problem-solving and reasoning */
    '38580978' /* Difficulty with activities of daily living */
  )
)
AND (
  concept_id IN (
    '4039301', /* Mini-Mental State Examination (MMSE) */
    '4039302', /* Montreal Cognitive Assessment (MoCA) */
    '4039303', /* Alzheimer's Disease Assessment Scale-Cognitive Subscale (ADAS-Cog) */
    '38580979' /* Neuropsychological testing */
  )
)
AND (
  concept_id IN (
    '4039320', /* Brain imaging (MRI) */
    '4039321', /* Brain imaging (CT) */
    '38580980' /* Blood tests */
  )
)
AND (
  concept_id IN (
    '4039347', /* Donepezil */
    '4039348', /* Rivastigmine */
    '4039349', /* Galantamine */
    '4039350', /* Memantine */
    '4039351' /* N-methyl-D-aspartate (NMDA) receptor antagonists */
  )
)
GROUP BY patient_id;

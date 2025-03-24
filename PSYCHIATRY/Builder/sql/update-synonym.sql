DROP TABLE if EXISTS vocab.concept_syn_staging;

CREATE TABLE vocab.concept_syn_staging AS (
                                              SELECT *
                                              FROM vocab.concept_synonym limit 0
                                          );

WITH syn_check AS (
                      SELECT a.concept_id,
                             a.synonym,
                             4180186               AS language_concept_id,
                             b.language_concept_id AS is_present
                      FROM vocab.concept_s_staging a
                               LEFT JOIN vocab.concept_synonym b
                                         ON a.concept_id = b.concept_id
                                             AND a.synonym = b.concept_synonym_name
                      WHERE NULLIF(TRIM(a.synonym), '') IS NOT NULL
                        AND TRIM(a.synonym) != '?'
                  )
INSERT
INTO vocab.concept_syn_staging (concept_id,
				       concept_synonym_name,
				       language_concept_id)
SELECT concept_id,
       synonym,
       language_concept_id
FROM syn_check
WHERE is_present IS NULL;

WITH syn_check AS (
                      SELECT a.concept_id,
                             a.synonym,
                             4180186               AS language_concept_id,
                             b.language_concept_id AS is_present
                      FROM vocab.concept_ns_staging a
                               LEFT JOIN vocab.concept_synonym b
                                         ON a.concept_id = b.concept_id
                                             AND a.synonym = b.concept_synonym_name
                      WHERE NULLIF(TRIM(a.synonym), '') IS NOT NULL
                        AND TRIM(a.synonym) != '?'
                  )
INSERT
INTO vocab.concept_syn_staging (concept_id,
				       concept_synonym_name,
				       language_concept_id)
SELECT concept_id,
       synonym,
       language_concept_id
FROM syn_check
WHERE is_present IS NULL;


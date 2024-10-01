/*
---------  ----------  ----------  ----------  ----------
-- CRITICAL INSERT BLOCK
---------  ----------  ----------  ----------  ----------
 */


INSERT INTO vocab.concept(concept_id,
                          concept_name,
                          domain_id,
                          vocabulary_id,
                          concept_class_id,
                          standard_concept,
                          concept_code,
                          valid_start_date,
                          valid_end_date,
                          invalid_reason)
SELECT concept_id,
       concept_name,
       domain_id,
       vocabulary_id,
       concept_class_id,
       standard_concept,
       concept_code,
       valid_start_date,
       valid_end_date,
       invalid_reason
FROM vocab.concept_s_staging;

INSERT INTO vocab.concept(concept_id,
                          concept_name,
                          domain_id,
                          vocabulary_id,
                          concept_class_id,
                          standard_concept,
                          concept_code,
                          valid_start_date,
                          valid_end_date,
                          invalid_reason)
SELECT concept_id,
       concept_name,
       domain_id,
       vocabulary_id,
       concept_class_id,
       standard_concept,
       concept_code,
       valid_start_date,
       valid_end_date,
       invalid_reason
FROM vocab.concept_ns_staging;


INSERT INTO vocab.concept_relationship(concept_id_1,
                                       concept_id_2,
                                       relationship_id,
                                       valid_start_date,
                                       valid_end_date,
                                       invalid_reason)
SELECT concept_id_1,
       concept_id_2,
       relationship_id,
       valid_start_date,
       valid_end_date,
       invalid_reason
FROM vocab.concept_rel_s_staging;

-- PREVENT OVERLAP BETWEEN S and NS CONC REL UPDATES

DELETE
FROM vocab.concept_rel_ns_staging a USING (
    SELECT concept_id_1, concept_id_2
    FROM vocab.concept_relationship
    WHERE concept_id_1 > 2000000000
       OR concept_id_2 > 2000000000
) b
WHERE a.concept_id_1 = b.concept_id_1
  AND a.concept_id_2 = b.concept_id_2;

INSERT INTO vocab.concept_relationship(concept_id_1,
                                       concept_id_2,
                                       relationship_id,
                                       valid_start_date,
                                       valid_end_date,
                                       invalid_reason)
SELECT concept_id_1,
       concept_id_2,
       relationship_id,
       valid_start_date,
       valid_end_date,
       invalid_reason
FROM vocab.concept_rel_ns_staging;

INSERT INTO vocab.concept_ancestor(ancestor_concept_id,
                                   descendant_concept_id,
                                   min_levels_of_separation,
                                   max_levels_of_separation)
SELECT ancestor_concept_id,
       descendant_concept_id,
       min_levels_of_separation,
       max_levels_of_separation
FROM vocab.concept_anc_s_staging;

INSERT INTO vocab.source_to_concept_map(source_code,
                                        source_concept_id,
                                        source_vocabulary_id,
                                        source_code_description,
                                        target_concept_id,
                                        target_vocabulary_id,
                                        valid_start_date,
                                        valid_end_date,
                                        invalid_reason)
SELECT source_code,
       source_concept_id,
       source_vocabulary_id,
       source_code_description,
       target_concept_id,
       target_vocabulary_id,
       valid_start_date,
       valid_end_date,
       invalid_reason
FROM vocab.s2c_map_staging;


/*
---------  ----------  ----------  ----------  ----------
-- USE MAPPING DEPRECATE TO DEPRECATE CONCEPT_RELATIONSHIP
---------  ----------  ----------  ----------  ----------
 */

-- FIRST DIRECT MAPPINGS (Non-Standard Source to OMOP Standard)
-- Maps to
UPDATE vocab.concept_relationship
SET invalid_reason = 'U'
FROM (SELECT source_concept_id, to_deprecate
      FROM vocab.concept_relationship
               INNER JOIN temp.mapping_to_deprecate
                          ON concept_id_1 = source_concept_id
                              AND concept_id_2 = to_deprecate
      WHERE concept_id_1 > 2000000000
         OR concept_id_2 > 2000000000) foo
WHERE concept_id_1 = foo.source_concept_id
  AND concept_id_2 = foo.to_deprecate;

-- Maps to
UPDATE vocab.concept_relationship
SET valid_end_date = now()::DATE - INTERVAL '1 day'
FROM (SELECT source_concept_id, to_deprecate
      FROM vocab.concept_relationship
               INNER JOIN temp.mapping_to_deprecate
                          ON concept_id_1 = source_concept_id
                              AND concept_id_2 = to_deprecate
      WHERE concept_id_1 > 2000000000
         OR concept_id_2 > 2000000000) foo
WHERE concept_id_1 = foo.source_concept_id
  AND concept_id_2 = foo.to_deprecate;

--Mapped from
UPDATE vocab.concept_relationship
SET invalid_reason = 'U'
FROM (SELECT source_concept_id, to_deprecate
      FROM vocab.concept_relationship
               INNER JOIN temp.mapping_to_deprecate
                          ON concept_id_1 = to_deprecate
                              AND concept_id_2 = source_concept_id
      WHERE concept_id_1 > 2000000000
         OR concept_id_2 > 2000000000) foo
WHERE concept_id_1 = foo.to_deprecate
  AND concept_id_2 = foo.source_concept_id;

--Mapped from
UPDATE vocab.concept_relationship
SET valid_end_date = now()::DATE - INTERVAL '1 day'
FROM (SELECT source_concept_id, to_deprecate
      FROM vocab.concept_relationship
               INNER JOIN temp.mapping_to_deprecate
                          ON concept_id_1 = to_deprecate
                              AND concept_id_2 = source_concept_id
      WHERE concept_id_1 > 2000000000
         OR concept_id_2 > 2000000000) foo
WHERE concept_id_1 = foo.to_deprecate
  AND concept_id_2 = foo.source_concept_id;

/*
---------  ----------  ----------  ----------  ----------
-- USE MAPPING DEPRECATE TO DEPRECATE SOURCE_TO_CONCEPT_MAP
---------  ----------  ----------  ----------  ----------
 */

-- S2C DEPRECATE (Non-Standard Source to OMOP Standard)
UPDATE vocab.source_to_concept_map
SET invalid_reason = 'U'
FROM (SELECT md.source_concept_id, md.to_deprecate
      FROM vocab.source_to_concept_map cm
               INNER JOIN temp.mapping_to_deprecate md
                          ON cm.source_concept_id = md.source_concept_id
                              AND cm.target_concept_id = md.to_deprecate) foo
WHERE vocab.source_to_concept_map.source_concept_id = foo.source_concept_id
  AND vocab.source_to_concept_map.target_concept_id = foo.to_deprecate;

UPDATE vocab.source_to_concept_map
SET valid_end_date = now()::DATE - INTERVAL '1 day'
FROM (SELECT md.source_concept_id, md.to_deprecate
      FROM vocab.source_to_concept_map cm
               INNER JOIN temp.mapping_to_deprecate md
                          ON cm.source_concept_id = md.source_concept_id
                              AND cm.target_concept_id = md.to_deprecate) foo
WHERE vocab.source_to_concept_map.source_concept_id = foo.source_concept_id
  AND vocab.source_to_concept_map.target_concept_id = foo.to_deprecate;


/*
---------  ----------  ----------  ----------  ----------
-- USE MAPPING UPDATE TO UPDATE CONCEPT_RELATIONSHIP
---------  ----------  ----------  ----------  ----------
 */
-- Maps to
INSERT INTO vocab.concept_relationship(concept_id_1,
                                       concept_id_2,
                                       relationship_id,
                                       valid_start_date,
                                       valid_end_date,
                                       invalid_reason)
SELECT source_concept_id,
       to_update,
       'Maps to',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.mapping_to_update;

-- Mapped from
INSERT INTO vocab.concept_relationship(concept_id_1,
                                       concept_id_2,
                                       relationship_id,
                                       valid_start_date,
                                       valid_end_date,
                                       invalid_reason)
SELECT to_update,
       source_concept_id,
       'Mapped from',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.mapping_to_update;

/*
---------  ----------  ----------  ----------  ----------
-- USE MAPPING UPDATE TO UPDATE S2C
---------  ----------  ----------  ----------  ----------
 */

DROP TABLE IF EXISTS temp.s2c_special_update;

CREATE TABLE temp.s2c_special_update AS
SELECT *
FROM temp.mapping_to_update;

DELETE
FROM temp.s2c_special_update a USING (SELECT c.to_update, c.source_concept_id
                                      FROM temp.mapping_to_update c
                                               INNER JOIN vocab.source_to_concept_map d
                                                          ON c.source_concept_id = d.source_concept_id AND
                                                             c.to_update = d.target_concept_id) b
WHERE a.to_update = b.to_update
  AND a.source_concept_id = b.source_concept_id;

INSERT INTO vocab.source_to_concept_map(source_code,
                                        source_concept_id,
                                        source_vocabulary_id,
                                        source_code_description,
                                        target_concept_id,
                                        target_vocabulary_id,
                                        valid_start_date,
                                        valid_end_date,
                                        invalid_reason)
SELECT co.concept_code,
       mu.source_concept_id,
       co.vocabulary_id,
       co.concept_name,
       mu.to_update,
       co2.vocabulary_id,
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.s2c_special_update mu
         LEFT JOIN vocab.concept co ON mu.source_concept_id = co.concept_id
         LEFT JOIN vocab.concept co2 ON mu.to_update = co2.concept_id;


UPDATE vocab.vocabulary 
SET vocabulary_version = REPLACE(CONCAT('B2AI_', now()::timestamp::text), ' ', '_')
WHERE vocabulary_id = 'None';

INSERT INTO vocab.concept_synonym (concept_id,
                                     concept_synonym_name,
                                     language_concept_id)
SELECT concept_id,
       concept_synonym_name,
       language_concept_id
FROM vocab.concept_syn_staging;

INSERT INTO vocab.mapping_metadata
SELECT * FROM vocab.mapping_metadata_staging;

UPDATE vocab.vocabulary
SET vocabulary_version = now()::date
WHERE vocabulary_id = 'B2AI';

UPDATE vocab.concept
SET valid_start_date = now()::date
WHERE concept_id = 2147483647;

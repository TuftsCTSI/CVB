/*
---------  ----------  ----------  ----------  ----------
CREATE CONCEPT STAGING TABLE FOR NEW NON-STANDARD CONCEPTS (GENERAL MAPPINGS)
---------  ----------  ----------  ----------  ----------
 */

DROP TABLE IF EXISTS vocab.concept_ns_staging;

CREATE TABLE vocab.concept_ns_staging AS (SELECT *
                                          FROM vocab.concept
                                          where concept_id > 2000000000
                                            and standard_concept = 'S'
                                          LIMIT 0);

ALTER TABLE vocab.concept_ns_staging
    ADD COLUMN target_concept_id INTEGER NULL;

ALTER TABLE vocab.concept_ns_staging
    ADD COLUMN synonym text NULL;

ALTER TABLE vocab.concept_ns_staging
    ADD COLUMN predicate_id text NULL;

INSERT INTO vocab.concept_ns_staging (concept_id,
                                      concept_name,
                                      domain_id,
                                      vocabulary_id,
                                      concept_class_id,
                                      standard_concept,
                                      concept_code,
                                      valid_start_date,
                                      valid_end_date,
                                      invalid_reason,
                                      target_concept_id,
                                      synonym,
                                      predicate_id)
SELECT row_number() OVER (ORDER BY source_concept_code) + (SELECT COALESCE(max(concept_id),2000000000) FROM vocab.concept WHERE concept_id < 2147000000 AND concept_id > 2000000000) AS concept_id,
       LEFT(cc.source_description, 255),
       (CASE
            WHEN cd.domain_id IS NOT NULL THEN cd.domain_id
            WHEN cd.domain_id IS NULL THEN 'Metadata' END),
       'B2AI',
       (CASE
            WHEN cd.concept_class_id IS NOT NULL THEN cd.concept_class_id
            WHEN cd.concept_class_id IS NULL THEN 'B2AI-SRC' END),
       NULL,
       UPPER(cc.source_concept_code),
       now()::date,
       '2099-12-31'::date,
       NULL,
       target_concept_id,
       NULLIF(cc.source_description_synonym, ''),
       predicate_id
FROM temp.concept_check_ns cc
         LEFT JOIN vocab.concept cd ON cc.target_concept_id = cd.concept_id;



/*
---------  ----------  ----------  ----------  ----------
CREATE CONCEPT RELATIONSHIP STAGING TABLE FOR NEW NON-STANDARD CONCEPTS (GENERAL MAPPINGS)
---------  ----------  ----------  ----------  ----------
 */

DROP TABLE IF EXISTS vocab.concept_rel_ns_staging;

CREATE TABLE vocab.concept_rel_ns_staging AS (SELECT *
                                              FROM vocab.concept_relationship
                                              where concept_id_1 > 2000000000
                                              LIMIT 0);


INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT b.concept_id,
       a.target_concept_id,
       'Maps to',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) =  'skos:exactmatch';


INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT a.target_concept_id,
       b.concept_id,
       'Mapped from',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) =  'skos:exactmatch';

INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT b.concept_id,
       a.target_concept_id,
       'Is a',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
        ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:broadmatch'
AND TRIM(UPPER(a.source_concept_code)) IN
    (SELECT distinct TRIM(UPPER(source_concept_code)) FROM temp.source_to_update WHERE TRIM(LOWER(a.predicate_id)) = 'skos:exactmatch');


INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT a.target_concept_id,
       b.concept_id,
       'Subsumes',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:broadmatch'
AND TRIM(UPPER(a.source_concept_code)) IN
    (SELECT distinct TRIM(UPPER(source_concept_code)) FROM temp.source_to_update WHERE TRIM(LOWER(a.predicate_id)) = 'skos:exactmatch');

INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT b.concept_id,
       a.target_concept_id,
       'Subsumes',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:narrowmatch'
AND TRIM(UPPER(a.source_concept_code)) IN
    (SELECT distinct TRIM(UPPER(source_concept_code)) FROM temp.source_to_update WHERE TRIM(LOWER(a.predicate_id)) = 'skos:exactmatch');


INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT a.target_concept_id,
       b.concept_id,
       'Is a',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:narrowmatch'
AND TRIM(UPPER(a.source_concept_code)) IN
    (SELECT distinct TRIM(UPPER(source_concept_code)) FROM temp.source_to_update WHERE TRIM(LOWER(a.predicate_id)) = 'skos:exactmatch');

INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT b.concept_id,
       a.target_concept_id,
       'Has asso proc',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Procedure'
AND TRIM(UPPER(a.source_concept_code)) IN
    (SELECT distinct TRIM(UPPER(source_concept_code)) FROM temp.source_to_update WHERE TRIM(LOWER(a.predicate_id)) = 'skos:exactmatch');


INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT a.target_concept_id,
       b.concept_id,
       'Asso proc of',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Procedure'
AND TRIM(UPPER(a.source_concept_code)) IN
    (SELECT distinct TRIM(UPPER(source_concept_code)) FROM temp.source_to_update WHERE TRIM(LOWER(a.predicate_id)) = 'skos:exactmatch');

INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT b.concept_id,
       a.target_concept_id,
       'Has asso finding',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Condition'
AND TRIM(UPPER(a.source_concept_code)) IN
    (SELECT distinct TRIM(UPPER(source_concept_code)) FROM temp.source_to_update WHERE TRIM(LOWER(a.predicate_id)) = 'skos:exactmatch');


INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT a.target_concept_id,
       b.concept_id,
       'Asso finding of',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Condition'
AND TRIM(UPPER(a.source_concept_code)) IN
    (SELECT distinct TRIM(UPPER(source_concept_code)) FROM temp.source_to_update WHERE TRIM(LOWER(a.predicate_id)) = 'skos:exactmatch');

INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT b.concept_id,
       a.target_concept_id,
       'Has measurement',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Measurement'
AND TRIM(UPPER(a.source_concept_code)) IN
    (SELECT distinct TRIM(UPPER(source_concept_code)) FROM temp.source_to_update WHERE TRIM(LOWER(a.predicate_id)) = 'skos:exactmatch');



INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT a.target_concept_id,
       b.concept_id,
       'Relat context of',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Observation'
AND TRIM(UPPER(a.source_concept_code)) IN
    (SELECT distinct TRIM(UPPER(source_concept_code)) FROM temp.source_to_update WHERE TRIM(LOWER(a.predicate_id)) = 'skos:exactmatch');

INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT b.concept_id,
       a.target_concept_id,
       'Has relat context',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Observation'
AND TRIM(UPPER(a.source_concept_code)) IN
    (SELECT distinct TRIM(UPPER(source_concept_code)) FROM temp.source_to_update WHERE TRIM(LOWER(a.predicate_id)) = 'skos:exactmatch');



INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT a.target_concept_id,
       b.concept_id,
       'Measurement of',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw a
    INNER JOIN vocab.concept_ns_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Measurement'
AND TRIM(UPPER(a.source_concept_code)) IN
    (SELECT distinct TRIM(UPPER(source_concept_code)) FROM temp.source_to_update WHERE TRIM(LOWER(a.predicate_id)) = 'skos:exactmatch');


-- Non-standard to standard map

INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT b.concept_id,
       a.concept_id,
       'Maps to',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM vocab.concept_s_staging a
INNER JOIN vocab.concept_ns_staging b
ON a.concept_code = b.concept_code;

INSERT INTO vocab.concept_rel_ns_staging (concept_id_1,
                                          concept_id_2,
                                          relationship_id,
                                          valid_start_date,
                                          valid_end_date,
                                          invalid_reason)
SELECT a.concept_id,
       b.concept_id,
       'Mapped from',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM vocab.concept_s_staging a
INNER JOIN vocab.concept_ns_staging b
ON a.concept_code = b.concept_code;


DELETE
FROM vocab.concept_rel_ns_staging a USING (
    SELECT MIN(ctid) as ctid, concept_id_1, array_agg(concept_id_2), array_agg(relationship_id)
    FROM vocab.concept_rel_ns_staging
    GROUP BY concept_id_1
    HAVING COUNT(*) > 1
) b
WHERE a.concept_id_1 = b.concept_id_1
  AND a.concept_id_2 = 0;

DELETE
FROM vocab.concept_rel_ns_staging a USING (
    SELECT MIN(ctid) as ctid, concept_id_2, array_agg(concept_id_1), array_agg(relationship_id)
    FROM vocab.concept_rel_ns_staging
    GROUP BY concept_id_2
    HAVING COUNT(*) > 1
) b
WHERE a.concept_id_2 = b.concept_id_2
  AND a.concept_id_1 = 0;

-- REMOVE ANY RELATIONSHIPS THAT ALREADY EXIST IN RELATIONSHIP FOLLOWING STANDARD UPDATE
DELETE
FROM vocab.concept_rel_ns_staging a USING (
    SELECT concept_id_1, concept_id_2
    FROM vocab.concept_relationship
    WHERE concept_id_1 > 2000000000
       OR concept_id_2 > 2000000000
) b
WHERE a.concept_id_1 = b.concept_id_1
  AND a.concept_id_2 = b.concept_id_2;

DELETE
FROM vocab.concept_rel_ns_staging
WHERE concept_id_2 IN (SELECT concept_id from vocab.mapping_exceptions)
   OR concept_id_1 IN (SELECT concept_id from vocab.mapping_exceptions);



/*
 ---------  ----------  ----------  ----------  ----------
 SOURCE-TO-CONCEPT-MAP UPDATE FOR NON-STANDARD MAPPINGS
 ----------  ----------  ----------  ----------  ----------
 */


INSERT INTO vocab.s2c_map_staging(source_code,
                                  source_concept_id,
                                  source_vocabulary_id,
                                  source_code_description,
                                  target_concept_id,
                                  target_vocabulary_id,
                                  valid_start_date,
                                  valid_end_date,
                                  invalid_reason)
SELECT replace(trim(ns.source_concept_code), ' ', '_'),
       b.concept_id,
       'B2AI',
       b.concept_name,
       ns.target_concept_id,
       con.vocabulary_id,
       now()::date,
       '2099-12-31'::date,
       NULL
FROM temp.concept_check_ns_raw ns
    INNER JOIN vocab.concept_ns_staging b
        ON UPPER(TRIM(ns.source_concept_code)) = UPPER(TRIM(b.concept_code))
    INNER JOIN vocab.concept con
        ON ns.target_concept_id = con.concept_id
WHERE con.standard_concept = 'S'
      AND b.concept_id IS NOT NULL;

INSERT INTO vocab.s2c_map_staging(source_code,
                                  source_concept_id,
                                  source_vocabulary_id,
                                  source_code_description,
                                  target_concept_id,
                                  target_vocabulary_id,
                                  valid_start_date,
                                  valid_end_date,
                                  invalid_reason)
SELECT LEFT(replace(trim(a.concept_code), ' ', '_'), 50),
       b.concept_id,
       'B2AI',
       replace(a.concept_name, '''', ''),
       a.concept_id,
       'B2AI',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM vocab.concept_s_staging a
INNER JOIN vocab.concept_ns_staging b
ON a.concept_code = b.concept_code;


DELETE
FROM vocab.s2c_map_staging a USING (
    SELECT source_concept_id,
           target_concept_id
    FROM vocab.source_to_concept_map) b
WHERE a.source_concept_id = b.source_concept_id
  AND a.target_concept_id = b.target_concept_id;


-- DEDUPLICATE ON SOURCE TO TARGET
DELETE
FROM vocab.s2c_map_staging a USING (
    SELECT MIN(ctid) as ctid, source_concept_id, target_concept_id
    FROM vocab.s2c_map_staging
    GROUP BY source_concept_id, target_concept_id
    HAVING COUNT(*) > 1
) b
WHERE a.source_concept_id = b.source_concept_id
  AND a.target_concept_id = b.target_concept_id
  AND a.ctid <> b.ctid;

-- DEDUPLICATE ON SOURCE CODE TO TARGET
DELETE
FROM vocab.s2c_map_staging a USING (
    SELECT MIN(ctid) as ctid, source_code, target_concept_id
    FROM vocab.s2c_map_staging
    GROUP BY source_code, target_concept_id
    HAVING COUNT(*) > 1
) b
WHERE a.source_code = b.source_code
  AND a.target_concept_id = b.target_concept_id
  AND a.ctid <> b.ctid;

DELETE
FROM vocab.s2c_map_staging
WHERE target_concept_id IN (SELECT concept_id from vocab.mapping_exceptions);

DELETE FROM vocab.concept_rel_ns_staging
WHERE concept_id_1 IS NULL OR concept_id_2 IS NULL;


DROP TABLE IF EXISTS vocab.mapping_metadata_staging;

CREATE TABLE vocab.mapping_metadata_staging
(
    mapping_concept_id    INTEGER NOT NULL,
    mapping_concept_code  TEXT    NOT NULL,
    confidence            FLOAT   NOT NULL,
    predicate_id          TEXT    NOT NULL,
    mapping_justification TEXT    NOT NULL,
    mapping_provider      TEXT    NOT NULL,
    author_id             INTEGER NOT NULL,
    author_label          TEXT    NOT NULL,
    reviewer_id           INTEGER NULL,
    reviewer_label        TEXT NULL,
    mapping_tool          TEXT NULL,
    mapping_tool_version  TEXT NULL
);

INSERT INTO vocab.mapping_metadata_staging
SELECT row_number() OVER (ORDER BY source_concept_code) + (SELECT count(*) FROM vocab.mapping_metadata) AS mapping_concept_id,
       CONCAT(source_concept_code, '|| - ||', 'B2AI', '|| - ||', con.concept_code, '|| - ||', con.vocabulary_id) AS mapping_concept_code,
       COALESCE(confidence, 0),
       predicate_id,
       'sempav:manualMappingCuration',
       'https://docs.google.com/spreadsheets/d/1EH61Y1xuNxei6CT_VcU0AeYY88Gk5aYExaF6THhzQ1U' AS mapping_provider,
       1,
       'Polina Talapova',
       COALESCE(rid.id, 0),
       reviewer_name,
       'Google Sheet Workflow',
       'v1.0'
FROM temp.source_to_update stu
    LEFT JOIN vocab.concept con
        ON con.concept_id = stu.target_concept_id
    LEFT JOIN vocab.review_ids rid
        ON trim(lower(stu.reviewer_name)) = trim(lower(rid.name))
WHERE CONCAT(source_concept_code, '|| - ||', 'B2AI', '|| - ||', con.concept_code, '|| - ||', con.vocabulary_id)
          NOT IN (SELECT mapping_concept_code FROM vocab.mapping_metadata)
;




INSERT INTO temp.vocab_logger(log_desc, log_count)
SELECT 'Smallest Non-Standard Concept Id Assigned in Update:',
       (SELECT COALESCE(min(concept_id)::text, 'NONE') FROM vocab.concept_ns_staging);

INSERT INTO temp.vocab_logger(log_desc, log_count)
SELECT 'Largest Non-Standard Concept Id Assigned in Update:',
       (SELECT COALESCE(max(concept_id)::text, 'NONE') FROM vocab.concept_ns_staging);

INSERT INTO temp.vocab_logger(log_desc, log_count)
SELECT 'Number of Non-Standard Concept Ids to Assign:',
       (SELECT count(*) FROM vocab.concept_ns_staging);

INSERT INTO temp.vocab_logger(log_desc, log_count)
SELECT 'Number of Mapping Metadata Entries to Create:',
       (SELECT count(*) FROM vocab.mapping_metadata_staging);

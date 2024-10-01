-- INSERT NEW STANDARD CONCEPTS INTO CONCEPT AND ASSIGN NEW STANDARD CUSTOM CONCEPT IDS USING MASTER SEQUENCE

DROP TABLE IF EXISTS vocab.concept_s_staging;

CREATE TABLE vocab.concept_s_staging AS (SELECT *
                                         FROM vocab.concept
                                         where concept_id > 2000000000
                                           and standard_concept = 'S'
                                         LIMIT 0);

ALTER TABLE vocab.concept_s_staging
    ADD COLUMN source_concept_id integer;

ALTER TABLE vocab.concept_s_staging
    ADD COLUMN target_concept_id integer;

ALTER TABLE vocab.concept_s_staging
    ADD COLUMN synonym text;

ALTER TABLE vocab.concept_s_staging
    ADD COLUMN predicate_id text;

INSERT INTO vocab.concept_s_staging (concept_id,
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
                                     source_concept_id,
                                     synonym,
                                     predicate_id)
SELECT nextval('vocab.master_id_assignment'),
       cc.source_description,
       (CASE
            WHEN cd.domain_id IS NOT NULL THEN cd.domain_id
            WHEN cd.domain_id IS NULL THEN 'Metadata' END),
       'B2AI',
       (CASE
            WHEN cd.concept_class_id IS NOT NULL THEN cd.concept_class_id
            WHEN cd.concept_class_id IS NULL THEN 'B2AI-SRC' END),
       'S',
       UPPER(cc.source_concept_code),
       now()::date,
       '2099-12-31'::date,
       NULL,
       cc.target_concept_id,
       cc.source_concept_id,
       NULLIF(cc.source_description_synonym, ''),
       predicate_id
FROM temp.concept_check_s cc
         LEFT JOIN vocab.concept cd ON target_concept_id::integer = cd.concept_id;


DROP TABLE IF EXISTS vocab.concept_rel_s_staging;
DROP TABLE IF EXISTS vocab.concept_rel_s_staging_survey;
DROP TABLE IF EXISTS temp.concept_rel_s_raw;

CREATE TABLE vocab.concept_rel_s_staging AS (SELECT *
                                             FROM vocab.concept_relationship
                                             where concept_id_1 > 2000000000
                                             LIMIT 1);

DELETE
FROM vocab.concept_rel_s_staging
WHERE concept_id_1 IS NOT NULL;

CREATE TABLE vocab.concept_rel_s_staging_survey AS (SELECT *
                                                    FROM vocab.concept_rel_s_staging);

CREATE TABLE temp.concept_rel_s_raw AS (SELECT *
                                        FROM vocab.concept_rel_s_staging);


INSERT INTO vocab.concept_rel_s_staging (concept_id_1,
                                         concept_id_2,
                                         relationship_id,
                                         valid_start_date,
                                         valid_end_date,
                                         invalid_reason)
SELECT concept_id,
       concept_id,
       'Maps to',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM vocab.concept_s_staging;



INSERT INTO vocab.concept_rel_s_staging (concept_id_1,
                                         concept_id_2,
                                         relationship_id,
                                         valid_start_date,
                                         valid_end_date,
                                         invalid_reason)
SELECT concept_id,
       concept_id,
       'Mapped from',
       now()::date,
       '2099-12-31'::date,
       NULL
FROM vocab.concept_s_staging;


INSERT INTO vocab.concept_rel_s_staging (concept_id_1,
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
    INNER JOIN vocab.concept_s_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:broadmatch';


INSERT INTO vocab.concept_rel_s_staging (concept_id_1,
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
    INNER JOIN vocab.concept_s_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:broadmatch';

INSERT INTO vocab.concept_rel_s_staging (concept_id_1,
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
    INNER JOIN vocab.concept_s_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:narrowmatch';


INSERT INTO vocab.concept_rel_s_staging (concept_id_1,
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
    INNER JOIN vocab.concept_s_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:narrowmatch';

INSERT INTO vocab.concept_rel_s_staging (concept_id_1,
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
    INNER JOIN vocab.concept_s_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Procedure';


INSERT INTO vocab.concept_rel_s_staging (concept_id_1,
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
    INNER JOIN vocab.concept_s_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Procedure';

INSERT INTO vocab.concept_rel_s_staging (concept_id_1,
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
    INNER JOIN vocab.concept_s_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Condition';


INSERT INTO vocab.concept_rel_s_staging (concept_id_1,
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
    INNER JOIN vocab.concept_s_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Condition';

INSERT INTO vocab.concept_rel_s_staging (concept_id_1,
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
    INNER JOIN vocab.concept_s_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Measurement';


INSERT INTO vocab.concept_rel_s_staging (concept_id_1,
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
    INNER JOIN vocab.concept_s_staging b
    ON UPPER(TRIM(a.source_concept_code)) = UPPER(TRIM(b.concept_code))
WHERE trim(lower(a.predicate_id)) = 'skos:relatedmatch'
AND a.target_domain_id = 'Measurement';



-- REMOVE ANY POTENTIAL RELATIONSHIPS THAT ALREADY EXIST (e.g. FROM CONCEPT REFERENCES)
DELETE
FROM vocab.concept_rel_s_staging a USING (
    SELECT concept_id_1, concept_id_2
    FROM vocab.concept_relationship
    WHERE concept_id_1 > 2000000000
       OR concept_id_2 > 2000000000
) b
WHERE a.concept_id_1 = b.concept_id_1
  AND a.concept_id_2 = b.concept_id_2;

/*
 ---------  ----------  ----------  ----------  ----------
 CONCEPT ANCESTOR UPDATE FOR STANDARD CUSTOMS
 ----------  ----------  ----------  ----------  ----------
 */
DROP TABLE IF EXISTS vocab.concept_anc_s_staging;

CREATE TABLE vocab.concept_anc_s_staging AS (SELECT *
                                             from vocab.concept_ancestor
                                             WHERE ancestor_concept_id > 2000000000
                                             LIMIT 1);

DELETE
FROM vocab.concept_anc_s_staging
WHERE ancestor_concept_id IS NOT NULL;

-- SELF-REFERENCE
INSERT INTO vocab.concept_anc_s_staging(ancestor_concept_id,
                                        descendant_concept_id,
                                        min_levels_of_separation,
                                        max_levels_of_separation)
SELECT concept_id,
       concept_id,
       0,
       0
FROM vocab.concept_s_staging;

WITH parent_hierarchy AS (
         SELECT css.concept_id,
                ca.ancestor_concept_id,
                ca.min_levels_of_separation,
                ca.max_levels_of_separation
         FROM vocab.concept_s_staging css
                  INNER JOIN vocab.concept_ancestor ca ON css.target_concept_id = ca.descendant_concept_id
         WHERE ancestor_concept_id != 0
           AND ancestor_concept_id < 2000000000
           AND lower(trim(css.predicate_id)) = 'skos:broadmatch'

     )
INSERT
INTO vocab.concept_anc_s_staging(ancestor_concept_id,
                                 descendant_concept_id,
                                 min_levels_of_separation,
                                 max_levels_of_separation)
SELECT ancestor_concept_id,
       concept_id,
       (min_levels_of_separation + 1),
       (max_levels_of_separation + 1)
FROM parent_hierarchy;

WITH children AS (
    SELECT concept_id,
           target_concept_id as child
    FROM vocab.concept_s_staging
    WHERE lower(trim(predicate_id)) = 'skos:narrowmatch'
)
INSERT
INTO vocab.concept_anc_s_staging(ancestor_concept_id,
                                 descendant_concept_id,
                                 min_levels_of_separation,
                                 max_levels_of_separation)
SELECT concept_id,
       child,
       1,
       1
FROM children;


/*
 ---------  ----------  ----------  ----------  ----------
 SOURCE-TO-CONCEPT-MAP UPDATE FOR STANDARD CUSTOMS
 ----------  ----------  ----------  ----------  ----------
 */
DROP TABLE IF EXISTS vocab.s2c_map_staging;

CREATE TABLE vocab.s2c_map_staging AS (SELECT *
                                       FROM vocab.source_to_concept_map
                                       LIMIT 0);


INSERT INTO temp.vocab_logger(log_desc, log_count)
SELECT 'Smallest Standard Custom Id Assigned in Update:',
       (SELECT COALESCE(min(concept_id)::text, 'NONE') FROM vocab.concept_s_staging);

INSERT INTO temp.vocab_logger(log_desc, log_count)
SELECT 'Largest Standard Custom Id Assigned in Update:',
       (SELECT COALESCE(max(concept_id)::text, 'NONE') FROM vocab.concept_s_staging);

INSERT INTO temp.vocab_logger(log_desc, log_count)
SELECT 'Number of Custom Concept Ids to Assign:',
       (SELECT count(*) FROM vocab.concept_s_staging);


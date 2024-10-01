
-- CHECK STANDARD CUSTOM CONCEPTS USING SUGGESTED NAME (WITHOUT REFERENCE)
DROP TABLE IF EXISTS temp.CONCEPT_CHECK_S;
DROP TABLE IF EXISTS temp.SRC_DESC_MATCH;
DROP TABLE IF EXISTS temp.CONCEPT_CHECK_S_RAW;
DROP TABLE IF EXISTS temp.CONCEPT_CHECK_NS_RAW;


CREATE TABLE temp.CONCEPT_CHECK_S AS
    (SELECT *
     FROM (SELECT * FROM temp.source_to_update sc
              LEFT JOIN (SELECT *
                         FROM vocab.CONCEPT
                         WHERE (concept_id > 2051500000 AND concept_id < 2052500000)
                           AND standard_concept = 'S') co
                        ON TRIM(UPPER(sc.source_concept_code)) = TRIM(UPPER(co.concept_code))) a
     WHERE a.source_concept_class_id != 'Suppl Concept'
     AND a.concept_name IS NULL);


-- TRACK ALL CUSTOM REQUESTS
CREATE TABLE temp.SRC_DESC_MATCH AS (
    SELECT *
    FROM temp.CONCEPT_CHECK_S
);

CREATE TABLE temp.CONCEPT_CHECK_S_RAW AS (
    SELECT *
    FROM temp.CONCEPT_CHECK_S
);

-- RETAIN ONLY UNIQUE SOURCE DESCRIPTIONS FOR STANDARD ID ASSIGNMENT
DELETE
FROM temp.CONCEPT_CHECK_S a USING (
    SELECT MIN(ctid) as ctid, source_description
    FROM temp.CONCEPT_CHECK_S
    GROUP BY source_description
    HAVING COUNT(*) > 1
) b
WHERE a.source_description = b.source_description
  AND a.ctid <> b.ctid;



-- REMOVE UNIQUE STANDARDS FROM SUGGESTED NAME DUPLICATES

DELETE
FROM temp.SRC_DESC_MATCH a USING (
    SELECT source_concept_id
    FROM temp.CONCEPT_CHECK_S
) b
WHERE a.source_concept_id = b.source_concept_id;

-- REMOVE ALL PREVIOUS MAPPINGS FROM SUGGESTED NAME DUPLICATES (ONLY INCLUDE THOSE THAT ARE NEW WITH DUPLICATED S N)

DELETE
FROM temp.SRC_DESC_MATCH a USING (
    SELECT concept_id
    FROM vocab.concept
    WHERE concept_id > 2000000000
) b
WHERE a.source_concept_id = b.concept_id;



-- CONCEPT_CHECK_S NOW REPRESENTS ANY STANDARD CUSTOM ROWS THAT DO NOT EXIST IN MASTER VOCAB VERSION

DROP TABLE IF EXISTS temp.CONCEPT_CHECK_NS;

CREATE TABLE temp.CONCEPT_CHECK_NS AS
    (SELECT *
     FROM temp.source_to_update sc
              LEFT JOIN (SELECT *
                         FROM vocab.CONCEPT
                         WHERE (concept_id > 2051500000 AND concept_id < 2052500000)
                           AND standard_concept IS NULL) co
                        ON TRIM(UPPER(sc.source_concept_code)) = TRIM(UPPER(co.concept_code)));

CREATE TABLE temp.concept_check_ns_raw AS
    SELECT * FROM temp.concept_check_ns;

DELETE
FROM temp.CONCEPT_CHECK_NS a USING (
    SELECT MIN(ctid) as ctid, source_description
    FROM temp.CONCEPT_CHECK_NS
    GROUP BY source_description
    HAVING COUNT(*) > 1
) b
WHERE a.source_description = b.source_description
  AND a.ctid <> b.ctid;

DELETE
FROM temp.CONCEPT_CHECK_NS
WHERE concept_name IS NOT NULL;

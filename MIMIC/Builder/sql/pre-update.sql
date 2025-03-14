-- PREP TABLES PRIOR TO INSERT
DELETE
FROM vocab.concept_ns_staging a USING (
    SELECT max(target_concept_id) as msc, concept_id
    FROM vocab.concept_ns_staging
    GROUP BY concept_id
    HAVING COUNT(*) > 1
) b
WHERE a.concept_id = b.concept_id
  AND a.target_concept_id != b.msc;

DELETE
FROM vocab.concept_ns_staging a USING (
    SELECT min(ctid) as ctid, concept_id
    FROM vocab.concept_ns_staging
    GROUP BY concept_id
    HAVING COUNT(*) > 1
) b
WHERE a.concept_id = b.concept_id
  AND a.ctid != b.ctid;

DELETE
FROM vocab.concept_rel_ns_staging a USING (
    SELECT min(ctid) as ctid, concept_id_1, concept_id_2
    FROM vocab.concept_rel_ns_staging
    GROUP BY concept_id_1, concept_id_2
    HAVING COUNT(*) > 1
) b
WHERE a.concept_id_1 = b.concept_id_1
  AND a.concept_id_2 = b.concept_id_2
  AND a.ctid != b.ctid;

DELETE
FROM vocab.concept_rel_s_staging a USING (
    SELECT min(ctid) as ctid, concept_id_1, concept_id_2
    FROM vocab.concept_rel_ns_staging
    GROUP BY concept_id_1, concept_id_2
    HAVING COUNT(*) > 1
) b
WHERE a.concept_id_1 = b.concept_id_1
  AND a.concept_id_2 = b.concept_id_2
  AND a.ctid != b.ctid;

DELETE
FROM vocab.concept_anc_s_staging a USING (
    SELECT min(ctid) as ctid, ancestor_concept_id, descendant_concept_id
    FROM vocab.concept_anc_s_staging
    GROUP BY ancestor_concept_id, descendant_concept_id
    HAVING COUNT(*) > 1
) b
WHERE a.ancestor_concept_id = b.ancestor_concept_id
  AND a.descendant_concept_id = b.descendant_concept_id
  AND a.ctid != b.ctid;

DELETE
FROM vocab.concept_rel_s_staging
WHERE concept_id_2 IN (SELECT concept_id from vocab.mapping_exceptions)
   OR concept_id_1 IN (SELECT concept_id from vocab.mapping_exceptions);



DELETE
FROM vocab.concept_rel_ns_staging
WHERE concept_id_2 IN (SELECT concept_id from vocab.mapping_exceptions)
   OR concept_id_1 IN (SELECT concept_id from vocab.mapping_exceptions);

DELETE
FROM vocab.concept_rel_ns_staging
WHERE concept_id_2 IS NULL
   OR concept_id_1 IS NULL;

DELETE
FROM temp.mapping_to_update a USING (SELECT * FROM vocab.concept_rel_ns_staging) b
WHERE a.source_concept_id = b.concept_id_1
  AND a.to_update = b.concept_id_2;

DELETE
FROM temp.mapping_to_update a USING (SELECT * FROM vocab.concept_rel_s_staging) b
WHERE a.source_concept_id = b.concept_id_1
  AND a.to_update = b.concept_id_2;


DROP TABLE IF EXISTS temp.mapping_diff;
DROP TABLE IF EXISTS temp.mapping_to_deprecate;
DROP TABLE IF EXISTS temp.mapping_to_update;

CREATE TABLE IF NOT EXISTS temp.mapping_diff
(
    source_concept_id     integer   NULL,
    target_difference_o2n integer[] NULL,
    target_difference_n2o integer[] NULL,
    old_targets           integer[] NULL,
    new_targets           integer[] NULL
);



WITH existing_uid_mapping AS (
    SELECT ss.source_concept_id          as concept_id,
           s2.concept_id_2 as old_target,
           sn.concept_id_2 as new_target
    FROM temp.source_to_update ss
             INNER JOIN vocab.concept_relationship s2
                        ON ss.source_concept_id = s2.concept_id_1
             INNER JOIN vocab.concept_rel_ns_staging sn
                        ON ss.source_concept_id = sn.concept_id_1
    WHERE s2.relationship_id = 'Maps to'
      AND s2.invalid_reason IS NULL
      AND sn.relationship_id = 'Maps to'
      AND ss.target_concept_id IS NOT NULL
),
     mapping_arrays AS (SELECT concept_id,
                               array_agg(old_target) as old_target_array,
                               array_agg(new_target) as new_target_array,
                               count(*)
                        FROM existing_uid_mapping
                        GROUP BY concept_id)
INSERT
INTO temp.mapping_diff
SELECT concept_id,
       array(select unnest(new_target_array) except select unnest(old_target_array)) as new_to_old,
       array(select unnest(old_target_array) except select unnest(new_target_array)) as old_to_new,
       old_target_array,
       new_target_array
FROM mapping_arrays;

DELETE
FROM temp.mapping_diff
WHERE target_difference_o2n = '{}'
  AND target_difference_n2o = '{}';

CREATE TABLE temp.mapping_to_deprecate AS (SELECT source_concept_id, unnest(target_difference_n2o) as to_deprecate
                                           FROM temp.mapping_diff
                                           WHERE target_difference_n2o != '{}');

CREATE TABLE temp.mapping_to_update AS (SELECT source_concept_id, unnest(target_difference_o2n) as to_update
                                        FROM temp.mapping_diff
                                        WHERE target_difference_o2n != '{}');




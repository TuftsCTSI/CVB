WITH all_mappings AS (
                         SELECT source_code_set,
                                source_code,
                                source_concept_id,
                                source_vocabulary_id,
                                source_domain AS source_domain_id,
                                source_code_set  AS source_concept_class_id,
                                source_description,
                                source_description_synonym   AS source_description_synonym,
                                now()::date valid_start_date,
                                relationship_id,
                                predicate_id,
                                confidence,
                                target_concept_id,
                                NULL AS target_concept_code,
                                target_concept_name,
                                target_vocabulary_id,
                                target_domain_id,
                                1 AS decision,
                                NULL::date AS review_date,
                                author_label AS author_name,
                                reviewer_label AS reviewer_name,
                                NULL AS reviewer_specialty,
                                reviewer_comments AS reviewer_comment,
                                NULL AS orcid_id,
                                NULL AS reviewer_affiliation_name,
                                'Completed' AS status,
                                NULL AS author_comment,
                                NULL AS change_required
                         FROM temp.mimic_mapping
                     )

INSERT
INTO temp.source_to_update   (
                                source_concept_code,
                                source_concept_id,
                                source_vocabulary_id,
                                source_domain_id,
                                source_concept_class_id,
                                source_description,
                                source_description_synonym,
                                valid_start,
                                relationship_id,
                                predicate_id,
                                confidence,
                                target_concept_id,
                                target_concept_code,
                                target_concept_name,
                                target_vocabulary_id,
                                target_domain_id,
                                decision,
                                review_date,
                                author_name,
                                reviewer_name,
                                reviewer_specialty,
                                reviewer_comment,
                                orcid_id,
                                reviewer_affiliation_name,
                                status,
                                author_comment,
                                change_required)
SELECT  LEFT(source_code, 50) AS source_concept_code, -- constrained by destination field length
        NULL::INTEGER AS source_concept_id,
        source_vocabulary_id,
        source_domain_id,
        source_concept_class_id,
        LEFT(source_description, 255), --  aligns with VARCHAR(255)
        LEFT(source_description_synonym, 1000),-- aligns with VARCHAR(1000) for concept_synonym_name
        valid_start_date,
        relationship_id,
        predicate_id,
        confidence::FLOAT,
        target_concept_id::INTEGER,
        target_concept_code,
        target_concept_name,
        target_vocabulary_id,
        INITCAP(target_domain_id),
        decision,
        review_date,
        author_name,
        reviewer_name,
        reviewer_specialty,
        reviewer_comment,
        orcid_id,
        reviewer_affiliation_name,
        status,
        author_comment,
        change_required
FROM all_mappings
WHERE NULLIF(TRIM(source_code), '') IS NOT NULL
AND NULLIF(TRIM(source_description), '') IS NOT NULL;

SELECT COUNT(*)
FROM temp.source_to_update;

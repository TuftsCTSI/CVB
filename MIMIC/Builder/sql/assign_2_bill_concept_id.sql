-- creating a registry table for 2-bill concept IDs
CREATE TABLE IF NOT EXISTS temp.concept_id_registry (
    source_code TEXT NOT NULL,
    source_vocabulary_id TEXT NOT NULL,
    concept_id INTEGER PRIMARY KEY,
    UNIQUE(source_code, source_vocabulary_id)
);

-- populate temp.concept_id_registry after the fisrt vocabulary run
INSERT INTO temp.concept_id_registry (source_code, source_vocabulary_id, concept_id)
SELECT DISTINCT
    source_code,
    source_vocabulary_id,
    concept_id
FROM concept_delta cd
WHERE NOT EXISTS (
    SELECT 1
    FROM temp.concept_id_registry r
    WHERE r.source_code = cd.source_code
      AND r.source_vocabulary_id = cd.source_vocabulary_id
);

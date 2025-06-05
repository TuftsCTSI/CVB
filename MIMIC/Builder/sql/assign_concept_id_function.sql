CREATE OR REPLACE FUNCTION temp.assign_concept_id(
    p_source_code TEXT,
    p_source_vocabulary_id TEXT
) RETURNS INTEGER AS $$
DECLARE
    existing_id INTEGER;
BEGIN
    -- looking for an existing concept_id
    SELECT concept_id INTO existing_id
    FROM temp.concept_id_registry
    WHERE source_code = p_source_code
      AND source_vocabulary_id = p_source_vocabulary_id;

    IF existing_id IS NOT NULL THEN
        RETURN existing_id;
    ELSE
        -- generate a new concept_id
        existing_id := nextval('temp.master_id_assignment');

        -- insert into the registry
        INSERT INTO temp.concept_id_registry (
            source_code, source_vocabulary_id, concept_id
        ) VALUES (
            p_source_code, p_source_vocabulary_id, existing_id
        );

        RETURN existing_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

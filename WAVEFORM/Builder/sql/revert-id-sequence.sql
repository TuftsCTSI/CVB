DROP SEQUENCE IF EXISTS vocab.master_id_assignment;

-- Note - I usually give a small buffer (100 uids or so) for admin/special custom ids
CREATE SEQUENCE vocab.master_id_assignment
    INCREMENT -1
    MINVALUE 2082000000
    MAXVALUE 2082500000
    START 2082499885
    OWNED BY vocab.concept.concept_id;

SELECT setval('vocab.master_id_assignment',
              (SELECT COALESCE(min(concept_id), 2082499886)
               FROM vocab.concept
               WHERE concept_id > 2082000000 AND concept_id < 2082500000
                 AND standard_concept = 'S'));

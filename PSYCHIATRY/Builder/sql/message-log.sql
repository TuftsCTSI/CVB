DROP TABLE IF EXISTS temp.UPDATE_LOG;

CREATE TABLE temp.UPDATE_LOG
(
    message text NULL,
    count   text NULL
);

INSERT INTO temp.UPDATE_LOG
SELECT 'Standard custom concepts to insert into CONCEPT:',
       (SELECT count(*) FROM vocab.concept_s_staging);

INSERT INTO temp.UPDATE_LOG
SELECT 'Non-standard concept ids to insert into CONCEPT:',
       (SELECT count(*) FROM vocab.concept_ns_staging);

INSERT INTO temp.UPDATE_LOG
SELECT 'Standard relationships to insert into CONCEPT RELATIONSHIP:',
       (SELECT count(*) FROM vocab.concept_rel_s_staging);

INSERT INTO temp.UPDATE_LOG
SELECT 'Non-standard relationships to insert into CONCEPT RELATIONSHIP:',
       (SELECT count(*) FROM vocab.concept_rel_ns_staging);

INSERT INTO temp.UPDATE_LOG
SELECT 'Standard hierarchy rows to insert into CONCEPT ANCESTOR:',
       (SELECT count(*) FROM vocab.concept_anc_s_staging);

INSERT INTO temp.UPDATE_LOG
SELECT 'Synonym rows to insert into CONCEPT SYNONYM:',
       (SELECT count(*) FROM vocab.concept_syn_staging);

INSERT INTO temp.UPDATE_LOG
SELECT 'Mapping relationships (S & NS) to insert into SOURCE TO CONCEPT MAP:',
       (SELECT count(*) FROM vocab.s2c_map_staging);

INSERT INTO temp.UPDATE_LOG
SELECT 'Mappings of existing concepts that require an update:',
       (SELECT count(*) FROM temp.mapping_to_update);

INSERT INTO temp.UPDATE_LOG
SELECT 'Existing mappings that require deprecation:',
       (SELECT count(*) FROM temp.mapping_to_deprecate);


INSERT INTO temp.UPDATE_LOG (SELECT * FROM temp.vocab_logger);

SELECT *
FROM temp.UPDATE_LOG;

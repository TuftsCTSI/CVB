DROP TABLE IF EXISTS temp.concept_delta;
DROP TABLE IF EXISTS temp.concept_relationship_delta;
DROP TABLE IF EXISTS temp.concept_ancestor_delta;
DROP TABLE IF EXISTS temp.concept_synonym_delta;
DROP TABLE IF EXISTS temp.vocabulary_delta;
DROP TABLE IF EXISTS temp.concept_class_delta;
DROP TABLE IF EXISTS temp.source_to_concept_map_delta;
DROP TABLE IF EXISTS temp.mapping_metadata_delta;


CREATE TABLE temp.concept_delta AS (SELECT * FROM vocab.concept WHERE vocabulary_id IN ('OMOP SDOH', 'OMOP Exposome', 'OMOP GIS') ORDER BY concept_id);

CREATE TABLE temp.concept_relationship_delta AS (SELECT * FROM vocab.concept_relationship WHERE (concept_id_1 > 2051500000 AND concept_id_1 < 2052500000) OR (concept_id_2 > 2051500000 AND concept_id_2 < 2052500000) ORDER BY concept_id_1, concept_id_2);

CREATE TABLE temp.concept_ancestor_delta AS (SELECT * FROM vocab.concept_ancestor WHERE (ancestor_concept_id > 2051500000 AND ancestor_concept_id < 2052500000) OR (descendant_concept_id > 2051500000 AND descendant_concept_id < 2052500000) ORDER BY ancestor_concept_id, descendant_concept_id);

CREATE TABLE temp.concept_synonym_delta AS (SELECT * FROM vocab.concept_synonym WHERE (concept_id > 2051500000 AND concept_id < 2052500000) ORDER BY concept_id);

CREATE TABLE temp.domain_delta AS (SELECT * FROM vocab.domain WHERE (domain_concept_id > 2051500000 AND domain_concept_id < 2052500000) ORDER BY domain_concept_id);

CREATE TABLE temp.relationship_delta AS (SELECT * FROM vocab.relationship WHERE (relationship_concept_id > 2051500000 AND relationship_concept_id < 2052500000) ORDER BY relationship_concept_id);

CREATE TABLE temp.vocabulary_delta AS (SELECT * FROM vocab.vocabulary WHERE (vocabulary_concept_id > 2051500000 AND vocabulary_concept_id < 2052500000) OR vocabulary_id = 'None' ORDER BY vocabulary_id);

CREATE TABLE temp.concept_class_delta AS (SELECT * FROM vocab.concept_class WHERE concept_class_concept_id = 46233639 AND concept_class_id != 'Suppl Concept');

CREATE TABLE temp.source_to_concept_map_delta AS (SELECT * FROM vocab.source_to_concept_map ORDER BY source_concept_id, target_concept_id);

CREATE TABLE temp.mapping_metadata_delta AS (SELECT * FROM vocab.mapping_metadata ORDER BY mapping_concept_code);

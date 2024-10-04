CREATE SCHEMA if NOT EXISTS temp;
DROP TABLE if EXISTS temp.source_to_update;
DROP TABLE if EXISTS temp.vocab_logger;
DROP TABLE if EXISTS temp.gis_source;
DROP TABLE if EXISTS temp.gis_mapping;
DROP TABLE if EXISTS temp.gis_hierarchy;

CREATE TABLE temp.gis_source
(
    source_code                TEXT,
    source_concept_id          INTEGER,
    source_vocabulary_id       TEXT,
    source_domain_id           TEXT,
    source_concept_class_id    TEXT,
    source_description         TEXT,
    source_description_synonym TEXT,
    valid_start_date           DATE,
    decision                   INTEGER,
    review_date                DATE,
    reviewer_name              TEXT,
    reviewer_specialty         TEXT,
    reviewer_comment           TEXT,
    orcid_id                   TEXT,
    reviewer_affiliation_name  TEXT,
    status                     TEXT,
    author_comment             TEXT,
    change_required            TEXT
);

CREATE TABLE temp.gis_mapping
(
    source_code               TEXT,
    source_concept_id         INTEGER,
    source_vocabulary_id      TEXT,
    source_description        TEXT,
    relationship_id           TEXT,
    predicate_id              TEXT,
    confidence                FLOAT8,
    target_concept_id         INTEGER,
    target_concept_name       TEXT,
    target_vocabulary_id      TEXT,
    target_domain_id          TEXT,
    decision                  INTEGER,
    review_date               DATE,
    reviewer_name             TEXT,
    reviewer_specialty        TEXT,
    reviewer_comment          TEXT,
    orcid_id                  TEXT,
    reviewer_affiliation_name TEXT,
    status                    TEXT,
    author_comment            TEXT,
    change_required           TEXT
);

CREATE TABLE temp.gis_hierarchy
(
    source_code               TEXT,
    source_concept_id         INTEGER,
    source_vocabulary_id      TEXT,
    source_description        TEXT,
    relationship_id           TEXT,
    predicate_id              TEXT,
    confidence                FLOAT8,
    target_concept_id         INTEGER,
    target_concept_code       TEXT,
    target_concept_name       TEXT,
    target_vocabulary_id      TEXT,
    target_domain_id          TEXT,
    decision                  INTEGER,
    review_date               DATE,
    reviewer_name             TEXT,
    reviewer_specialty        TEXT,
    reviewer_comment          TEXT,
    orcid_id                  TEXT,
    reviewer_affiliation_name TEXT,
    status                    TEXT,
    author_comment            TEXT,
    change_required           TEXT
);



CREATE TABLE temp.source_to_update
(
    source_concept_code                TEXT,
    source_concept_id          INTEGER,
    source_vocabulary_id       TEXT,
    source_domain_id           TEXT,
    source_concept_class_id    TEXT,
    source_description         TEXT,
    source_description_synonym TEXT,
    valid_start_date           DATE,
    relationship_id            TEXT,
    predicate_id               TEXT,
    confidence                 FLOAT8,
    target_concept_id          INTEGER,
    target_concept_code        TEXT,
    target_concept_name        TEXT,
    target_vocabulary_id       TEXT,
    target_domain_id           TEXT,
    decision                   INTEGER,
    review_date                DATE,
    reviewer_name              TEXT,
    reviewer_specialty         TEXT,
    reviewer_comment           TEXT,
    orcid_id                   TEXT,
    reviewer_affiliation_name  TEXT,
    status                     TEXT,
    author_comment             TEXT,
    change_required            TEXT
);

CREATE TABLE temp.vocab_logger
(
    log_desc  TEXT NULL,
    log_count TEXT NULL
);

-- CREATE TABLE vocab.mapping_metadata
-- (
--     mapping_concept_id    INTEGER NOT NULL,
--     mapping_concept_code  TEXT    NOT NULL,
--     confidence            FLOAT   NOT NULL,
--     predicate_id          TEXT    NOT NULL,
--     mapping_justification TEXT    NOT NULL,
--     mapping_provider      TEXT    NOT NULL,
--     author_id             INTEGER NOT NULL,
--     author_label          TEXT    NOT NULL,
--     reviewer_id           INTEGER NULL,
--     reviewer_label        TEXT NULL,
--     mapping_tool          TEXT NULL,
--     mapping_tool_version  TEXT NULL
-- );

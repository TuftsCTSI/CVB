CREATE SCHEMA if NOT EXISTS temp;
DROP TABLE if EXISTS temp.source_to_update;
DROP TABLE if EXISTS temp.vocab_logger;
DROP TABLE if EXISTS temp.mimic_mapping;

CREATE TABLE temp.mimic_mapping
(
    source_code_set       TEXT,
    source_category       TEXT,
    source_domain         TEXT,
    source_code           TEXT,
    source_concept_id     INTEGER,
    source_vocabulary_id  TEXT,
    source_description    TEXT,
    source_description_synonym  TEXT,
    relationship_id       TEXT,
    predicate_id          TEXT,
    confidence            TEXT,
    target_concept_id     INTEGER,
    target_concept_name   TEXT,
    target_vocabulary_id  TEXT,
    target_domain_id      TEXT,
    author_label          TEXT,
    reviewer_label        TEXT,
    reviewer_comments     TEXT,
    mapping_justification TEXT,
    mapping_tool          TEXT,
    mapping_tool_version  TEXT
);

CREATE TABLE temp.source_to_update
(
    source_concept_code        TEXT,
    source_concept_id          INTEGER,
    source_vocabulary_id       TEXT,
    source_domain_id           TEXT,
    source_concept_class_id    TEXT,
    source_description         TEXT,
    source_description_synonym TEXT,
    valid_start                DATE,
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
    author_name                TEXT,
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


CREATE TABLE IF NOT EXISTS vocab.mapping_exceptions
(
    concept_id
    integer
);

CREATE TABLE IF NOT EXISTS vocab.review_ids
(
    name
    text,
    id
    integer
);

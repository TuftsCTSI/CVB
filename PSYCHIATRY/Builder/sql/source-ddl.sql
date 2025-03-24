CREATE SCHEMA if NOT EXISTS temp;
DROP TABLE if EXISTS temp.source_to_update;
DROP TABLE if EXISTS temp.vocab_logger;
DROP TABLE if EXISTS temp.psych_mapping;

CREATE TABLE temp.psych_mapping
(
    source_concept_code        TEXT,
    source_concept_id          INTEGER,
    source_vocabulary_id       TEXT,
    source_description         TEXT,
    source_description_synonym TEXT,
    clinical_expert_specialty  TEXT,
    relationship_id            TEXT,
    predicate_id               TEXT,
    confidence                 FLOAT,
    target_concept_id          TEXT,
    target_concept_name        TEXT,
    target_vocabulary_id       TEXT,
    target_domain_id           TEXT,
    mapping_justification      TEXT,
    author_label               TEXT,
    decision                   TEXT,
    review_date_mm_dd_yy       TEXT,
    reviewer_name              TEXT,
    reviewer_specialty         TEXT,
    reviewer_comment           TEXT,
    author_comment             TEXT,
    orcid_id                   TEXT,
    status                     TEXT,
    site_name                  TEXT,
    change_required            TEXT,
    final_decision             TEXT,
    final_comment              TEXT
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
insert into vocab.concept (concept_id, concept_name, domain_id, vocabulary_id, concept_class_id, standard_concept,
                     concept_code, valid_start_date, valid_end_date, invalid_reason)
values (2082499999, 'WAVEFORM', 'Metadata', 'Vocabulary', 'Vocabulary', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL);

insert into vocab.vocabulary (vocabulary_id, vocabulary_name, vocabulary_reference, vocabulary_version,
                        vocabulary_concept_id)
values ('WAVEFORM', 'WAVEFORM Custom Terminology', 'OMOP generated', now()::date, 2082499999);


INSERT INTO vocab.concept_class (concept_class_id, concept_class_name, concept_class_concept_id)
VALUES  ('WFE File Format', 'WFE File Format', 46233639),
        ('WFE Algorithm', 'WFE Algorithm', 46233639),
        ('WFE Lead', 'WFE Lead', 46233639)
;

insert into vocab.concept (concept_id, concept_name, domain_id, vocabulary_id, concept_class_id, standard_concept,
                     concept_code, valid_start_date, valid_end_date, invalid_reason)
values (2082499991, 'Waveform Metadata', 'Metadata', 'Domain', 'Domain', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL);

INSERT INTO vocab.domain(domain_id, domain_name, domain_concept_id)
VALUES ('Waveform Metadata', 'Waveform Metadata', 2082499991);
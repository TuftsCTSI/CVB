insert into vocab.concept (concept_id, concept_name, domain_id, vocabulary_id, concept_class_id, standard_concept,
                     concept_code, valid_start_date, valid_end_date, invalid_reason)
values (2062499999, 'MIMIC4', 'Metadata', 'Vocabulary', 'Vocabulary', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL);

insert into vocab.vocabulary (vocabulary_id, vocabulary_name, vocabulary_reference, vocabulary_version,
                        vocabulary_concept_id)
values ('MIMIC4', 'MIMIC4 Custom Terminology', 'OMOP generated', now()::date, 2062499999);


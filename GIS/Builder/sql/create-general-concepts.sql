INSERT INTO vocab.concept_class (concept_class_id, concept_class_name, concept_class_concept_id)
VALUES  ('ADI Construct', 'ADI Construct', 46233639),
        ('ADI Item', 'ADI Item', 46233639),
        ('AHRQ Construct', 'AHRQ Construct', 46233639),
        ('AHRQ Determinant', 'AHRQ Determinant', 46233639),
        ('AHRQ Item', 'AHRQ Item', 46233639),
        ('COI Construct', 'COI Construct', 46233639),
        ('COI Determinant', 'COI Determinant', 46233639),
        ('COI Item', 'COI Item', 46233639),
        ('EJI EBM Item', 'EJI EBM Item', 46233639),
        ('EJI HVM Item', 'EJI HVM Item', 46233639),
        ('EJI Item', 'EJI Item', 46233639),
        ('Exposome Target', 'Exposome Target', 46233639),
        ('Exposome Transporter', 'Exposome Transporter', 46233639),
        ('Exposure Type Concept', 'Exposure Type Concept', 46233639),
        ('Geometry Relationship', 'Geometry Relationship', 46233639),
        ('Geometry Type', 'Geometry Type', 46233639),
        ('GIS Measure', 'GIS Measure', 46233639),
        ('SDG Goal', 'SDG Goal', 46233639),
        ('SDG Indicator', 'SDG Indicator', 46233639),
        ('SDOH Construct', 'SDOH Construct', 46233639),
        ('SDOH Determinant', 'SDOH Determinant', 46233639),
        ('SDOH Item', 'SDOH Item', 46233639),
        ('SDOHO Construct', 'SDOHO Construct', 46233639),
        ('SDOHO Determinant', 'SDOHO Determinant', 46233639),
        ('SDOHO Item', 'SDOHO Item', 46233639),
        ('SDOHO Value', 'SDOHO Value', 46233639),
        ('SEDH Construct', 'SEDH Construct', 46233639),
        ('SEDH Item', 'SEDH Item', 46233639),
        ('SVI Construct', 'SVI Construct', 46233639),
        ('SVI Determinant', 'SVI Determinant', 46233639),
        ('SVI Item', 'SVI Item', 46233639);

insert into vocab.concept (concept_id, concept_name, domain_id, vocabulary_id, concept_class_id, standard_concept,
                     concept_code, valid_start_date, valid_end_date, invalid_reason)
values (2052499999, 'OMOP SDOH', 'Metadata', 'Vocabulary', 'Vocabulary', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499998, 'OMOP Exposome', 'Metadata', 'Vocabulary', 'Vocabulary', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499997, 'OMOP GIS', 'Metadata', 'Vocabulary', 'Vocabulary', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499996, 'Has geometry', 'Metadata', 'Relationship', 'Relationship', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499995, 'Affects biostructure', 'Metadata', 'Relationship', 'Relationship', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499994, 'Locates in tissue', 'Metadata', 'Relationship', 'Relationship', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499993, 'Locates in cell', 'Metadata', 'Relationship', 'Relationship', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499992, 'Impact on process', 'Metadata', 'Relationship', 'Relationship', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499991, 'Environmental Feature', 'Metadata', 'Domain', 'Domain', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499990, 'Phenotypic Feature', 'Metadata', 'Domain', 'Domain', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499989, 'Demographic Feature', 'Metadata', 'Domain', 'Domain', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499988, 'Socioeconomic Feature', 'Metadata', 'Domain', 'Domain', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499987, 'Geographic Feature', 'Metadata', 'Domain', 'Domain', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499986, 'Behavioral Feature', 'Metadata', 'Domain', 'Domain', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL),
       (2052499985, 'Healthcare Feature', 'Metadata', 'Domain', 'Domain', 'S', 'OMOP generated', now()::date, '2099-12-31', NULL);


INSERT INTO vocab.domain(domain_id, domain_name, domain_concept_id)
VALUES ('Environmental Feature', 'Environmental Feature', 2052499991),
        ('Phenotypic Feature', 'Phenotypic Feature', 2052499990),
        ('Demographic Feature', 'Demographic Feature', 2052499989),
        ('Socioeconomic Feature', 'Socioeconomic Feature', 2052499988),
        ('Geographic Feature', 'Geographic Feature', 2052499987),
        ('Behavioral Feature', 'Behavioral Feature', 2052499986),
        ('Healthcare Feature', 'Healthcare Feature', 2052499985);


INSERT INTO vocab.relationship(relationship_id, relationship_name, is_hierarchical, defines_ancestry, reverse_relationship_id, relationship_concept_id)
VALUES ('Has geometry', 'Has geometry', 0, 0, 'Is geometry of', 2052499996),
        ('Affects biostructure','Affects biostructure',0,0,'Affected by',2052499995),
        ('Locates in tissue', 'Locates in tissue', 0, 0, 'Tissue contains',2052499994),
        ('Locates in cell', 'Locates in cell', 0, 0, 'Cell contains', 2052499993),
        ('Impact on process', 'Impact on process', 0, 0, 'Impacted by', 2052499992);

insert into vocab.vocabulary (vocabulary_id, vocabulary_name, vocabulary_reference, vocabulary_version,
                        vocabulary_concept_id)
values ('OMOP SDOH', 'OMOP Social Determinants of Health', 'OMOP generated', now()::date, 2052499999),
       ('OMOP Exposome', 'OMOP Exposome', 'OMOP generated', now()::date, 2052499998),
       ('OMOP GIS', 'OMOP Geographic Information System', 'OMOP generated', now()::date, 2052499997);


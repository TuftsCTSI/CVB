set search_path to vocab;

set session_replication_role to replica;
delete from vocabulary where vocabulary_concept_id >= 2000000000;
delete from concept_ancestor where ancestor_concept_id >= 2000000000;
delete from concept_ancestor where descendant_concept_id >= 2000000000;
delete from concept_relationship where concept_id_1 >= 2000000000;
delete from concept_relationship where concept_id_2 >= 2000000000;
delete from concept where concept_id >= 2000000000;
delete from concept_synonym WHERE concept_id >= 2000000000;
delete from domain where domain_concept_id >= 2000000000;
delete from concept_class WHERE concept_class_concept_id = 46233639 AND concept_class_id != 'Suppl Concept';
delete from relationship WHERE relationship_concept_id >= 2000000000;
delete from source_to_concept_map;
delete from mapping_metadata;
set session_replication_role to origin;

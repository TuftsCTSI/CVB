 #!/bin/bash

rm -rf /tmp/output

mkdir /tmp/output

export SQL_DIRECTORY="/opt/etl/CVB/GIS/Builder/sql"
export MAP_DIRECTORY="/opt/etl/CVB/GIS/Mappings"


# ONLY EXECUTE ON FIRST RUN!
#psql -h "$2" -d gis_vocabulary -U postgres -f "${SQL_DIRECTORY}/create-general-concepts.sql"

# Create tables for source mapping files
psql -h "$2" -d gis_vocabulary -U postgres -f "${SQL_DIRECTORY}/source-ddl.sql"

# COPY mappings to vocab server - gis_source
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.gis_source FROM '${MAP_DIRECTORY}/gis_source.csv' CSV HEADER"

# COPY mappings to vocab server - gis_mapping
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.gis_mapping FROM '${MAP_DIRECTORY}/gis_mapping.csv' CSV HEADER"

# COPY mappings to vocab server - gis_hierarchy
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.gis_hierarchy FROM '${MAP_DIRECTORY}/gis_hierarchy.csv' CSV HEADER"

# Convert raw mappings to source table
psql -h "$2" -d gis_vocabulary -U postgres -f "${SQL_DIRECTORY}/load-source.sql"

# Ensure appropriate id assignment
psql -h "$2" -d gis_vocabulary -U postgres -f "${SQL_DIRECTORY}/revert-id-sequence.sql"

# Populate check tables
psql -h "$2" -d gis_vocabulary -U postgres -f "${SQL_DIRECTORY}/evaluate-difference.sql"

# Populate staging standard
psql -h "$2" -d gis_vocabulary -U postgres -f "${SQL_DIRECTORY}/update-standard.sql"

# Populate staging nonstandard
psql -h "$2" -d gis_vocabulary -U postgres -f "${SQL_DIRECTORY}/update-nonstandard.sql"

# Populate staging synonym
psql -h "$2" -d gis_vocabulary -U postgres -f "${SQL_DIRECTORY}/update-synonym.sql"

# Check for updates and deprecations
psql -h "$2" -d gis_vocabulary -U postgres -f "${SQL_DIRECTORY}/deprecate-and-update.sql"

# Remove duplicates
psql -h "$2" -d gis_vocabulary -U postgres -f "${SQL_DIRECTORY}/pre-update.sql"

# Apply main update
psql -h "$2" -d gis_vocabulary -U postgres -f "${SQL_DIRECTORY}/execute-core-update.sql"

# Get Logging/Counts
psql -h "$2" -d gis_vocabulary -U postgres -f "${SQL_DIRECTORY}/message-log.sql"

# Prepare for export
psql -h "$2" -d gis_vocabulary -U postgres -f "${SQL_DIRECTORY}/create-delta-tables.sql"


echo "-- EXECUTE THE CODE BELOW TO UPDATE YOUR VOCABULARY TABLES WITH GIS CONCEPTS" >> /tmp/output/restore.sql

pg_dump -h "$2" -U postgres \
  --table=temp.concept_delta \
  --table=temp.concept_relationship_delta \
  --table=temp.concept_synonym_delta \
  --table=temp.concept_ancestor_delta \
  --table=temp.vocabulary_delta \
  --table=temp.concept_class_delta \
  --table=temp.relationship_delta \
  --table=temp.domain_delta \
  --table=temp.source_to_concept_map_delta \
  --table=temp.mapping_metadata_delta \
  --column-inserts postgres >> /tmp/output/restore.sql

# concept_delta
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.concept_delta TO '/tmp/output/concept_delta.csv' CSV HEADER"

# concept_relationship_delta
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.concept_relationship_delta TO '/tmp/output/concept_relationship_delta.csv' CSV HEADER"

# concept_synonym_delta
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.concept_synonym_delta TO '/tmp/output/concept_synonym_delta.csv' CSV HEADER"

# concept_ancestor_delta
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.concept_ancestor_delta TO '/tmp/output/concept_ancestor_delta.csv' CSV HEADER"

# vocabulary_delta
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.vocabulary_delta TO '/tmp/output/vocabulary_delta.csv' CSV HEADER"

# concept_class_delta 
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.concept_class_delta TO '/tmp/output/concept_class_delta.csv' CSV HEADER"

# relationship_delta
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.relationship_delta TO '/tmp/output/relationship_delta.csv' CSV HEADER"

# domain_delta
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.domain_delta TO '/tmp/output/domain_delta.csv' CSV HEADER"

# source_to_concept_map
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.source_to_concept_map_delta TO '/tmp/output/source_to_concept_map.csv' CSV HEADER"

# mapping_metadata
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.mapping_metadata_delta TO '/tmp/output/mapping_metadata.csv' CSV HEADER"

# update log
psql -h "$2" -d gis_vocabulary -U postgres -c "\copy temp.UPDATE_LOG TO '/tmp/output/update_log.csv' CSV HEADER"

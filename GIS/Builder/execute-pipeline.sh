 #!/bin/bash

rm -rf /tmp/output

mkdir /tmp/output

export SQL_DIRECTORY="${RUNNER_WORKDIR}/chorus-mapping-stage/chorus-mapping-stage/Builder/sql"
#export SQL_DIRECTORY="/extracts/data/vocab-builder/chorus-mapping-stage/Builder/sql"
export MAP_DIRECTORY="${RUNNER_WORKDIR}/chorus-mapping-stage/chorus-mapping-stage/Mappings"
#export MAP_DIRECTORY="/extracts/data/vocab-builder/chorus-mapping-stage/Mappings"


export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/source-ddl.sql"

# COPY mappings to vocab server - exact-level-1
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.source_exact_1 FROM '${MAP_DIRECTORY}/exact-level-1.csv' CSV HEADER"

# COPY mappings to vocab server - broad-level-2
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.source_broad_2 FROM '${MAP_DIRECTORY}/broad-level-2.csv' CSV HEADER"

# COPY mappings to vocab server - narrow-level-3
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.source_narrow_3 FROM '${MAP_DIRECTORY}/narrow-level-3.csv' CSV HEADER"

# COPY mappings to vocab server - related-level-4
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.source_related_4 FROM '${MAP_DIRECTORY}/related-level-4.csv' CSV HEADER"

# COPY mappings to vocab server - exact-level-5
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.source_exact_5 FROM '${MAP_DIRECTORY}/exact-level-5.csv' CSV HEADER"

# COPY mappings to vocab server - broad-level-6
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.source_broad_6 FROM '${MAP_DIRECTORY}/broad-level-6.csv' CSV HEADER"

# COPY mappings to vocab server - narrow-level-7
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.source_narrow_7 FROM '${MAP_DIRECTORY}/narrow-level-7.csv' CSV HEADER"

# COPY mappings to vocab server - related-level-8
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.source_related_8 FROM '${MAP_DIRECTORY}/related-level-8.csv' CSV HEADER"

# Convert raw mappings to source table
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/load-source.sql"

# Ensure appropriate id assignment
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/revert-id-sequence.sql"

# Populate check tables
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/evaluate-difference.sql"

# Populate staging standard
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/update-standard.sql"

# Populate staging nonstandard
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/update-nonstandard.sql"

# Populate staging synonym
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/update-synonym.sql"

# Check for updates and deprecations
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/deprecate-and-update.sql"

# Remove duplicates
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/pre-update.sql"

# Apply main update
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/execute-core-update.sql"

# Get Logging/Counts
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/message-log.sql"

# Prepare for export
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/create-delta-tables.sql"


echo "-- EXECUTE THE CODE BELOW TO UPDATE YOUR VOCABULARY TABLES WITH CHORUS INFO" >> /tmp/output/restore.sql

export PGPASSWORD="$1" && pg_dump -h "$2" -U postgres \
  --table=temp.concept_delta \
  --table=temp.concept_relationship_delta \
  --table=temp.concept_synonym_delta \
  --table=temp.concept_ancestor_delta \
  --table=temp.vocabulary_delta \
  --table=temp.concept_class_delta \
  --table=temp.source_to_concept_map_delta \
  --table=temp.mapping_metadata_delta \
  --column-inserts postgres >> /tmp/output/restore.sql

# concept_delta
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.concept_delta TO '/tmp/output/concept_delta.csv' CSV HEADER"

# concept_relationship_delta
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.concept_relationship_delta TO '/tmp/output/concept_relationship_delta.csv' CSV HEADER"

# concept_synonym_delta
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.concept_synonym_delta TO '/tmp/output/concept_synonym_delta.csv' CSV HEADER"

# concept_ancestor_delta
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.concept_ancestor_delta TO '/tmp/output/concept_ancestor_delta.csv' CSV HEADER"

# vocabulary_delta
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.vocabulary_delta TO '/tmp/output/vocabulary_delta.csv' CSV HEADER"

# concept_class_delta 
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.concept_class_delta TO '/tmp/output/concept_class_delta.csv' CSV HEADER"

# source_to_concept_map
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.source_to_concept_map_delta TO '/tmp/output/source_to_concept_map.csv' CSV HEADER"

# mapping_metadata
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.mapping_metadata_delta TO '/tmp/output/mapping_metadata.csv' CSV HEADER"

# update log
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -c "\copy temp.UPDATE_LOG TO '/tmp/output/update_log.csv' CSV HEADER"

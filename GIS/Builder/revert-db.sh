#!/bin/bash


#export SQL_DIRECTORY="${RUNNER_WORKDIR}/chorus-mapping-stage/chorus-mapping-stage/Builder/sql"
export SQL_DIRECTORY="/extracts/data/vocab-builder/chorus-mapping-stage/Builder/sql"
#export MAP_DIRECTORY="${RUNNER_WORKDIR}/chorus-mapping-stage/chorus-mapping-stage/Mappings"
export MAP_DIRECTORY="/extracts/data/vocab-builder/chorus-mapping-stage/Mappings"

# Remove all additions from db
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/hard-reset.sql"

# Remove all additions from db
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/create-general-concepts.sql"

# Revert id sequence
export PGPASSWORD="$1" && psql -h "$2" -d postgres -U postgres -f "${SQL_DIRECTORY}/revert-id-sequence.sql"

#!/bin/bash


export SQL_DIRECTORY="${RUNNER_WORKDIR}/CVB/CVB/MIMIC/Builder/sql"
export MAP_DIRECTORY="${RUNNER_WORKDIR}/CVB/CVB/MIMIC/Mappings"

# Remove all additions from db
psql -h "$2" -d mimic_vocabulary -U postgres -f "${SQL_DIRECTORY}/hard-reset.sql"

# Remove all additions from db
psql -h "$2" -d mimic_vocabulary -U postgres -f "${SQL_DIRECTORY}/create-general-concepts.sql"

# Revert id sequence
psql -h "$2" -d mimic_vocabulary -U postgres -f "${SQL_DIRECTORY}/revert-id-sequence.sql"

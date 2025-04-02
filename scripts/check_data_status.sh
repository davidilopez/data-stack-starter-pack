#!/bin/bash

set -e  # Exit on error

__docker_call() {
    if [ -z "$POSTGRES_USER" ]; then
        echo "Error: POSTGRES_USER environment variable is not set."
        exit 1
    fi

    echo "Running docker exec command..."
    docker exec -it $1 psql -U ${POSTGRES_USER} -d $2 -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name = '$3'" 2>/dev/null | grep -w "$3"
}

# Function to check data status in postgres docker container
check_data_status() {
    container_name=$1
    db_name=$2
    schema_name=$3

    echo "Checking if schema $schema_name exists..."
    SCHEMA_EXISTS=$(__docker_call $container_name $db_name $schema_name)

    if echo "$SCHEMA_EXISTS" | grep -qw "$schema_name"; then
        echo "Schema $schema_name exists in database $db_name."
        exit 0
    else
        echo "Error: Schema $schema_name does not exist in database $db_name."
        exit 1
    fi
}

# Check data status
check_data_status $1 $2 $3

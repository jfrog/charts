#!/bin/bash
# This can be used to create user, database, schema and grant the required permissions.
# This script can handle multiple execution and not with "already exists" error. An entity will get created only if it does not exist.
# NOTE : 1. This expects current linux user to be admin user in postgreSQL (this is the case with 'postgres' user)
#        2. Execute this by logging as postgres or any other user with similar privilege
#        3. This files needs be executed from a location which postgres (or the admin user which will be used) has access to. (/opt can be used)
#
#        su postgres -c "POSTGRES_PATH=/path/to/postgres/bin PGPASSWORD=postgres bash ./createPostgresUsers.sh"
POSTGRES_LABEL="Postgres"

# Logging function
log() {
    echo -e "$1"
}

# Error function
errorExit() {
    echo; echo -e "\033[31mERROR:\033[0m $1"; echo
    exit 1
}

# Create user if it does not exist
createUser(){
    local user=$1
    local pass=$2
    [ ! -z ${user} ] || errorExit "user is empty"
    [ ! -z ${pass} ] || errorExit "password is empty"
    ${PSQL} $POSTGRES_OPTIONS -tAc "SELECT 1 FROM pg_roles WHERE rolname='${user}'" | grep -q 1 1>/dev/null
    local rc=$?
    # Create user if doesn't exists
    if [[ ${rc} -ne 0 ]]; then
        echo "Creating user ${user}..."
        ${PSQL} $POSTGRES_OPTIONS -c "CREATE USER ${user} WITH PASSWORD '${pass}';" 1>/dev/null || errorExit "Failed creating user ${user} on PostgreSQL"
        echo "Done"
    fi
}

# Create database if it does not exist
createDB(){
    local db=$1
    local user=$2
    [ ! -z ${db}   ] || errorExit "db is empty"
    [ ! -z ${user} ] || errorExit "user is empty"
    if ! ${PSQL} $POSTGRES_OPTIONS -lqt | cut -d \| -f 1 | grep -qw ${db} 1>/dev/null; then
        ${PSQL} $POSTGRES_OPTIONS -c "CREATE DATABASE ${db} WITH OWNER=${user} ENCODING='UTF8';" 1>/dev/null || errorExit "Failed creating db ${db} on PostgreSQL"
    fi
}

# Check if postgres db is ready
postgresIsNotReady() {
    attempt_number=${attempt_number:-0}
    ${PSQL} $POSTGRES_OPTIONS --version > /dev/null 2>&1
    outcome1=$?
    # Execute a simple db function to verify if postgres is up and running
    ${PSQL} $POSTGRES_OPTIONS -l > /dev/null 2>&1
    outcome2=$?
    if [[ $outcome1 -eq 0 ]] && [[ $outcome2 -eq 0  ]]; then
        return 0
    else
        if [ $attempt_number -gt 10 ]; then
            errorExit "Unable to proceed. $POSTGRES_LABEL is not reachable. This can occur if the service is not running \
or the port is not accepting requests at $DB_PORT (host : $DB_HOST). Gave up after $attempt_number attempts"
        fi
        let "attempt_number=attempt_number+1"
        return 1
    fi
}

# Wait for availability of postgres
init(){
    if [[ -z $POSTGRES_PATH ]]; then
        hash ${PSQL} 2>/dev/null || { echo >&2 "\"${PSQL}\" is not installed or not available in path"; exit 1; }
    fi
    log "Waiting for $POSTGRES_LABEL to get ready using the commands: \"${PSQL} $POSTGRES_OPTIONS --version\" & \"${PSQL} $POSTGRES_OPTIONS -l\""
    attempt_number=0
    while ! postgresIsNotReady
    do
        sleep 5
        echo -n '.'
    done
    log "$POSTGRES_LABEL is ready. Executing commands"
}

# Create users and DB
setupDB(){
    local user=$1
    local pass=$2
    local db=$3
    # Create user
    createUser "${user}" "${pass}"    
    createDB "${db}" "${user}"
    ${PSQL} $POSTGRES_OPTIONS -c "GRANT ALL PRIVILEGES ON DATABASE ${db} TO ${user}" 1>/dev/null;
}

# Load default and custom postgres details from below files
[ -f setenvDefaults.sh ] && source setenvDefaults.sh || true
[ -f setenv.sh         ] && source setenv.sh         || true

# DB_NAME=$1
# DB_USERNAME=$2
# DB_PASSWORD=$3
# CHART_NAME=$4

: ${DB_NAME:=$1}
: ${DB_USERNAME:=$2}
: ${DB_PASSWORD:=$3}
: ${CHART_NAME:=4}

### Following are the postgres details being setup for each service.
##  Common details
: ${DB_PORT:=5432}
: ${DB_SSL_MODE:="disable"}
: ${DB_TABLESPACE:="pg_default"}
: ${DB_HOST:="localhost"}

## Set Postgres options
[[ -z "${POSTGRES_PATH}" ]] && PSQL=psql || PSQL=${POSTGRES_PATH}/psql
POSTGRES_OPTIONS="sslmode=${DB_SSL_MODE} --host=${DB_HOST} -U ${PGUSERNAME} -w"

init

log "Setting up DB $DB_NAME and user $DB_USERNAME on Postgres for $CHART_NAME chart."
setupDB "${DB_USERNAME}" "${DB_PASSWORD}" "${DB_NAME}" || true

log "$POSTGRES_LABEL setup is now complete."

exit 0
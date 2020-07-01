#! /bin/bash
# This can be used to export JFrog Mission Control data for migration from Mission Control 3.5.1+ to 4.x

set -e

# default values
TEMP_FOLDER= # Will be defined during init
OUTPUT_DIR=.
OUTPUT_FILE= # Will be defined during init
DB_USER_NAME=jfmc
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE_NAME=mission_control
DB_DATABASE_SCHEMA=jfmc_server
VERBOSE_MODE=false


# ..... _logger.sh ......
# REF https://misc.flogisoft.com/bash/tip_colors_and_formatting
cClear="\e[0m"
cBlue="\e[38;5;69m"
cRedDull="\e[1;31m"
cYellow="\e[1;33m"
cRedBright="\e[38;5;197m"


_loggerGetMode() {
    local MODE="$1"
    case $MODE in
    INFO)
        printf "${cBlue}%s%-5s%s${cClear}" "[" "${MODE}" "]"
    ;;
    DEBUG)
        printf "%-7s" "[${MODE}]"
    ;;
    WARN)
        printf "${cRedDull}%s%-5s%s${cClear}" "[" "${MODE}" "]"
    ;;
    ERROR)
        printf "${cRedBright}%s%-5s%s${cClear}" "[" "${MODE}" "]"
    ;;
    esac
}

# Capitalises the first letter of the message
_loggerGetMessage() {
    local originalMessage="$*"
    local firstChar=$(echo "${originalMessage:0:1}" | awk '{ print toupper($0) }')
    local resetOfMessage="${originalMessage:1}"
    echo "$firstChar$resetOfMessage"
}

# The spec also says content should be left-trimmed but this is not necessary in our case. We don't reach the limit.
_loggerGetStackTrace() {
    printf "%s%-30s%s" "[" "$1:$2" "]"
}

_loggerGetThread() {
    printf "%s" "[main]"
}

_loggerGetServiceType() {
    printf "%s%-5s%s" "[" "shell" "]"
}

#Trace ID is not applicable to scripts
_loggerGetTraceID() {
    printf "%s" "[]"
}

# The date binary works differently based on whether it is GNU/BSD
is_date_supported=0
date --version > /dev/null 2>&1 || is_date_supported=1
IS_GNU=$(echo $is_date_supported)

_loggerGetTimestamp() {
    if [ "${IS_GNU}" == "0" ]; then
        echo -n $(date -u +%FT%T.%3NZ)
    else
        echo -n $(date -u +%FT%T.000Z)
    fi
}

logger() {
    if [ -z "$CONTEXT" ]
    then
        CONTEXT=$(caller)
    fi
    local MESSAGE="$1"
    local MODE=${2-"INFO"}
    local SERVICE_TYPE="script"
    local TRACE_ID=""
    local THREAD="main"

    local CONTEXT_LINE=$(echo "$CONTEXT" | awk '{print $1}')
    local CONTEXT_FILE=$(echo "$CONTEXT" | awk -F"/" '{print $NF}')

    # To comply with logging standards
    printf "%s\n" "$(_loggerGetTimestamp) $(_loggerGetServiceType) $(_loggerGetMode $MODE) $(_loggerGetTraceID) $(_loggerGetStackTrace $CONTEXT_FILE $CONTEXT_LINE) $(_loggerGetThread) - $(_loggerGetMessage $MESSAGE)"

    CONTEXT=
}

logDebug(){
    VERBOSE_MODE=${VERBOSE_MODE-"false"}
    CONTEXT=$(caller)
    if [ ${VERBOSE_MODE} == "true" ];then
        logger "$1" "DEBUG"
    else
        logger "$1" "DEBUG" >&6
    fi
    CONTEXT=
}

logError() {
    CONTEXT=$(caller)
    logger "$1" "ERROR"
    CONTEXT=
}

errorExit () {
    logError "$1" "ERROR"
    exit 1
}

warn () {
    CONTEXT=$(caller)
    logger "$1" "WARN"
    CONTEXT=
}

note () {
    CONTEXT=$(caller)
    logger "$1" "NOTE"
    CONTEXT=
}

bannerStart() {
    title=$1
    echo
    echo -e "\033[1m${title}\033[0m"
    echo
}

bannerSection() {
    title=$1
    echo
    echo -e "******************************** ${title} ********************************"
    echo
}

bannerSubSection() {
    title=$1
    echo
    echo -e "************** ${title} *******************"
    echo
}

bannerMessge() {
    title=$1
    echo
    echo -e "********************************"
    echo -e "${title}"
    echo -e "********************************"
    echo
}

setRed () {
    local input="$1"
    echo -e \\033[31m${input}\\033[0m
}
setGreen () {
    local input="$1"
    echo -e \\033[32m${input}\\033[0m
}
setYellow () {
    local input="$1"
    echo -e \\033[33m${input}\\033[0m
}

logger_addLinebreak () {
    echo -e "---\n"
}

bannerImportant() {
    title=$1
    echo
    echo -e "######################################## IMPORTANT ########################################"
    echo -e "\033[1m${title}\033[0m"
    echo -e "###########################################################################################"
    echo
}

bannerEnd() {
    #TODO pass a title and calculate length dynamically so that start and end look alike
    echo
    echo "*****************************************************************************"
    echo
}

banner() {
    title=$1
    content=$2
    bannerStart "${title}"
    echo -e "$content"
}

# The logic below helps us redirect content we'd normally hide to the log file.
    #
    # We have several commands which clutter the console with output and so use
    # `cmd > /dev/null` - this redirects the command's output to null.
    #
    # However, the information we just hid maybe useful for support. Using the code pattern
    # `cmd >&6` (instead of `cmd> >/dev/null` ), the command's output is hidden from the console
    # but redirected to the installation log file
    #

#Default value of 6 is just null
exec 6>>/dev/null
redirectLogsToFile() {
    echo ""
    # local file=$1

    # [ ! -z "${file}" ] || return 0

    # local logDir=$(dirname "$file")

    # if [ ! -f "${file}" ]; then
    #     [ -d "${logDir}" ] || mkdir -p ${logDir} || \
    #     ( echo "WARNING : Could not create parent directory (${logDir}) to redirect console log : ${file}" ; return 0 )
    # fi

    # #6 now points to the log file
    # exec 6>>${file}
    # #reference https://unix.stackexchange.com/questions/145651/using-exec-and-tee-to-redirect-logs-to-stdout-and-a-log-file-in-the-same-time
    # exec 2>&1 > >(tee -a "${file}")
}


# Utility method to strip away codes
_codeStripper() {
    # Some possible codes [39m, [33m, [1m
    echo "$*" | sed 's/\[[0-9]\{1,\}m//g'
}


# Output from application's logs are piped to this method. It checks a configuration variable to determine if content should be logged to
# the common console.log file
redirectServiceLogsToFile() {

    local result="0"
    # check if the function getSystemValue exists
    LC_ALL=C type getSystemValue > /dev/null 2>&1 || result="$?"
    if [[ "$result" != "0" ]]; then
        warn "Couldn't find the systemYamlHelper. Skipping log redirection"
        return 0
    fi

    getSystemValue "shared.consoleLog" "NOT_SET"
    if [[ "${YAML_VALUE}" == "false" ]]; then
        logger "Redirection is set to false. Skipping log redirection"
        return 0;
    fi

    if [ -z "${JF_PRODUCT_HOME}" ] || [ "${JF_PRODUCT_HOME}" == "" ]; then
        warn "JF_PRODUCT_HOME is unavailable. Skipping log redirection"
        return 0
    fi

    local targetFile="${JF_PRODUCT_HOME}/var/log/console.log"

    if [ ! -f ${targetFile} ]; then
        mkdir -p "${JF_PRODUCT_HOME}/var/log" || return 0
        touch $targetFile
    fi

    while read -r line; do
        printf '%s\n' "${line}" >> $targetFile || return 0 # Don't want to log anything - might clutter the screen
    done
}
# ..... _logger.sh .....

logInfo() {
    CONTEXT=$(caller)
    logger "$1" "INFO"
    CONTEXT=
}

usage() {
    cat << END_USAGE

jfmcDataExport.sh - Export JFrog Mission Control data for migration from Mission Control 3.5.1+ to 4.x.

Usage:   jfmcDataExport.sh [OPTION]...

Options:
  --host=HOST           database server host (default: "127.0.0.1")
  --port=PORT           database server port (default: "5432")
  --user=USER           database user name (default: "jfmc")
  --database=DATABASE   database name to connect to (default: "mission_control")
  --schema=SCHEMA       database schema name to connect to (default: "jfmc_server")
  --output=OUTPUT       path to output dir where jfmcDataExport.tar.gz will be created (default: ".")
  --verbose             show detailed output logs
  -h, --help            show this help, then exit

In case psql binary cannot be found in path, POSTGRES_PATH environment variable can be defined to provide psql
location dir.

END_USAGE

    exit 1
}

parseOptions() {
    for cliArgument in "$@"
    do
        case ${cliArgument} in
            --user=*)
                DB_USER_NAME="${cliArgument#*=}"
                shift # past argument=value
                ;;
            --database=*)
                DB_DATABASE_NAME="${cliArgument#*=}"
                shift # past argument=value
                ;;
            --schema=*)
                DB_DATABASE_SCHEMA="${cliArgument#*=}"
                shift # past argument=value
                ;;
            --host=*)
                DB_HOST="${cliArgument#*=}"
                shift # past argument=value
                ;;
            --port=*)
                DB_PORT="${cliArgument#*=}"
                shift # past argument=value
                ;;
            --output=*)
                OUTPUT_DIR="${cliArgument#*=}"
                shift # past argument=value
                ;;
            --verbose)
                VERBOSE_MODE=true
                shift # past argument=value
                ;;
            -h|--help)
                usage
                ;;
            *)
                # unknown option
                usage
                ;;
        esac
    done
}

logEnv() {
    logDebug "Settings: "
    logDebug "  - Database server host:    ${DB_HOST}"
    logDebug "  - Database server port:    ${DB_PORT}"
    logDebug "  - Database name:           ${DB_DATABASE_NAME}"
    logDebug "  - Database user name:      ${DB_USER_NAME}"
    logDebug "  - Temporary output folder: ${TEMP_FOLDER}"
    logDebug "  - Output dir:              ${OUTPUT_DIR}"
}

cleanUp() {
    [[ -d "${TEMP_FOLDER}" ]] && logDebug "Deleting temp folder..." && rm -rf ${TEMP_FOLDER}
    logDebug "Clean up complete"

}

exitOnError() {
    local message=$1
    logError "Stopping because: ${message}!"
    cleanUp
    exit 1
}

exitOnInterrupt() {
    exitOnError "Process interrupted"
}

init() {
    if [[ -z $POSTGRES_PATH ]]; then
        hash ${PSQL} 2>/dev/null || { echo >&2 "\"${PSQL}\" is not installed or not available in path"; exit 1; }
    fi
    logDebug "Preparing output folder..."
    TEMP_FOLDER=$(mktemp -d)
    logEnv
    [[ -d ${TEMP_FOLDER} ]] || exitOnError "Temporary folder could not be created"
    [[ -d ${OUTPUT_DIR} ]] || exitOnError "${OUTPUT_DIR} does not exist"
    OUTPUT_FILE="${OUTPUT_DIR}/jfmcDataExport.tar.gz"
    if [[ -f "${OUTPUT_FILE}" ]]; then
	warn "${OUTPUT_FILE} will be overwritten."
    fi
}

verifyFileExistsAndIsNotEmpty() {
    local file=$1
    [[ -f "${file}" ]] || exitOnError "${file} is missing"
    [[ -s "${file}" ]] || exitOnError "${file} should not be empty"
}

extractSqlQueryToJsonFile() {
    local sqlQuery=$1
    local outputPath=$2
    logDebug "Dumping data to ${outputPath}"
    # Note: Redirecting output requires less permissions than using "COPY ... TO 'path/to/file'"
    ${PSQL} --command="COPY (SELECT array_to_json(coalesce(array_agg(row_to_json(t)), '{}')) FROM ($sqlQuery) t) TO STDOUT;" \
         --username=${DB_USER_NAME} \
         --host=${DB_HOST} \
         --port=${DB_PORT} \
         --dbname=${DB_DATABASE_NAME} > ${outputPath} || exitOnError "psql command failed"
    verifyFileExistsAndIsNotEmpty "${outputPath}"
}

bundleData() {
    logInfo "Bundling exported data..."
    tar --create --gzip --file ${OUTPUT_FILE} --directory ${TEMP_FOLDER} .  || exitOnError "Bundle creation failed"
    logInfo "Mission Control data dumped to: ${OUTPUT_FILE}"
}

extractData() {
    logInfo "Exporting license buckets..."
    local bucketsSql="SELECT id, subject, product_name, product_id, license_type, issued_date, valid_date, quantity, identifier, signature, max_of_usage, name, saas_imported, identifier_index, jfmc_info_service_id, jfmc_info_url, split_parent_id FROM ${DB_DATABASE_SCHEMA}.bucket"
    extractSqlQueryToJsonFile "${bucketsSql}" "${TEMP_FOLDER}/buckets.json" || exitOnError "Export of License Buckets failed"
    logInfo "Exporting managed licenses..."
    local managedLicensesSql="SELECT id, bucket_id, license_hash, encode(license_key, 'base64') AS license_key, instance_name, state FROM ${DB_DATABASE_SCHEMA}.managed_license"
    extractSqlQueryToJsonFile "${managedLicensesSql}" "${TEMP_FOLDER}/managed-licenses.json" || exitOnError "Export of Managed Licenses failed"
}

trap exitOnInterrupt SIGINT SIGTERM SIGHUP

[[ -z "${POSTGRES_PATH}" ]] && PSQL=psql || PSQL=${POSTGRES_PATH}/psql

parseOptions "$@"
init
extractData
bundleData
cleanUp

cat << END_REPORT

To import the data in Mission Control 4.x:"
  1. Copy ${OUTPUT_FILE} into JF_PRODUCT_HOME/var/bootstrap/mc without changing the file name on one Mission Control node."
  2. Restart Mission Control node."

END_REPORT




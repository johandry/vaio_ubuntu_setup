#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Variables and functions used by all the scripts
# Description: 
#=======================================================================================================

declare -r SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
declare -r SCRIPT_NAME="$( basename "$0" )"
declare -r LOG_FILE=/tmp/${SCRIPT_NAME%.*}_$$.log

log () {
  msg="\e[${3};1m[${1}]\e[0m\t${2}\n"
  log="$(date +'%x - %X')\t[${1}]\t${2}\n"
  echo -ne $msg
  echo -ne $log >> "${LOG_FILE}"
}
error () {
  # Red [ERROR]
  log "ERROR" "${1}" 91
}
ok () {
  # Green [ OK ]
  log " OK " "${1}" 92  
}
warn () {
  # Yellow [WARN]
  log "WARN" "${1}" 93
}
info () {
  # Blue [INFO]
  log "INFO" "${1}" 94
}
debug () {
  # Purple [DBUG]
  log "DBUG" "${1}" 92
}


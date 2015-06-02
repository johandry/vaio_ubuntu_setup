#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Connect to VPN
# Usage: ${script_name} [--connect | --disconnect | --status | --help]
#
# Options:
#     -h, --help    Display this help message.
#     --connect: Connect to the VPN
#     --disconnect: Disconnect from the VPN
#     --status: Display if the conputer is or not connected to the VPN
#
# Description: 
#
# Report Issues or create Pull Requests in http://github.com/johandry/vaio_ubuntu_setup/ 
#=======================================================================================================

source "/home/${USER}/bin/common.sh"

[[ -z "$VPN_1_GATEWAY" ]] && error "VPN_1_GATEWAY variable is not defined" && exit 1 
[[ -z "$VPN_1_USER" ]]    && error "VPN_1_USER variable is not defined"    && exit 1
[[ -z "$VPN_1_PASSWD" ]]  && error "VPN_1_PASSWD variable is not defined"  && exit 1

VPN_PID_FILE="/tmp/${SCRIPT_NAME%.*}.pid"

get_pid () {
  VPN_PID=$( ps -fea | grep 'openconnect' | grep -v grep | head -1 | awk '{print $2}' )
  echo "${VPN_PID}" > "${VPN_PID_FILE}"
  echo "${VPN_PID}"
}

VPN_PID=$( get_pid )

connect () {
  VPN_PID=$( get_pid )
  [[ -n "${VPN_PID}" ]] && warn "VPN 1 is already connected (${VPN_PID})" && return 1

  sudo su -c "echo -ne '${VPN_1_PASSWD}\npush' | openconnect -u ${VPN_1_USER} ${VPN_1_GATEWAY} &"

  VPN_PID=$( get_pid )
  [[ -n "${VPN_PID}" ]] && ok "VPN 1 is connected (${VPN_PID})"
}

disconnect () {
  VPN_PID=$( get_pid )
  [[ -z "${VPN_PID}" ]] && error "VPN 1 is not running" && return 1

  sudo kill -9 ${VPN_PID} && ok "VPN 1 disconnected"

  VPN_PID=$( get_pid )
  [[ -n "${VPN_PID}" ]] && error "VPN 1 could not be disconnected (${VPN_PID})"
}

status () {
  VPN_PID=$( get_pid )
  [[ -n "${VPN_PID}" ]] && msg="VPN 1 is connected (${VPN_PID})"  && exit_code=0
  [[ -z "${VPN_PID}" ]] && msg="VPN 1 is not connected"           && exit_code=1

  info "${msg}"
  exit ${exit_code}
}

[[ -z "${1}" ]] && status
[[ "${1}" == "--help" ]] && usage
[[ "${1}" == "--connect" ]] && connect
[[ "${1}" == "--disconnect" ]] && disconnect
[[ "${1}" == "--status" ]] && status

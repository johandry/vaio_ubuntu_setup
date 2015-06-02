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

[[ -z "$VPN_2_GATEWAY" ]] && error "VPN_2_GATEWAY variable is not defined" && exit 1 
[[ -z "$VPN_2_USER" ]]    && error "VPN_2_USER variable is not defined"    && exit 1
[[ -z "$VPN_2_PASSWD" ]]  && error "VPN_2_PASSWD variable is not defined"  && exit 1

VPN_PID_FILE="/tmp/${SCRIPT_NAME%.*}.pid"

get_pid () {
  VPN_PID=$( ps -fea | grep 'array_vpnc64' | grep -v grep | head -1 | awk '{print $2}' )
  echo "${VPN_PID}" > "${VPN_PID_FILE}"
  echo "${VPN_PID}"
}

VPN_PID=$( get_pid )

connect () {
  VPN_PID=$( get_pid )
  [[ -n "${VPN_PID}" ]] && warn "VPN 2 is already connected (${VPN_PID})" && return 1

  /usr/local/array_vpn/array_vpnc64 -hostname ${VPN_2_GATEWAY} -username ${VPN_2_USER} -passwd ${VPN_2_PASSWD} &

  VPN_PID=$( get_pid )
  [[ -n "${VPN_PID}" ]] && ok "VPN 2 is connected (${VPN_PID})"
}

disconnect () {
  VPN_PID=$( get_pid )
  [[ -z "${VPN_PID}" ]] && error "VPN 2 is not running" && return 1

  /usr/local/array_vpn/array_vpnc64 -stop && ok "VPN 2 disconnected"

  VPN_PID=$( get_pid )
  [[ -n "${VPN_PID}" ]] && error "VPN 2 could not be disconnected (${VPN_PID})"
}

status () {
  VPN_PID=$( get_pid )
  [[ -n "${VPN_PID}" ]] && msg="VPN 2 is connected (${VPN_PID})"  && exit_code=0
  [[ -z "${VPN_PID}" ]] && msg="VPN 2 is not connected"           && exit_code=1

  info "${msg}"
  exit ${exit_code}
}

[[ -z "${1}" ]]                 && status
[[ "${1}" == "--help" ]]        && usage
[[ "${1}" == "--connect" ]]     && connect
[[ "${1}" == "--disconnect" ]]  && disconnect
[[ "${1}" == "--status" ]]      && status

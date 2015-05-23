#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Connect to VPN
# Description: 
#=======================================================================================================

source "/home/${USER}/bin/common.sh"

[[ -z "$VPN_GATEWAY" ]] && error "VPN_GATEWAY variable is not defined" && exit 1 
[[ -z "$VPN_USER" ]]    && error "VPN_USER variable is not defined"    && exit 1
[[ -z "$VPN_PASSWD" ]]  && error "VPN_PASSWD variable is not defined"  && exit 1

VPN_PID_FILE="/tmp/${SCRIPT_NAME%.*}.pid"

VPN_PID=$( cat /tmp/vpn.pid )

connect () {
  [[ -n "${VPN_PID}" ]] && warn "VPN is already connected (${VPN_PID})" && return 1

  sudo su -c "echo -ne '${VPN_PASSWD}\npush' | openconnect -u ${VPN_USER} ${VPN_GATEWAY} &"

  VPN_PID=$(ps -fea | grep openconnect | grep -v grep | awk '{print $2}')
  echo "${VPN_PID}" > "${VPN_PID_FILE}"
}

disconnect () {
  [[ -z "${VPN_PID}" ]] && error "VPN is not running" && return 1

  sudo kill -9 ${VPN_PID} && ok "VPN disconnected"

  VPN_PID=$(ps -fea | grep openconnect | grep -v grep | awk '{print $2}')
  echo "${VPN_PID}" > "${VPN_PID_FILE}"
  [[ -n "${VPN_PID}" ]] && error "VPN could not be disconnected (${VPN_PID})"
}

status () {
  VPN_PID_NOW=$(ps -fea | grep openconnect | grep -v grep | awk '{print $2}')
  [[ -n "${VPN_PID_NOW}" ]] && msg="VPN is connected"
  [[ -z "${VPN_PID_NOW}" ]] && msg="VPN is not connected"

  [[ "${VPN_PID}" == "${VPN_PID_NOW}" && -n "${VPN_PID}" ]] && msg="${msg} with PID ${VPN_PID}"
  if [[ "${VPN_PID}" != "${VPN_PID_NOW}" ]]
    then
    msg="${msg} and PID was fixed (${VPN_PID_NEW})"
    echo "${VPN_PID_NOW}" > "${VPN_PID_FILE}"
  fi

  info "${msg}"
}

usage () {
  echo "USAGE: ${SCRIPT_NAME} [--connect | --disconnect | --status | --help]"
}

[[ -z "${1}" ]] && status
[[ "${1}" == "--help" ]] && usage
[[ "${1}" == "--connect" ]] && connect
[[ "${1}" == "--disconnect" ]] && disconnect
[[ "${1}" == "--status" ]] && status
#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Open VMWare Horizon Client
# Usage: ${script_name} [--help]
#
# Options:
#     -h, --help    Display this help message.
#
# Description: 
#
# Report Issues or create Pull Requests in http://github.com/johandry/vaio_ubuntu_setup/ 
#=======================================================================================================

source "/home/${USER}/bin/common.sh"

[[ -z "$WIN_USER" ]]       && error "WIN_USER variable is not defined"       && exit 1 
[[ -z "$WIN_PASSWD" ]]     && error "WIN_PASSWD variable is not defined"     && exit 1
[[ -z "$WIN_DOMAIN" ]]     && error "WIN_DOMAIN variable is not defined"     && exit 1
[[ -z "$WIN_SERVER_URL" ]] && error "WIN_SERVER_URL variable is not defined" && exit 1 
[[ -z "$WIN_DESKTOP" ]]    && error "WIN_DESKTOP variable is not defined"    && exit 1

/home/${USER}/bin/vpn.sh --status

VPNConnected=$?

[[ ${VPNConnected} -ne 0 ]] && error "Looks like VPN is not connected" && exit 1

VMWV_PID=$( ps -fea | grep vmware-view | grep -v grep | awk '{print $2}' )

[[ -n "${VMWV_PID}" ]] && error "Looks like VMWare Horizon Client is already running with PID $VMWV_PID" && exit 1

vmware-view -s "${WIN_SERVER_URL}" -u "${WIN_USER}" -d "${WIN_DOMAIN}" -p "${WIN_PASSWD}" -n "${WIN_DESKTOP}" &>"${LOG_FILE}" &
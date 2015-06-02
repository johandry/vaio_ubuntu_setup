#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Open Q Messenger
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

/home/${USER}/bin/vpn_1.sh --status
VPN_1_Connected=$?
[[ ${VPN_1_Connected} -ne 0 ]] && error "Looks like VPN 1 is not connected" && exit 1

QMSGR_PID=$( ps -fea | grep java | grep 'q.att.com' | head -1 | awk '{print $2}' )

[[ -n "${QMSGR_PID}" ]] && error "Looks like Q Messenger is already running with PID $QMSGR_PID" && exit 1

/usr/bin/javaws http://startup.q.att.com/startup/webstart/q.jnlp &>"${LOG_FILE}" &
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

/home/${USER}/bin/vpn.sh --status

VPNConnected=$?

[[ ${VPNConnected} -ne 0 ]] && error "Looks like VPN is not connected" && exit 1

/usr/bin/javaws http://startup.q.att.com/startup/webstart/q.jnlp &>"${LOG_FILE}" &
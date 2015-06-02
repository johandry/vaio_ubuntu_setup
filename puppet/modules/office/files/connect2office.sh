#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Connect to the Office
# Usage: ${script_name} [--help]
#
# Options:
#     -h, --help    Display this help message.
#
# Description: Will connect to VPN and open all required programs to connect to the Office
#
# Report Issues or create Pull Requests in http://github.com/johandry/vaio_ubuntu_setup/ 
#=======================================================================================================

source "/home/${USER}/bin/common.sh"

[[ -z "$SKYPE_USER" ]]    && error "SKYPE_USER variable is not defined"    && exit 1
[[ -z "$SKYPE_PASSWD" ]]  && error "SKYPE_PASSWD variable is not defined"  && exit 1

echo "${SKYPE_USER}" "${SKYPE_PASSWD}" | /usr/bin/skype --pipelogin &>"${LOG_FILE}" &

/home/${USER}/bin/vpn_1.sh --status
VPN_1_Connected=$?
[[ ${VPN_1_Connected} -eq 1 ]] && /home/${USER}/bin/vpn_1.sh --connect 

/home/${USER}/bin/vpn_2.sh --status
VPN_2_Connected=$?
[[ ${VPN_2_Connected} -eq 1 ]] && /home/${USER}/bin/vpn_2.sh --connect 

# If Q Messenger is running, will not run again
/home/${USER}/bin/qmsgr.sh

# If VMWare Horizon is running, will not run again
/home/${USER}/bin/desktop.sh

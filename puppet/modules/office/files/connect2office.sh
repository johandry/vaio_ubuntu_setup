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

# If VPN is already connected will not connect again
/home/${USER}/bin/vpn.sh --connect 

# If Q Messenger is running, will not run again
/home/${USER}/bin/qmsgr.sh

# If VMWare Horizon is running, will not run again
/home/${USER}/bin/desktop.sh

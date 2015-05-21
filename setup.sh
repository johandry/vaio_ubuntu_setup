#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Setup my Sony VAIO VGN-FW139E with Ubuntu MATE
# Description: Will install several programs required for Development and DepOps activities. It will install Puppet to provision and manage the content of the computer.
#=======================================================================================================

declare -r ANYCONNECT_URL=https://www.auckland.ac.nz/content/dam/uoa/central/for/current-students/postgraduate-students/documents/anyconnect-predeploy-linux-64-3.1.04072-k9.tar
declare -r VMWARE_HORIZON_CLIENT_URL=https://download3.vmware.com/software/view/viewclients/CART14Q4/VMware-Horizon-Client-3.2.0-2331566.x86.bundle 

declare -r SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
declare -r LOG_FILE=/tmp/vaio_ubuntu_setup.log

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

init () {
  > "${LOG_FILE}"
  info "Starting setup"
  START_T=$(date +%s)
}

create_SSH_Key () {
  [[ -e ~/.ssh/id_rsa ]] && info "SSH Key exists therefore was not created" && return 1

  rm -f ~/.ssh/id_rsa*
  ssh-keygen -N "" -f ~/.ssh/id_rsa -t rsa -b 4096 -C "Johandry's Sony VAIO Ubuntu"
  echo "Go to: https://github.com/settings/ssh"
  echo "Click on 'Add SSH key'. Set the title 'Git - Sony VAIO Ubuntu' and copy the following key:"
  cat ~/.ssh/id_rsa.pub
  echo
  echo "click on 'Add key' and delete any previous key from Johandry's Sony VAIO Ubuntu"
  echo "Press Enter when ready"
  read

  ok "SSH Key created"
}

create_Workspace () {
  [[ -d /home/$USER/Workspace/vaio_ubuntu_setup ]] && info "Workspace exists therefore was not created" && return 1

  info "Creating Workspace"
  mkdir -p /home/$USER/Workspace

  info "Cloning the VAIO UbunTU Setup project"
  git clone git@github.com:johandry/vaio_ubuntu_setup.git /home/$USER/Workspace/vaio_ubuntu_setup && cd !$

  git config --global user.name "Johandry Amador"
  git config --global user.email johandry@gmail.com

  ok "Workspace directory created and git was setup"
}

update_OS () {
  info "Updating Ubuntu"
  sudo apt-get -y update
  sudo apt-get -y upgrade
  ok "Ubuntu is updated"
}

install_Cisco_AnyConnect_VPN_Client () {
  if [[ -e /opt/cisco/anyconnect/bin/vpnui ]]
    then
    info "Cisco AnyConnect VPN Client installed therefore was not installed" 
  else
    info "Installing Cisco AnyConnect VPN Client"
    # Download the client 64-bits version
    # Source: https://www.auckland.ac.nz/en/for/current-students/cs-current-pg/cs-current-pg-support/vpn/cs-cisco-vpn-client-for-linux.html
    wget "${ANYCONNECT_URL}" -O /tmp/anyconnect.tar

    # Is it Required???
    # Install Network Manager OpenConnect
    # Source: http://askubuntu.com/questions/154699/how-do-i-install-the-cisco-anyconnect-vpn-client
    sudo apt-get install -y network-manager-openconnect-gnome

    # Untar and install
    # Source: http://oit.ua.edu/wp-content/uploads/2014/08/Linux.pdf
    # Source: https://www.auckland.ac.nz/en/for/current-students/cs-current-pg/cs-current-pg-support/vpn/cs-cisco-vpn-client-for-linux.html
    # Dependency: update_OS
    mkdir -p /tmp/anyconnect
    tar xf /tmp/anyconnect.tar -C /tmp/anyconnect
    cd /tmp/anyconnect/*/vpn/
    sudo ./vpn_install.sh

    ok "Cisco AnyConnect VPN Client installed"
  fi

  info "Starting Cisco AnyConnect VPN Service"
  # Start service
  sudo systemctl start vpnagentd.service
  sudo systemctl status vpnagentd.service

  info "If Service is not working, try restart Ubuntu"

  info "Connect to the VPN to get the profile"
  /opt/cisco/anyconnect/bin/vpnui

  ok "Cisco AnyConnect VPN Client installed"
}

install_VMWare_Horizon_Client () {
  # Install dependencies. These packages are 32-bit version
  sudo dpkg --add-architecture i386
  sudo apt-get -y update
  sudo apt-get -y install libxml2:i386 libssl1.0.0:i386 libXtst6:i386 libudev1:i386 libpcsclite1:i386 libtheora0:i386 libv4l-0:i386 libpulse0:i386 freerdp-x11 libatk1.0-0:i386 libgdk-pixbuf2.0-0:i386 libgtk2.0-0:i386 libxss1:i386
  sudo ln -sf /lib/i386-linux-gnu/libudev.so.1 /lib/i386-linux-gnu/libudev.so.0
  sudo ln -sf /lib/i386-linux-gnu/libssl.so.1.0.0 /lib/i386-linux-gnu/libssl.so.1.0.1
  sudo ln -sf /lib/i386-linux-gnu/libcrypto.so.1.0.0 /lib/i386-linux-gnu/libcrypto.so.1
  sudo ln -sf /lib/i386-linux-gnu/libcrypto.so.1.0.0 /lib/i386-linux-gnu/libcrypto.so.1.0.1

  # Downloading VMWare Horizon Client
  wget ${VMWARE_HORIZON_CLIENT_URL} -O /tmp/VMware-Horizon-Client.bundle

  info "Do NOT select USB, Printing or any other extra feature. Just the basics"
  chmod +x /tmp/VMware-Horizon-Client.bundle
  sudo /tmp/VMware-Horizon-Client.bundle

  # Source: https://communities.vmware.com/thread/499473

  # TODO: Add it to the menu
}

install_Chrome () {
  wget -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg --install /tmp/google-chrome-stable_current_amd64.deb
  # If this does not work, try open http://www.google.com/intl/us_US/chrome/browser/ and download manually.
}

cleanup () {
  [[ ! -d ~/Setup ]] && info "Setup directory does not exists therefore was not deleted" && return 1
  cd
  rm -rf ~/Setup
  ok "~/Setup directory deleted"
}

finish () {
  END_T=$(date +%s)
  ok "Setup completed in $(($END_T - $START_T)) seconds"
}

setup () {
  create_SSH_Key
  create_Workspace
  update_OS
  install_Cisco_AnyConnect_VPN_Client
  install_VMWare_Horizon_Client
  install_Chrome
  cleanup
}

init
#setup
finish

#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Setup my Sony VAIO VGN-FW139E with Ubuntu MATE
# Description: Will install several programs required for Development and DepOps activities. It will install Puppet to provision and manage the content of the computer.
#=======================================================================================================

declare -r PUPPET_VERSION="3.7.2"
declare -r PUPPET_URL="https://apt.puppetlabs.com/puppetlabs-release-utopic.deb"
declare -r VMWARE_HORIZON_CLIENT_URL="https://download3.vmware.com/software/view/viewclients/CART14Q4/VMware-Horizon-Client-3.2.0-2331566.x86.bundle"

declare -r username=johandry

declare -r SETUP_DIR="$( cd "$( dirname "$0" )" && pwd )"
source "${SETUP_DIR}/puppet/modules/base/files/common.sh"


init () {
  [[ $EUID -ne 0 ]] && error "This script must be run as root. Not with sudo" && exit 1

  > "${LOG_FILE}"
  info "Starting setup"
  START_T=$(date +%s)
}

install_Puppet () {
  [[ "$(/usr/bin/puppet --version)" == "${PUPPET_VERSION}" ]] && info "Puppet ${PUPPET_VERSION} is installed" && return 1
  info "Installing puppet"

  wget -O /tmp/puppetlabs-release.deb ${PUPPET_URL}
  dpkg -i /tmp/puppetlabs-release.deb
  apt-get update
  apt-get install -y puppet
  sed -i.bkp 's/^127.0.1.1\tvaio$/127.0.1.1\tvaio.johandry.com\tvaio/' /etc/hosts

  info "Setting puppet manifests and modules"
  BKP_DATE=$(date +"%m%d%Y%H%M%S")
  mv /etc/puppet/manifests /etc/puppet/manifests.$BKP_DATE
  mv /etc/puppet/modules   /etc/puppet/modules.$BKP_DATE
  cp -a "${SCRIPT_DIR}/puppet/manifests" /etc/puppet/
  cp -a "${SCRIPT_DIR}/puppet/modules"   /etc/puppet/
  chown -R root.root /etc/puppet/manifests
  chown -R root.root /etc/puppet/modules

  [[ "$(/usr/bin/puppet --version)" == "${PUPPET_VERSION}" ]] && ok "Puppet ${PUPPET_VERSION} successfuly installed" && return 0
  error "Puppet ${PUPPET_VERSION} install have failed"
}

install_VMWare_Horizon_Client () {
#  # Downloading VMWare Horizon Client
#  info "Downloading VMWare Horizon Client"
#  wget ${VMWARE_HORIZON_CLIENT_URL} -O /tmp/VMware-Horizon-Client.bundle
#  chmod +x /tmp/VMware-Horizon-Client.bundle
  info "Install and setup VMWare Horizon Client"
  sudo /tmp/VMware-Horizon-Client.bundle

  # Source: https://communities.vmware.com/thread/499473

  # TODO: Add it to the menu
}

finish () {
  END_T=$(date +%s)
  info "Setup completed in $(($END_T - $START_T)) seconds"
}

setup () {
  install_Puppet
}

execute () {
  setupGithub=
  [[ ! -e /home/${username}/.ssh/id_rsa.pub ]] && setupGithub=true

  sudo puppet apply -v /etc/puppet/manifests/site.pp

  if [[ -n "${setupGithub}" ]]
    then
    info "Go to: https://github.com/settings/ssh"
    info "Click on 'Add SSH key'. Set the title 'Git - Sony VAIO Ubuntu' and copy the following key:"
    echo
    cat /home/${username}/.ssh/id_rsa.pub
    echo
    info "click on 'Add key' and delete any previous key from Sony VAIO with Ubuntu"
    info "Press Enter when ready"
    read
  fi

  [[ ! -e /usr/bin/vmware-view ]] && install_VMWare_Horizon_Client
}

init
setup
execute
finish


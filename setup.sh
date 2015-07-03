#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Setup my Sony VAIO VGN-FW139E with Ubuntu MATE
#
# Usage: {script_name} [ -h | --help | --cleanup ]
#
# Options:
#     -h, --help		Display this help message. bash {script_name} -h
#     --deploy          Commit and push changes to github
#
# Description: Will install several programs required for Development and DepOps activities, install Puppet to provision and manage the content of the computer.
#
# Report Issues or create Pull Requests in http://github.com/johandry/vaio_ubuntu_setup/
#=======================================================================================================

declare -r PUPPET_VERSION="3.7.2"
declare -r PUPPET_URL="https://apt.puppetlabs.com/puppetlabs-release-utopic.deb"

declare -r SETUP_DIR="$( cd "$( dirname "$0" )" && pwd )"
source "${SETUP_DIR}/puppet/modules/scripts/files/common.sh"

init () {
  > "${LOG_FILE}"
  info "Starting setup"
  START_T=$(date +%s)
}

install_Puppet () {
  [[ "$(/usr/bin/puppet --version)" == "${PUPPET_VERSION}" ]] && info "Puppet ${PUPPET_VERSION} is installed" && return 1
  info "Installing puppet"

  wget -O /tmp/puppetlabs-release.deb ${PUPPET_URL}
  sudo dpkg -i /tmp/puppetlabs-release.deb
  sudo apt-get update
  sudo apt-get install -y puppet
  sudo sed -i.bkp 's/^127.0.1.1\tvaio$/127.0.1.1\tvaio.johandry.com\tvaio/' /etc/hosts

  [[ "$(/usr/bin/puppet --version)" == "${PUPPET_VERSION}" ]] && ok "Puppet ${PUPPET_VERSION} successfully installed" && return 0
  error "Puppet ${PUPPET_VERSION} install have failed"
}

install_VMWare_Horizon_Client () {
  [[ -e /usr/bin/vmware-view ]] && info "VMWare Horizon Client is installed" && return 1

#  # Downloading VMWare Horizon Client
#  info "Downloading VMWare Horizon Client"
#  wget ${VMWARE_HORIZON_CLIENT_URL} -O /tmp/VMware-Horizon-Client.bundle
#  chmod +x /tmp/VMware-Horizon-Client.bundle
  info "Install and setup VMWare Horizon Client"
  sudo /tmp/VMware-Horizon-Client.bundle

  # Source: https://communities.vmware.com/thread/499473

  # TODO: Add it to the menu
}

setup () {
  init 

  install_Puppet

  ${SCRIPT_DIR}/update.sh

  install_VMWare_Horizon_Client

  finish
}

finish () {
  END_T=$(date +%s)
  info "Setup completed in $(($END_T - $START_T)) seconds"

  rm -rf ${HOME}/Setup
}

deploy () {
  [[ -z "${1}" ]] && error "Need a commit message to deploy" && exit 1

  TO_DELETE=$( git ls-files --delete )
  [[ -n ${TO_DELETE} ]] && git rm "${TO_DELETE}"
  cd "${SCRIPT_DIR}"
  git add .
  git commit -a -m "${1}"
  git push origin master
}

[[ -z "${1}" ]]             && setup          && exit 0

[[ "${1}" == "--deploy" ]]  && deploy "${2}"  && exit 0

error "Unknown option ${1}"
exit 1

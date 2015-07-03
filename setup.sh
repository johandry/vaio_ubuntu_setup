#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Setup my Sony VAIO VGN-FW139E with Ubuntu MATE
#
# Usage: {script_name} [ -h | --help | --cleanup ]
#
# Options:
#     -h, --help		Display this help message. bash {script_name} -h
#     --cleanup			Remove temporal files and backups
#     --deploy          Commit and push changes to github
#
# Description: Will install several programs required for Development and DepOps activities. It will install Puppet to provision and manage the content of the computer.
#
# Report Issues or create Pull Requests in http://github.com/johandry/vaio_ubuntu_setup/
#=======================================================================================================

declare -r PUPPET_VERSION="3.7.2"
declare -r PUPPET_URL="https://apt.puppetlabs.com/puppetlabs-release-utopic.deb"
# declare -r VMWARE_HORIZON_CLIENT_URL="https://download3.vmware.com/software/view/viewclients/CART14Q4/VMware-Horizon-Client-3.2.0-2331566.x86.bundle"

declare -r SETUP_DIR="$( cd "$( dirname "$0" )" && pwd )"
source "${SETUP_DIR}/puppet/modules/scripts/files/common.sh"

init () {
  ## [[ $EUID -ne 0 ]] && error "This script must be run as root. Not with sudo" && exit 1

  > "${LOG_FILE}"
  info "Starting setup"
  START_T=$(date +%s)

  setupGithub=
  [[ ! -e ${HOME}/.ssh/id_rsa.pub ]] && setupGithub=true

  if [[ -z "${GPG_PASSWD}" ]]
    then
    info "Enter GPG password to encrypt files"
    read -p "GPG Password: " -r -s GPG_PASSWD
    echo
  fi
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

setup_Github () {
  [[ -z "${setupGithub}" ]] && info "Github is configured" && return 1

  info "Go to: https://github.com/settings/ssh"
  info "Click on 'Add SSH key'. Set the title 'Git - Sony VAIO Ubuntu' and copy the following key:"
  echo
  cat ${HOME}/.ssh/id_rsa.pub
  echo
  info "click on 'Add key' and delete any previous key from Sony VAIO with Ubuntu"
  info "Press Enter when ready"
  read
}

setup () {
  install_Puppet

  ${SCRIPT_DIR}/update.sh

  setup_Github

  install_VMWare_Horizon_Client
}

finish () {
  END_T=$(date +%s)
  info "Setup completed in $(($END_T - $START_T)) seconds"

  rm -rf ${HOME}/Setup
}

cleanup () {
  info "Deleting old backups of puppet manifests, modules and hiera data"
  sudo rm -rf /var/puppet/backups/*

  exit 0
}

deploy () {
  [[ -z "${1}" ]] && error "Need a commit message to deploy" && exit 1
  TO_DELETE=$( git ls-files --delete )
  [[ -n ${TO_DELETE} ]] && git rm "${TO_DELETE}"
  cd "${SCRIPT_DIR}"
  git add .
  git commit -a -m "${1}"
  git push origin master

  exit 0
}

main () {
  init
  setup
  finish

  exit 0
}

[[ "${1}" == "-p" && -n "${2}" ]] && GPG_PASSWD="${2}"

[[ -z "${1}" ]]             && main

[[ "${1}" == "--cleanup" ]] && cleanup

[[ "${1}" == "--deploy" ]]  && deploy "${2}"

error "Unknown option ${1}" && exit 1

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
#     --gpg             Encrypt the personal settings and move it to the project repository
#     --deploy          Commit and push changes to github
#
# Description: Will install several programs required for Development and DepOps activities. It will install Puppet to provision and manage the content of the computer.
#
# Report Issues or create Pull Requests in http://github.com/johandry/vaio_ubuntu_setup/
#=======================================================================================================

declare -r USERNAME=johandry

declare -r PUPPET_VERSION="3.7.2"
declare -r PUPPET_URL="https://apt.puppetlabs.com/puppetlabs-release-utopic.deb"
declare -r VMWARE_HORIZON_CLIENT_URL="https://download3.vmware.com/software/view/viewclients/CART14Q4/VMware-Horizon-Client-3.2.0-2331566.x86.bundle"

declare -r SETUP_DIR="$( cd "$( dirname "$0" )" && pwd )"
source "${SETUP_DIR}/puppet/modules/base/files/common.sh"

init () {
  ## [[ $EUID -ne 0 ]] && error "This script must be run as root. Not with sudo" && exit 1

  > "${LOG_FILE}"
  info "Starting setup"
  START_T=$(date +%s)

  setupGithub=
  [[ ! -e /home/${USERNAME}/.ssh/id_rsa.pub ]] && setupGithub=true
}

install_Puppet () {
  [[ "$(/usr/bin/puppet --version)" == "${PUPPET_VERSION}" ]] && info "Puppet ${PUPPET_VERSION} is installed" && return 1
  info "Installing puppet"

  wget -O /tmp/puppetlabs-release.deb ${PUPPET_URL}
  sudo dpkg -i /tmp/puppetlabs-release.deb
  sudo apt-get update
  sudo apt-get install -y puppet
  sudo sed -i.bkp 's/^127.0.1.1\tvaio$/127.0.1.1\tvaio.johandry.com\tvaio/' /etc/hosts

  [[ "$(/usr/bin/puppet --version)" == "${PUPPET_VERSION}" ]] && ok "Puppet ${PUPPET_VERSION} successfuly installed" && return 0
  error "Puppet ${PUPPET_VERSION} install have failed"
}

install_manifests_n_modules () {
  [[ ! -d /etc/puppet/manifests ]] && error "Puppet is not installed or there is no manifests to install" && return 1

  diff_modules=$( diff -qr "${SCRIPT_DIR}/puppet/modules" /etc/puppet/modules | grep -v personal-settings.sh )
  diff_manifests=$( diff -qr "${SCRIPT_DIR}/puppet/manifests" /etc/puppet/manifests )
  [[ -z "${diff_modules}" && -z "${diff_manifests}" ]] && info "Puppet manifests and modules are up to date" && return 1
  info "Installing latest puppet manifests and modules"

  BKP_DATE=$(date +"%m%d%Y%H%M%S")

  sudo mv /etc/puppet/manifests /etc/puppet/manifests.$BKP_DATE
  sudo mv /etc/puppet/modules   /etc/puppet/modules.$BKP_DATE
  sudo cp -a "${SCRIPT_DIR}/puppet/manifests" /etc/puppet/
  sudo cp -a "${SCRIPT_DIR}/puppet/modules"   /etc/puppet/
  sudo chown -R root.root /etc/puppet/manifests
  sudo chown -R root.root /etc/puppet/modules

  info "Enter password to decrypt the personal settings file"
  gpg "${SCRIPT_DIR}/puppet/modules/base/files/personal-settings.sh.gpg"
  sudo mv  "${SCRIPT_DIR}/puppet/modules/base/files/personal-settings.sh" /etc/puppet/modules/base/files/
  sudo rm  /etc/puppet/modules/base/files/personal-settings.sh.gpg

  [[ -e /etc/puppet/manifests/site.pp && -d /etc/puppet/manifests.$BKP_DATE && -d /etc/puppet/modules.$BKP_DATE ]] && ok "Puppet manifests and modules were installed and backup done with id ${BKP_DATE}" && return 0
  error "Puppet manifests and modules were not installed correctly"
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
  cat /home/${USERNAME}/.ssh/id_rsa.pub
  echo
  info "click on 'Add key' and delete any previous key from Sony VAIO with Ubuntu"
  info "Press Enter when ready"
  read
}

setup () {

  install_Puppet

  install_manifests_n_modules

  info "Applying puppet rules"
  sudo puppet apply -v /etc/puppet/manifests/site.pp

  setup_Github

  install_VMWare_Horizon_Client
}

finish () {
  END_T=$(date +%s)
  info "Setup completed in $(($END_T - $START_T)) seconds"

  rm -rf /home/$USERNAME/Setup
}

cleanup () {
  info "Deleting old backups of puppet manifests and modules"
  sudo rm -rf /etc/puppet/modules.*
  sudo rm -rf /etc/puppet/manifests.*
}

update_personal_settings () {
  info "Enter password to encrypt the personal settings file"
  sudo cp /etc/profile.d/personal-settings.sh ${HOME}
  sudo chown $USERNAME ${HOME}/personal-settings.sh
  gpg -c ${HOME}/personal-settings.sh
  rm -f ${HOME}/personal-settings.sh
  mv -f ${HOME}/personal-settings.sh.gpg "${SCRIPT_DIR}/puppet/modules/base/files"
}

deploy () {
  [[ -z "${1}" ]] && error "Need a commit message to deploy" && exit 1

  update_personal_settings

  [[ -e "${SCRIPT_DIR}/puppet/modules/base/files/personal-settings.sh" ]] && error "The personals settings file cannot be deployed to Github" && error 1

  cd "${SCRIPT_DIR}"
  git add .
  git commit -a -m "${1}"
  git push origin master
}

[[ "${1}" == "--cleanup" ]] && cleanup && exit 0

[[ "${1}" == "--gpg" ]] && update_personal_settings && exit 0

[[ "${1}" == "--deploy" ]] && deploy "${2}" && exit 0

[[ -n "${1}" ]] && error "Unknown option ${1}" && exit 1

init
setup
finish


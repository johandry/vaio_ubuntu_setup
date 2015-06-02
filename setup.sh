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
# declare -r VMWARE_HORIZON_CLIENT_URL="https://download3.vmware.com/software/view/viewclients/CART14Q4/VMware-Horizon-Client-3.2.0-2331566.x86.bundle"

declare -r SETUP_DIR="$( cd "$( dirname "$0" )" && pwd )"
source "${SETUP_DIR}/puppet/modules/base/files/common.sh"

init () {
  ## [[ $EUID -ne 0 ]] && error "This script must be run as root. Not with sudo" && exit 1

  > "${LOG_FILE}"
  info "Starting setup"
  START_T=$(date +%s)

  setupGithub=
  [[ ! -e /home/${USERNAME}/.ssh/id_rsa.pub ]] && setupGithub=true

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

  [[ "$(/usr/bin/puppet --version)" == "${PUPPET_VERSION}" ]] && ok "Puppet ${PUPPET_VERSION} successfuly installed" && return 0
  error "Puppet ${PUPPET_VERSION} install have failed"
}

decrypt_file () {
  file="$1"
  target="$2"

  if [[ -n "${GPG_PASSWD}" ]]
    then
    info "Decrypting ${file##*/}"
    echo "${GPG_PASSWD}" | gpg --no-tty -q --passphrase-fd 0 --yes "${file}.gpg" &>>"${LOG_FILE}"
    [[ $? -ne 0 ]] && error "Decrypting ${file##*/}"
  else
    info "Enter password to decrypt the file ${file}.gpg"
    gpg "${file}.gpg"
  fi

  # Move the decrypted file to puppet module, it cannot be in the project repository
  sudo mv -f "${file}" "${target}"
}

install_manifests_n_modules () {
  [[ ! -d /etc/puppet ]] && error "Puppet is not installed or there is no manifests to install" && return 1

  info "Installing latest puppet manifests and modules"

  BKP_DATE=$(date +"%m%d%Y%H%M%S")

  # Backups
  sudo mkdir -p /etc/puppet/backup/${BKP_DATE}

  for artifact in "${SCRIPT_DIR}"/puppet/*
  do
    artifact_name=${artifact##*/}
    sudo mv -f /etc/puppet/${artifact_name} /etc/puppet/backup/${BKP_DATE}/
  done

  sudo cp -a "${SCRIPT_DIR}"/puppet/* /etc/puppet/

  sudo chown -R root.root /etc/puppet

  decrypt_file "${SCRIPT_DIR}/puppet/modules/base/files/personal-settings.sh" "/etc/puppet/modules/base/files/"
  decrypt_file "${SCRIPT_DIR}/puppet/modules/office/files/VPN connection 1" "/etc/puppet/modules/office/files/"
  decrypt_file "${SCRIPT_DIR}/puppet/modules/base/files/ssh-settings.tar.gz" "/etc/puppet/modules/base/files/"

  [[ -e /etc/puppet/manifests/site.pp && -d /etc/puppet/backup/${BKP_DATE} ]] && ok "Puppet manifests and modules were installed and backup done with id ${BKP_DATE}" && return 0
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
  info "Deleting old backups of puppet manifests, modules and hiera data"
  sudo rm -rf /etc/puppet/backups/*

  exit 0
}

encrypt_file () {
  file="$1"
  target="$2"
  filename=${file##*/}

  [[ -z "${GPG_PASSWD}" ]] && info "Enter password to encrypt the file ${filename}"

  # Copy the file to a temporal place
  sudo cp "${file}" ${HOME}
  sudo chown $USERNAME "${HOME}/${filename}"

  info "Encrypting ${filename}"
  echo "${GPG_PASSWD}" | gpg --no-tty -q --passphrase-fd 0 --yes -c "${HOME}/${filename}" 2>&1 >>"${LOG_FILE}"
  [[ $? -ne 0 ]] && error "Decrypting ${file##*/}"

  # Remove the file from the temporal place and move it to the target location
  rm -f "${HOME}/${filename}"
  mv -f "${HOME}/${filename}.gpg" "${target}"
}

update_encrypted_files () {
  encrypt_file "/etc/profile.d/personal-settings.sh" "${SCRIPT_DIR}/puppet/modules/base/files"

  encrypt_file "/etc/NetworkManager/system-connections/VPN connection 1" "${SCRIPT_DIR}/puppet/modules/office/files"

  mkdir -p /tmp/ssh-settings
  cp ${HOME}/.ssh/id_rsa ${HOME}/.ssh/id_rsa.pub ${HOME}/.ssh/config /tmp/ssh-settings
  cd /tmp/ssh-settings && tar czf /tmp/ssh-settings.tar.gz . 2>/dev/null
  [[ $? -ne 0 ]] && error "Compressing SSH settings"
  rm -rf /tmp/ssh-settings
  encrypt_file "/tmp/ssh-settings.tar.gz" "${SCRIPT_DIR}/puppet/modules/base/files"
}

deploy () {
  [[ -z "${1}" ]] && error "Need a commit message to deploy" && exit 1

  update_encrypted_files

  [[ -e "${SCRIPT_DIR}/puppet/modules/base/files/personal-settings.sh" ]] && error "The personals settings file cannot be deployed to Github" && exit 1
  [[ -e "${SCRIPT_DIR}/puppet/modules/office/files/VPN_connection" ]] && error "The VPN connection file cannot be deployed to Github" && exit 1

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

[[ "${1}" == "--gpg" ]]     && update_encrypted_files && exit 0

[[ "${1}" == "--deploy" ]]  && deploy "${2}"

error "Unknown option ${1}" && exit 1

#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Update my Sony VAIO VGN-FW139E with Ubuntu MATE
#
# Usage: {script_name} [ -h | --help | --cleanup ]
#
# Options:
#     -h, --help		Display this help message. bash {script_name} -h
#
# Description: Will install several programs required for Development and DepOps activities with Puppet
#
# Report Issues or create Pull Requests in http://github.com/johandry/vaio_ubuntu_setup/
#=======================================================================================================

source "${HOME}/bin/common.sh"

FORCE_UPDATE=

# Options for puppet
# DEBUG="--debug"
VERBOSE="--verbose"

init () {
  > "${LOG_FILE}"
  info "Starting setup"
  START_T=$(date +%s)

  if [[ -z "${GPG_PASSWD}" ]]
    then
    info "Enter GPG password to encrypt/decrypt files"
    read -p "GPG Password: " -r -s GPG_PASSWD
    echo
  fi
}

update_puppet () {
  [[ ! -d /etc/puppet ]] && error "Puppet is not installed" && return 1

  info "Installing latest puppet rules"

  cd "${SCRIPT_DIR}/puppet"
  git add .
  git commit -m "Update"
  git push origin master

  cd /etc/puppet
  sudo git pull origin master

  # decrypt_keys  

  [[ -e /etc/puppet/manifests/site.pp ]] && ok "Puppet rules were updated and backup done in /var/puppet/backup/${BKP_DATE}" && return 0
  error "Puppet manifests and modules were not installed correctly"
}

update () {
  init

  update_puppet

  info "Applying puppet rules"
  sudo puppet  apply ${DEBUG} ${VERBOSE} /etc/puppet/manifests/site.pp

  finish

  exit 0
}

finish () {
  END_T=$(date +%s)
  info "Setup completed in $(($END_T - $START_T)) seconds"
}

cleanup () {
  info "Deleting old backups of puppet manifests, modules and hiera data"
  sudo rm -rf /var/puppet/backups/*

  exit 0
}

encrypt_keys () {
  file="$1"

  target="${SCRIPT_DIR}/puppet/modules/files/files"
  filename=${file##*/}

  if [[ -n "${GPG_PASSWD}" ]]
    then
    info "Encrypting ${filename}"
    echo "${GPG_PASSWD}" | gpg --no-tty -q --passphrase-fd 0 --yes -c "${file}" 2>&1 >>"${LOG_FILE}"
    [[ $? -ne 0 ]] && error "Decrypting ${file##*/}"
  else
    info "Enter password to encrypt the file ${filename}"
    gpg -c "${file}.gpg"
  fi

  mv -f "${file}.gpg" "${target}"
}

create_keys_directory () {
  TMP_KEYS="${1}"

  filename="config.tar.gz"
  source_dir="/etc/puppet/secure/keys"
  

  sudo cp -a ${source_dir}/* "${TMP_KEYS}"
  cd "${TMP_KEYS}" && sudo tar czf "${filename}" . 2>/dev/null
  [[ $? -ne 0 ]] && error "Compressing ${filename}" && return 1

  sudo chown ${USER} "${file}"
}

decrypt_keys () {
  TMP_KEYS="${1}"

  file="${SCRIPT_DIR}/puppet/modules/puppet/files/config.tar.gz"
  target_1="/etc/puppet/modules/puppet/files/"
  target_2="/etc/puppet/secure/keys"

  if [[ -n "${GPG_PASSWD}" ]]
    then
    info "Decrypting ${file##*/}"
    echo "${GPG_PASSWD}" | gpg --no-tty -q --passphrase-fd 0 --yes "${file}.gpg" &>>"${LOG_FILE}"
    [[ $? -ne 0 ]] && error "Decrypting ${file##*/}"
  else
    info "Enter password to decrypt the file ${file}.gpg"
    gpg "${file}.gpg"
  fi

  mkdir -p $TMP_KEYS
  mv -f "${file}" $TMP_KEYS
  cd $TMP_KEYS

  tar xzf ${file##*/} && rm ${file##*/}

  sudo cp $TMP_KEYS/* "${target_1}"
  sudo mkdir -p "${target_2}" && sudo chmod -R 0775 "${target_2%/*}"
  sudo cp $TMP_KEYS/* "${target_2}"

  rm -rf $TMP_KEYS
}

update_keys () {
  TMP_KEYS="/tmp/keys"

  create_keys_directory "${TMP_KEYS}"

  encrypt_file "${TMP_KEYS}/config.tar.gz"

  decrypt_keys "${TMP_KEYS}"

  sudo rm -rf "${TMP_KEYS}"

  exit 0
}

[[ "${1}" == "-p" && -n "${2}" ]] && GPG_PASSWD="${2}"

[[ "${1}" == "--force" ]]     && FORCE_UPDATE=true

[[ "${1}" == "--cleanup" ]]   && cleanup

[[ -z "${1}" || "--force" ]]  && update
[[ "${1}" == "--keys" ]]      && update_keys

error "Unknown option ${1}"   && exit 1

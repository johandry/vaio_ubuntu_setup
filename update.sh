#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Update my Sony VAIO VGN-FW139E with Ubuntu MATE
#
# Usage: {script_name} [ -h | --help | --cleanup ]
#
# Options:
#     -h, --help		Display this help message.
#     -keys         Update the Hiedra-eyaml keys. Use this option if you update the keys in puppet. The 
#
# Description: Will install several programs required for Development and DepOps activities with Puppet
#
# Report Issues or create Pull Requests in http://github.com/johandry/vaio_ubuntu_setup/
#=======================================================================================================

if [[ -e "${HOME}/bin/common.sh" ]]
  then
  source "${HOME}/bin/common.sh"
else
  declare -r SETUP_DIR="$( cd "$( dirname "$0" )" && pwd )"
  source "${SETUP_DIR}/puppet/modules/scripts/files/common.sh"
fi

FORCE_UPDATE=

# Options for puppet
# DEBUG="--debug"
VERBOSE="--verbose"

init () {
  > "${LOG_FILE}"
  info "Starting setup"
  START_T=$(date +%s)
}

update_puppet () {
  [[ ! -d /etc/puppet ]] && error "Puppet is not installed" && exit 1

  info "Installing latest puppet rules"

  cd "${SCRIPT_DIR}/puppet"
  git remote -v | grep -q /var/git/puppet || git remote add origin /var/git/puppet
  git add .
  git commit -m "Update"
  sudo git push origin master
  echo tt

  cd /etc/puppet
  sudo git pull origin master 
  echo test

  [[ -e /etc/puppet/manifests/site.pp ]] && ok "Puppet manifests is set" && return 0
  error "Puppet manifests was not set"
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

update_keys () {

  TMP_KEYS="/tmp/keys"
  file="config.tar.gz"
  source_dir="/etc/puppet/secure/keys"
  target_dir="${SCRIPT_DIR}/puppet/modules/puppet/files"

  info "Creating an encrypted file with the Hiera-eyaml keys"

  # Copy keys to a temporal folder to compress and have one single file.
  mkdir -p "${TMP_KEYS}"
  sudo cp ${source_dir}/*.pem "${TMP_KEYS}"
  cd "${TMP_KEYS}" && sudo tar czf "${file}" *.pem 2>/dev/null
  [[ $? -ne 0 ]] && error "Compressing ${file}" && exit 1
  sudo chown ${USER} "${TMP_KEYS}/${file}"

  # Encrypt the compressed file with the keys
  if [[ -n "${GPG_PASSWD}" ]]
    then
    info "Encrypting ${file}"
    echo "${GPG_PASSWD}" | gpg --no-tty -q --passphrase-fd 0 --yes -c "${TMP_KEYS}/${file}" 2>&1 >>"${LOG_FILE}"
    [[ $? -ne 0 ]] && error "Encrypting ${file##*/}" && exit 1
  else
    info "Enter password to encrypt the file ${file}"
    gpg -c "${TMP_KEYS}/${file}"
    [[ $? -ne 0 ]] && error "Encrypting ${file##*/}" && exit 1
  fi

  # Move the encrypted and compressed file with the keys to the project, so it can be in GitHub
  mv -f "${TMP_KEYS}/${file}.gpg" "${target_dir}"

  ok "Encrypted keys for Hhiera-eyaml are in the project workspace ready to be in GitHub"
  sudo rm -rf "${TMP_KEYS}"

  exit 0
}

[[ -z "${1}" ]]           && update
[[ "${1}" == "--keys" ]]  && update_keys

error "Unknown option ${1}"   && exit 1

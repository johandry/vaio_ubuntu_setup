#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Office functions
#
# Usage: 
#   File to be placed in /etc/profile.d/ so it can be loaded by the /etc/profile
# 
# Description: This file contain functions and aliases used in the office.
# 
# Report Issues or create Pull Requests in http://github.com/johandry/vaio_ubuntu_setup/
#=======================================================================================================

export FF_SERVER_FILE="/home/$USER/.serverffs.lst"

export SL_SERVER_FILE="/home/$USER/.serversls.lst"

serverff () {
  [[ ${1} == "--refresh" ]] && info "Updating the FF servers from Puppet" && ssh -q ${UNIX_USER}@${PUPPET_FF} "sudo rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production node:list" | sort | grep -v "/opt/bmc" | grep -v '(in /' > "${FF_SERVER_FILE}"

  [[ -z ${1} ]] && cat "${FF_SERVER_FILE}"
}
export -f serverff

serversl () {
  [[ ${1} == "--refresh" ]] && info "Updating the SL servers from Puppet" && ssh -q ${UNIX_USER}@${PUPPET_SL} "sudo rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production node:list" | sort > "${SL_SERVER_FILE}"

  [[ -z ${1} ]] && cat "${SL_SERVER_FILE}"
}
export -f serversl

ffssh () {
  server_name=${1}
  [[ -z "${server_name}" ]] && warn "A server partial or full name is required. Using the default server" && server_name=${UNIX_FF_DEFAULT_SERVER}


  # If servers list file does not exists or it is older than 7 days, recreate the list
  [[ ! -e "${FF_SERVER_FILE}" || $(( `date +%s` - `stat -L --format %Y "${FF_SERVER_FILE}"` )) -gt $(( 7*24*60*60 )) ]] && serverff --refresh

  if [[ $( grep "${server_name}" "${FF_SERVER_FILE}" | wc -l ) -gt 1 ]]
    then
    warn "Try a longer partial name, there are more than one server matching with '${server_name}':"
    grep "${server_name}" "${FF_SERVER_FILE}" | sed "s/\.${UNIX_FF_DOMAIN}//" | sed 's/^/*  /'
    return 1
  fi

  server=$( grep "${server_name}" "${FF_SERVER_FILE}" )

  [[ -z ${server} ]] && warn "There is no server with '${server_name}' in the name" && return 1

  info "Login into ${server}"
  ssh -q ${UNIX_USER}@${server}
}
export -f ffssh

slssh () {
  server_name=${1}
  [[ -z "${server_name}" ]] && warn "A server partial or full name is required. Using the default server" && server_name=${UNIX_SL_DEFAULT_SERVER}

  # If servers list file does not exists or it is older than 7 days, recreate the list
  [[ ! -e "${SL_SERVER_FILE}" || $(( `date +%s` - `stat -L --format %Y "${SL_SERVER_FILE}"` )) -gt $(( 7*24*60*60 )) ]] && serversl --refresh

  if [[ $( grep "${server_name}" "${SL_SERVER_FILE}" | wc -l ) -gt 1 ]]
    then
    warn "Try a longer partial name, there are more than one server matching with '${server_name}':"
    grep "${server_name}" "${SL_SERVER_FILE}" | sed "s/\.${UNIX_SL_DOMAIN}//" | sed 's/^/*  /'
    return 1
  fi

  server=$( grep "${server_name}" "${SL_SERVER_FILE}" )

  [[ -z ${server} ]] && warn "There is no server with '${server_name}' in the name" && return 1

  info "Login into ${server}"
  ssh -q ${UNIX_USER}@${server}
}
export -f slssh

mssh () {
  echo "TODO"
}
export -f mssh
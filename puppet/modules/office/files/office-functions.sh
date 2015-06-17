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

export FF_SERVER_FILE="/home/$USER/.ffservers.lst"

export SL_SERVER_FILE="/home/$USER/.slservers.lst"

serverff () {
  [[ ${1} == "--refresh" ]] && ssh -q ${UNIX_USER}@/${PUPPET_FF} "sudo rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production node:list" | sort | grep -v "/opt/bmc" | grep -v '(in /' > "${FF_SERVER_FILE}"

  [[ -z ${1} ]] && cat "${FF_SERVER_FILE}"
}
export -f serverff

serversl () {
  echo "TODO"
}
export -f serversl

ffssh () {
  [[ -z "${1}" ]] && error "A server partial or full name is required" && return 1

  # If servers list file does not exists or it is older than 7 days, recreate the list
  [[ ! -e "${FF_SERVER_FILE}" || $(( `date +%s` - `stat -L --format %Y "${FF_SERVER_FILE}"` )) -gt $(( 7*24*60*60 )) ]] && serverff --refresh

  if [[ $( grep "${1}" "${FF_SERVER_FILE}" | wc -l ) -gt 1 ]]
    then
    warn "Try a longer partial name, there are more than one server matching with '${1}':"
    grep "${1}" "${FF_SERVER_FILE}" | sed "s/\.${UNIX_FF_DOMAIN}//" | sed 's/^/*  /'
    return 1
  fi

  server=$( grep "${1}" "${FF_SERVER_FILE}" )

  [[ -z ${server} ]] && warn "There is no server with '${1}' in the name" && return 1

  info "Login into ${server}"
  ssh -q ${UNIX_USER}@${server}
}
export -f ffssh

slssh () {
  echo "TODO"
}
export -f slssh

mssh () {
  echo "TODO"
}
export -f mssh
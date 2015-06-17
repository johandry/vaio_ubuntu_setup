class users (
  $username
) {

  user { "${username}":
    ensure      => "present",
    managehome  => true,
    groups      => ['docker'],
  }

  exec { 'sudo nopasswd':
    command     => 'sed -i.bak "s/%sudo.*ALL=(ALL:ALL).*ALL/%sudo\tALL=(ALL:ALL)\tNOPASSWD:ALL/" /etc/sudoers',
    unless      => "grep -q '%sudo.*ALL=(ALL:ALL).*NOPASSWD:ALL' /etc/sudoers",
    logoutput   => on_failure,
  }

}
class scripts (
  $username       = $users::username,
  $skype_username = $scripts::skype_username,
  $skype_passwd   = $scripts::skype_passwd,
  $gpg_passwd     = $scripts::gpg_passwd
) { 

  file { "/home/${username}/bin":
    ensure    => "directory",
    mode      => 0750,
    owner     => $username,
    group     => $username,
  }
  file { "/home/${username}/bin/common.sh":
    ensure    => "file",
    mode      => 0750,
    owner     => $username,
    group     => $username,
    source    => "puppet:///modules/scripts/common.sh",
  }

  file { "/home/${username}/.bashrc":
    ensure    => "file",
    mode      => 0644,
    owner     => $username,
    group     => $username,
    source    => "puppet:///modules/scripts/bashrc",
  }

  file { "/etc/profile.d/personal-settings.sh":
    ensure    => "file",
    mode      => 0640,
    owner     => $username,
    group     => $username,
    content   => template('scripts/personal-settings.erb')
  }
}
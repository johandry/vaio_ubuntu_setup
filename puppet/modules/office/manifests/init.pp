class office {

  file { "/home/${username}/bin/vpn.sh":
    ensure	=> "file",
    mode		=> 0750,
    owner		=> "${username}",
    group		=> "${username}",
    source	=> "puppet:///modules/office/vpn.sh",
    require => File["/home/${username}/bin"],
  }
  file { "/home/${username}/bin/qmsgr.sh":
    ensure	=> "file",
    mode		=> 0750,
    owner		=> "${username}",
    group		=> "${username}",
    source	=> "puppet:///modules/office/qmsgr.sh",
    require => File["/home/${username}/bin"],
  }
  file { "/home/${username}/bin/desktop.sh":
    ensure	=> "file",
    mode		=> 0750,
    owner		=> "${username}",
    group		=> "${username}",
    source	=> "puppet:///modules/office/desktop.sh",
    require => File["/home/${username}/bin"],
  }
  file { "/etc/NetworkManager/system-connections/VPN connection 1":
    ensure	=> "file",
    mode		=> 0600,
    owner		=> root,
    group		=> root,
    source	=> "puppet:///modules/office/VPN connection 1",
    require => Package["network-manager-openconnect"],
  }
}
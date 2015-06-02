class office {

  $sl_vpn_url = "http://speedtest.dal05.softlayer.com/array/ArrayNetworksL3VPN_LINUX.zip"

  # Install SoftLayer VPN. Source: http://archive.thoughtsoncloud.com/2014/08/ibm-softlayer-vpn-solution-linux-command-line-interface-clients/
  file { "/usr/local/array_vpn/":
    ensure    => "directory",
    mode      => 0755,
    owner     => "root",
    group     => "root",
  }
  exec { "Download VPN SoftLayer":
    command   => "wget ${sl_vpn_url} -O ArrayNetworksL3VPN_LINUX.bin && chmod +x ArrayNetworksL3VPN_LINUX.bin",
    creates   => "/usr/local/array_vpn/ArrayNetworksL3VPN_LINUX.bin",
    require   => File[ "/usr/local/array_vpn/" ],
    cwd       => "/usr/local/array_vpn/",
    logoutput => on_failure,
  }
  exec { "Install VPN SoftLayer":
    command   => "/usr/local/array_vpn/ArrayNetworksL3VPN_LINUX.bin",
    creates   => "/usr/local/array_vpn/array_vpnc64",
    require   => Exec[ "Download VPN SoftLayer" ],
    cwd       => "/usr/local/array_vpn/",
    logoutput => on_failure,
  }

  file { "/home/${username}/bin/vpn_1.sh":
    ensure    => "file",
    mode		  => 0750,
    owner     => "${username}",
    group	    => "${username}",
    source    => "puppet:///modules/office/vpn_1.sh",
    require   => File["/home/${username}/bin"],
  }
  file { "/home/${username}/bin/vpn_2.sh":
    ensure    => "file",
    mode      => 0750,
    owner     => "${username}",
    group     => "${username}",
    source    => "puppet:///modules/office/vpn_2.sh",
    require   => File["/home/${username}/bin"],
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
  file { "/home/${username}/bin/connect2office.sh":
    ensure	=> "file",
    mode		=> 0750,
    owner		=> "${username}",
    group		=> "${username}",
    source	=> "puppet:///modules/office/connect2office.sh",
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
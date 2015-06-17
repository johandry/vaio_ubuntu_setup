class office (
  $username                   = $users::username,
  $vmware_horizon_client_url  = $office::vmware_horizon_client_url,
  $sl_vpn_url                 = $office::sl_vpn_url,
  $vpn_config_content         = $office::vpn_config,
  $vpn_1_gateway              = $office::vpn_1_gateway,
  $vpn_1_username             = $office::vpn_1_username,
  $vpn_1_passwd               = $office::vpn_1_passwd,
  $vpn_2_gateway              = $office::vpn_2_gateway,
  $vpn_2_username             = $office::vpn_2_username,
  $vpn_2_passwd               = $office::vpn_2_passwd,
  $win_username               = $office::win_username,
  $win_passwd                 = $office::win_passwd,
  $win_domain                 = $office::win_domain,
  $win_server_url             = $office::win_server_url,
  $win_desktop                = $office::win_desktop,
  $unix_username              = $office::unix_username,
  $unix_ff_domainname         = $office::unix_ff_domainname,
  $unix_sl_domainname         = $office::unix_sl_domainname,
  $puppet_ff_hostname         = $office::puppet_ff_hostname
) {

  # Install VMWare Horizon Client Requirements
  $vmware_requirements  = [
    'libxml2:i386',
    'libssl1.0.0:i386',
    'libXtst6:i386',
    'libudev1:i386',
    'libpcsclite1:i386',
    'libtheora0:i386',
    'libv4l-0:i386',
    'libpulse0:i386',
    'freerdp-x11',
    'libatk1.0-0:i386',
    'libgdk-pixbuf2.0-0:i386',
    'libgtk2.0-0:i386',
    'libxss1:i386',
  ]

  exec { "apt-get add i386 architecture and update":
    command   => "dpkg --add-architecture i386 && apt-get update",
    unless    => "dpkg --print-foreign-architectures | grep -c i386",
  }

  package { $vmware_requirements:
  ensure    => present,
    require   => Exec['apt-get add i386 architecture and update'],
  }

  file { "/lib/i386-linux-gnu/libudev.so.0":
    ensure    => "link",
    target    => "/lib/i386-linux-gnu/libudev.so.1",
  }
  file { "/lib/i386-linux-gnu/libssl.so.1.0.1":
    ensure    => "link",
    target    => "/lib/i386-linux-gnu/libssl.so.1.0.0",
  }
  file { "/lib/i386-linux-gnu/libcrypto.so.1":
    ensure    => "link",
    target    => "/lib/i386-linux-gnu/libcrypto.so.1.0.0",
  }
  file { "/lib/i386-linux-gnu/libcrypto.so.1.0.":
    ensure    => "link",
    target    => "/lib/i386-linux-gnu/libcrypto.so.1.0.0 1",
  }

  exec { "download vmware horizon client":
    command   => "wget -O /tmp/VMware-Horizon-Client.bundle ${vmware_horizon_client_url} && chmod +x /tmp/VMware-Horizon-Client.bundle",
    creates   => "/usr/bin/vmware-view",
    logoutput => on_failure,
  }

  # The install will continue in the setup.sh script because it's done with a GUI

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
    owner     => $username,
    group	    => $username,
    source    => "puppet:///modules/office/vpn_1.sh",
    require   => File["/home/${username}/bin"],
  }
  file { "/home/${username}/bin/vpn_2.sh":
    ensure    => "file",
    mode      => 0750,
    owner     => $username,
    group     => $username,
    source    => "puppet:///modules/office/vpn_2.sh",
    require   => File["/home/${username}/bin"],
  }
  file { "/home/${username}/bin/qmsgr.sh":
    ensure	=> "file",
    mode		=> 0750,
    owner		=> $username,
    group		=> $username,
    source	=> "puppet:///modules/office/qmsgr.sh",
    require => File["/home/${username}/bin"],
  }
  file { "/home/${username}/bin/desktop.sh":
    ensure	=> "file",
    mode		=> 0750,
    owner		=> $username,
    group		=> $username,
    source	=> "puppet:///modules/office/desktop.sh",
    require => File["/home/${username}/bin"],
  }
  file { "/home/${username}/bin/connect2office.sh":
    ensure	=> "file",
    mode		=> 0750,
    owner		=> $username,
    group		=> $username,
    source	=> "puppet:///modules/office/connect2office.sh",
    require => File["/home/${username}/bin"],
  }
  file { "/etc/NetworkManager/system-connections/VPN_FF":
    ensure	=> "file",
    mode		=> 0640,
    owner		=> root,
    group		=> root,
    content => $vpn_config_content,
  }
  file { "/etc/profile.d/office-settings.sh":
    ensure  => "file",
    mode    => 0640,
    owner   => $username,
    group   => $username,
    content => template('office/office-settings.erb'),
  }
  file { "/etc/profile.d/office-functions.sh":
    ensure  => "file",
    mode    => 0640,
    owner   => $username,
    group   => $username,
    source  => "puppet:///modules/office/office-functions.sh",
  }

  # Install Evolution (Mail Client)
  package { ["evolution", "evolution-ews", "evolution-mapi"]:
    ensure    => "latest",
  }
  # # Pidgin plugin para Lync
  # package { "pidgin-sipe":
  #   ensure    => "latest",
  # }
}
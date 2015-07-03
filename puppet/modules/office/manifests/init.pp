class office (
  $username                   = $users::username,
  $vmware_horizon_client_url,
  $sl_vpn_url,

  $vpn_ff_config,
  $vpn_ff_gateway,
  $vpn_ff_username,
  $vpn_ff_passwd,

  $vpn_sl_gateway,
  $vpn_sl_username,
  $vpn_sl_passwd,

  $win_ff_username,
  $win_ff_passwd,
  $win_ff_domain,
  $win_ff_server_url,
  $win_ff_desktop,

  $win_sl_username,
  $win_sl_passwd,
  $win_sl_domain,
  $win_sl_server_url,
  $win_sl_desktop,

  $unix_username,
  $unix_ff_domainname,
  $unix_sl_domainname,
  $unix_ff_default_server,
  $unix_sl_default_server,
  
  $puppet_ff_hostname,
  $puppet_sl_hostname
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

  file { "/home/${username}/.vmware":
    ensure    => "directory",
    mode      => 0700,
    owner     => $username,
    group     => $username,
  }
  file { "/home/${username}/.vmware/view-preferences":
    ensure    => "file",
    mode      => 0664,
    owner     => $username,
    group     => $username,
    require   => File["/home/${username}/.vmware"],
  }
  exec { "VMware-Horizon-Client sslVerificationMode":
    command   => "echo 'view.sslVerificationMode = \"3\"' >> /home/${username}/.vmware/view-preferences",
    unless    => "grep -q 'view.sslVerificationMode = \"3\"' /home/${username}/.vmware/view-preferences",
    require   => File["/home/${username}/.vmware/view-preferences"],
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

  file { "/home/${username}/bin/vpnff":
    ensure    => "file",
    mode		  => 0750,
    owner     => $username,
    group	    => $username,
    source    => "puppet:///modules/office/vpnff",
    require   => File["/home/${username}/bin"],
  }
  file { "/home/${username}/bin/vpnsl":
    ensure    => "file",
    mode      => 0750,
    owner     => $username,
    group     => $username,
    source    => "puppet:///modules/office/vpnsl",
    require   => File["/home/${username}/bin"],
  }
  file { "/home/${username}/bin/Qmsgr":
    ensure	=> "file",
    mode		=> 0750,
    owner		=> $username,
    group		=> $username,
    source	=> "puppet:///modules/office/Qmsgr",
    require => File["/home/${username}/bin"],
  }
  file { "/home/${username}/bin/vmff":
    ensure	=> "file",
    mode		=> 0750,
    owner		=> $username,
    group		=> $username,
    source	=> "puppet:///modules/office/vmff",
    require => File["/home/${username}/bin"],
  }
  file { "/home/${username}/bin/vmsl":
    ensure  => "file",
    mode    => 0750,
    owner   => $username,
    group   => $username,
    source  => "puppet:///modules/office/vmsl",
    require => File["/home/${username}/bin"],
  }
  file { "/home/${username}/bin/c2office":
    ensure	=> "file",
    mode		=> 0750,
    owner		=> $username,
    group		=> $username,
    source	=> "puppet:///modules/office/c2office",
    require => File["/home/${username}/bin"],
  }
  file { "/etc/NetworkManager/system-connections/FF":
    ensure	=> "file",
    mode		=> 0640,
    owner		=> root,
    group		=> root,
    content => $vpn_ff_config,
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
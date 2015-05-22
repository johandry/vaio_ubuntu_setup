class vpn {

  # VMWare Horizon Client URL
  $vmware_horizon_client_url	= "https://download3.vmware.com/software/view/viewclients/CART14Q4/VMware-Horizon-Client-3.2.0-2331566.x86.bundle"

  # Install Network Manager OpenConnect
  package { "network-manager-openconnect-gnome":
    ensure		=> "latest",
  }

  # Install VMWare Horizon Client Requirements
  $vmware_requirements	= [
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
    command		=> "dpkg --add-architecture i386 && apt-get update",
    unless		=> "dpkg --print-foreign-architectures | grep -c i386",
  }

  package { $vmware_requirements:
	ensure		=> present,
    require		=> Exec['apt-get add i386 architecture and update'],
  }

  file { "/lib/i386-linux-gnu/libudev.so.0":
    ensure		=> "link",
    target		=> "/lib/i386-linux-gnu/libudev.so.1",
  }
  file { "/lib/i386-linux-gnu/libssl.so.1.0.1":
    ensure		=> "link",
    target		=> "/lib/i386-linux-gnu/libssl.so.1.0.0",
  }
  file { "/lib/i386-linux-gnu/libcrypto.so.1":
    ensure		=> "link",
    target		=> "/lib/i386-linux-gnu/libcrypto.so.1.0.0",
  }
  file { "/lib/i386-linux-gnu/libcrypto.so.1.0.":
    ensure		=> "link",
    target		=> "/lib/i386-linux-gnu/libcrypto.so.1.0.0 1",
  }

  exec { "download vmware horizon client":
    command		=> "wget -O /tmp/VMware-Horizon-Client.bundle $vmware_horizon_client_url && chmod +x /tmp/VMware-Horizon-Client.bundle",
    creates		=> "/usr/bin/vmware-view",
    logoutput	=> on_failure,
  }

}

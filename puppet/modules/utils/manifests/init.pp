class utils {
  
  # Install Network Manager OpenConnect
  package { [ "network-manager-openconnect-gnome", "network-manager-openconnect"]:
    ensure		=> "latest",
  }

  # Install Google Chorme
  exec { "dpkg install google-chrome":
    command		=> "wget -O /tmp/google-chrome-stable_current_amd64.deb $google_chrome_url && dpkg --install /tmp/google-chrome-stable_current_amd64.deb",
    creates		=> "/opt/google/chrome/google-chrome",
    logoutput	=> on_failure,
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

  # The install will continue in the setup.sh script because it's done with a GUI

  # Install Java
  package { [ "default-jre", "default-jdk", "icedtea-netx", "icedtea-plugin" ]:
    ensure    => "latest"
  }

  exec { "install skype":
    command   => "wget ${skype_url} -O /tmp/skype-ubuntu.deb && dpkg --install /tmp/skype-ubuntu.deb",
    creates   => "/usr/bin/skype",
  }
  exec { "force install skype":
    command   => "apt-get -f install",
    creates   => "/usr/bin/skype",
    require   => Exec["install skype"],
  }

  exec { "install dropbox":
    command   => "wget -O /tmp/dropbox.deb $dropbox_url && dpkg --install /tmp/dropbox.deb && /usr/bin/dropbox start -i",
    creates   => "/usr/bin/dropbox",
  }

  # Python 
  package { ["python3", "python3-pip"]:
    ensure    => "latest",
  }

  # Install Evolution (Mail Client)
  package { ["evolution", "evolution-ews", "evolution-mapi"]:
    ensure    => "latest",
  }
  # # Pidgin plugin para Lync
  # package { "pidgin-sipe":
  #   ensure    => "latest",
  # }
  
  # Install Sublime Text 3
  exec { "download sublime-text":
    command   => "wget -O /tmp/sublime-text.deb ${sublime_text_url} && dpkg --install /tmp/sublime-text.deb",
    creates   => "/usr/bin/subl",
    logoutput => on_failure,
  }
  # After this, install the Packages with Sublime Text Package Control because it will update them to the latest version
}

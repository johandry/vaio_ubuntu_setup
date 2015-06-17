class utils (
  $google_chrome_url  = $utils::google_chrome_url,
  $skype_url          = $utils::skype_url,
  $dropbox_url        = $utils::dropbox_url
){

  # Install Google Chorme
  exec { "dpkg install google-chrome":
    command		=> "wget -O /tmp/google-chrome-stable_current_amd64.deb ${google_chrome_url} && dpkg --install /tmp/google-chrome-stable_current_amd64.deb",
    creates		=> "/opt/google/chrome/google-chrome",
    logoutput	=> on_failure,
  }

  # Install Java
  package { [ "default-jre", "default-jdk", "icedtea-netx", "icedtea-plugin" ]:
    ensure    => "latest"
  }

  # Install Skype
  exec { "install skype":
    command   => "wget ${skype_url} -O /tmp/skype-ubuntu.deb && dpkg --install /tmp/skype-ubuntu.deb",
    creates   => "/usr/bin/skype",
  }
  exec { "force install skype":
    command   => "apt-get -f install",
    creates   => "/usr/bin/skype",
    require   => Exec["install skype"],
  }

  # Install Dropbox
  exec { "install dropbox":
    command   => "wget -O /tmp/dropbox.deb ${dropbox_url} && dpkg --install /tmp/dropbox.deb && /usr/bin/dropbox start -i",
    creates   => "/usr/bin/dropbox",
  }

}

class networking () {

  host { "vaio.johandry.com":
    ip           => "127.0.1.1",
    host_aliases => "vaio",
  }

  # Install Network Manager OpenConnect
  package { [ "network-manager-openconnect-gnome", "network-manager-openconnect"]:
    ensure    => "latest",
  }

}
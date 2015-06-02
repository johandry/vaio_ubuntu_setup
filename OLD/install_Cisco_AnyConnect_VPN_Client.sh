# Cisco AnyConnect is not longer needed, it was replaced by OpenConnect, but keep this script just in case.

install_Cisco_AnyConnect_VPN_Client () {
  if [[ -e /opt/cisco/anyconnect/bin/vpnui ]]
    then
    info "Cisco AnyConnect VPN Client installed therefore was not installed" 
  else
    info "Installing Cisco AnyConnect VPN Client"
    # Download the client 64-bits version
    # Source: https://www.auckland.ac.nz/en/for/current-students/cs-current-pg/cs-current-pg-support/vpn/cs-cisco-vpn-client-for-linux.html
    wget "${ANYCONNECT_URL}" -O /tmp/anyconnect.tar

    # Untar and install
    # Source: http://oit.ua.edu/wp-content/uploads/2014/08/Linux.pdf
    # Source: https://www.auckland.ac.nz/en/for/current-students/cs-current-pg/cs-current-pg-support/vpn/cs-cisco-vpn-client-for-linux.html
    # Dependency: update_OS
    mkdir -p /tmp/anyconnect
    tar xf /tmp/anyconnect.tar -C /tmp/anyconnect
    cd /tmp/anyconnect/*/vpn/
    sudo ./vpn_install.sh

    ok "Cisco AnyConnect VPN Client installed"
  fi

  info "Starting Cisco AnyConnect VPN Service"
  # Start service
  sudo systemctl start vpnagentd.service
  sudo systemctl status vpnagentd.service

  info "If Service is not working, try restart Ubuntu"

  info "Connect to the VPN to get the profile"
  /opt/cisco/anyconnect/bin/vpnui

  ok "Cisco AnyConnect VPN Client installed"
}

install_VMWare_Horizon_Client () {
  # Install dependencies. These packages are 32-bit version
  sudo dpkg --add-architecture i386
  sudo apt-get -y update

  sudo apt-get -y install libxml2:i386 libssl1.0.0:i386 libXtst6:i386 libudev1:i386 libpcsclite1:i386 libtheora0:i386 libv4l-0:i386 libpulse0:i386 freerdp-x11 libatk1.0-0:i386 libgdk-pixbuf2.0-0:i386 libgtk2.0-0:i386 libxss1:i386
  sudo ln -sf /lib/i386-linux-gnu/libudev.so.1 /lib/i386-linux-gnu/libudev.so.0
  sudo ln -sf /lib/i386-linux-gnu/libssl.so.1.0.0 /lib/i386-linux-gnu/libssl.so.1.0.1
  sudo ln -sf /lib/i386-linux-gnu/libcrypto.so.1.0.0 /lib/i386-linux-gnu/libcrypto.so.1
  sudo ln -sf /lib/i386-linux-gnu/libcrypto.so.1.0.0 /lib/i386-linux-gnu/libcrypto.so.1.0.1

  # Downloading VMWare Horizon Client
  wget ${VMWARE_HORIZON_CLIENT_URL} -O /tmp/VMware-Horizon-Client.bundle

  info "Do NOT select USB, Printing or any other extra feature. Just the basics"
  chmod +x /tmp/VMware-Horizon-Client.bundle
  sudo /tmp/VMware-Horizon-Client.bundle

  # Source: https://communities.vmware.com/thread/499473

  # TODO: Add it to the menu
}


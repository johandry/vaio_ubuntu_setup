# Ubuntu MATE Setup on a Sony VAIO

This is a guide and scripts to setup my old **Sony VAIO VGN-FW139E** with Ubuntu MATE which I use for development and DevOps playground.

## Requirements

* VAIO VGN-FW139E
* Internet Access

## Install Ubuntu MATE

I use a USB Flash drive to install Ubuntu MATE and I'm using a Mac OS X 10.10 to download and setup the USB Flash drive. Download Ubuntu MATE ISO with wget and you may go to https://ubuntu-mate.org/vivid/ to get the URL of the latest version.

```
wget http://cdimage.ubuntu.com/ubuntu-mate/releases/15.04/release/ubuntu-mate-15.04-desktop-amd64.iso
```

In Mac OS X convert the ISO to DMG. The first command is to identify where the USB Flash drive is mounted, in this case it is /dev/disk2 and that's the value for USB\_DISK. So, replace MOUNT_ON value for the disk that is using the USB Flash in your Mac.

``` 
hdiutil convert -format UDRW -o ubuntu-mate-15.04-desktop-amd64 ubuntu-mate-15.04-desktop-amd64.iso
diskutil list
USB_DISK=/dev/disk2
diskutil umountDisk $USB_DISK
sudo dd if=ubuntu-mate-15.04-desktop-amd64.dmg of=$USB_DISK

```

Once it is done you can unplug the USB Flash drive form the Mac and plug it in the VAIO to start the install of Ubuntu MATE.

A few notes about the install:

* Press the F11 key when the computer is powered on, this is to boot from the USB.
* If the installer don't show the option to install Ubuntu alongside Windows 8 then quit the installation to go to "Try Ubuntu" mode, open a terminal and with the command 'parted' delete the partitions that are not NFS (Windows partitions). Then restart the installation.

## Setup

Git is not installed by default so install it, clone this repository and execute the setup.sh script:

```
sudo apt-get install -y git
git clone https://github.com/johandry/vaio_ubuntu_setup.git /home/$USER/Setup && cd !$
./setup.sh
```

This script - check code [here](https://raw.githubusercontent.com/johandry/vaio_ubuntu_setup/master/setup.sh) - will do:

1. Install Cisco AnyConnect VPN Client 
1. Install VMWare Horizon Client
1. Install MATE Desktop
1. Install Cinnamon Desktop 
1. Install Puppet to automate installs

The Puppet Manifest will make sure:

1. Install Docker
1. Install Packer and Vagrant
1. Sublime Text 3
1. 


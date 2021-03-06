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

1. Install Puppet to automate installations and setups
1. Execute or Apply the Puppet rules.
1. Install VMWare Horizon Client

Puppet will do:

1. Update and upgrade Ubuntu. Make sure this is done every Monday
1. Create ~/bin directory and copy some scripts
1. Create a Workspace and clone this project
1. Install Google Chrome
1. Install VMWare Horizon Client requirements
1. Install Docker
1. Install Sublime Text 3
1. Install and configure VPN clients
1. Install IM such as Skype and Q Messenger
1. Install SSH Keys
1. Install several useful scripts and the bashrc
1. Install Dropbox
1. Install Evolution


TODO:

* Install VirtualBox, Packer and Vagrant
* Install Ruby and rbenv

## What Next?

After run the setup to install lot of programs, there are some tasks that is better to do manually such as:

1. Download and install a few desktop wallpapers. [Here](http://www.hdwallpapers.in/) is a good site to get them. 
1. Download and install Sublime Text packages. Package Control will make sure you have the latest version. Use it instead of install them with Puppet. Read the next section for a list of packages to install

### Sublime Text 3 Packages

Use Package Control to install the packages. Open the Command Pallete (Command+Shift+P on OS X, Control+Shift+P on Linux/Windows). Type "Package Control: Install Package", wait while Package Control fetches the latest package list, then type the name of the package to install and press enter.

1. [Package Control](https://packagecontrol.io/installation)
1. [Puppet](https://github.com/russCloak/SublimePuppet)

[Here](https://packagecontrol.io) you can find more packages.
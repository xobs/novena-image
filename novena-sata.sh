#!/bin/bash
echo "Constructing a disk image on /dev/sdb"
exec sudo ./novena-image.sh \
	-d /dev/sdb \
	-t sata \
	-s jessie \
	-a pulseaudio-novena_1.0-1_all.deb \
	-a irqbalance_0.56-1ubuntu4-rmk1_armhf.deb \
	-a novena-disable-ssp_1.0-1_armhf.deb \
	-a u-boot-novena_2014.10-novena-rc1_armhf.deb \
	-l "sudo openssh-server ntp ntpdate dosfstools btrfs-tools \
	    novena-eeprom xserver-xorg-video-modesetting task-xfce-desktop \
	    hicolor-icon-theme gnome-icon-theme tango-icon-theme keychain \
	    avahi-daemon avahi-dnsconfd libnss-mdns btrfs-tools dosfstools \
	    parted debootstrap python build-essential xscreensaver vlc vim \
	    emacs x11-xserver-utils usbutils unzip apt-file xz-utils \
	    subversion git make screen tmux read-edid powertop powermgmt-base \
	    pavucontrol p7zip-full paprefs pciutils nmap ntfs-3g \
	    network-manager-vpnc network-manager-pptp network-manager-openvpn \
	    network-manager-iodine mplayer2 libreoffice imagemagick icedove \
	    iceweasel gtkwave gnupg2 git git-email git-man fuse freecad \
	    enigmail dc curl clang bridge-utils bluez bluez-tools \
	    bluez-hcidump bison bc automake autoconf pidgin alsa-utils verilog \
	    i2c-tools hwinfo android-tools-adb android-tools-fastboot \
	    android-tools-fsutils libcap-ng0 libglib2.0-0"

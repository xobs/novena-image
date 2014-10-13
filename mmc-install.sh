#!/bin/bash
if [ -z $1 ]
then
	echo "Usage: $0 [device]"
	echo "E.g. $0 /dev/mmcblk1"
	exit 1
fi

echo "Constructing a disk image on $1"
time sudo ./novena-image.sh \
	-d $1 \
	-t mmc \
	-s jessie \
	-a pulseaudio-novena_1.0-1_all.deb \
	-a irqbalance_0.56-1ubuntu4-rmk1_armhf.deb \
	-a novena-disable-ssp_1.1-1_armhf.deb \
	-a novena-firstrun_1.0-r1_all.deb \
	-a u-boot-novena_2014.10-novena-rc5_armhf.deb \
	-a linux-image-3.17.0-rc5-00054-g8a738b8_1.4_armhf.deb \
	-l "sudo openssh-server ntp ntpdate dosfstools novena-eeprom \
            xserver-xorg-video-modesetting arandr user-setup vim emacs \
	    hicolor-icon-theme gnome-icon-theme keychain locales \
	    avahi-daemon avahi-dnsconfd libnss-mdns debootstrap psutils \
	    python build-essential xscreensaver console-data zip tcpdump \
	    x11-xserver-utils usbutils unzip xz-utils subversion git make \
	    screen tmux read-edid powertop powermgmt-base pavucontrol \
	    p7zip-full paprefs pciutils nmap ntfs-3g network-manager-vpnc \
	    network-manager-pptp network-manager-openvpn bash-completion \
	    network-manager-iodine hexchat icedove iceweasel gnupg2 unp \
	    git-email git-man fuse enigmail dc curl clang bridge-utils \
	    bluez bluez-tools bluez-hcidump bison bc automake autoconf \
	    pidgin alsa-utils i2c-tools hwinfo android-tools-adb unrar \
	    android-tools-fastboot android-tools-fsutils smartmontools \
	    xfce4-goodies xfce4-power-manager xfce4-mixer xfce4-terminal \
	    mousepad orage dbus-x11 quodlibet evince-gtk irssi strace \
	    tango-icon-theme network-manager-gnome synaptic pkg-config \
	    gnome-orca ncurses-dev gdb lzop lzop gawk bison g++ gcc flex \
	    wireshark pm-utils qalc qalculatei memtester locate mousetweaks \
	    iptraf iperf iotop initramfs-tools gnupg-agent extfat-fuse \
	    extfat-utils dict ark aptitude"

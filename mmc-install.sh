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
	-a u-boot-novena_2014.10-novena-rc9_armhf.deb \
	-a irqbalance_0.56-1ubuntu4-rmk1_armhf.deb \
	-a linux-headers-novena_1.8_armhf.deb \
	-a linux-image-novena_1.8_armhf.deb \
	-a novena-disable-ssp_1.1-1_armhf.deb \
	-a novena-eeprom-gui_1.2-r1_armhf.deb \
	-a novena-firstrun_1.1-r1_all.deb \
	-l "sudo openssh-server ntp ntpdate dosfstools novena-eeprom \
            xserver-xorg-video-modesetting arandr user-setup vim emacs \
	    hicolor-icon-theme gnome-icon-theme keychain locales evtest \
	    avahi-daemon avahi-dnsconfd libnss-mdns debootstrap psutils \
	    python build-essential xscreensaver console-data zip tcpdump \
	    x11-xserver-utils usbutils unzip xz-utils subversion git make \
	    screen tmux read-edid powertop powermgmt-base pavucontrol \
	    p7zip-full paprefs pciutils nmap ntfs-3g network-manager-vpnc \
	    network-manager-pptp network-manager-openvpn bash-completion \
	    network-manager-iodine hexchat icedove iceweasel gnupg2 unp \
	    git-email git-man fuse enigmail dc curl clang bridge-utils \
	    bluez bluez-tools bluez-hcidump bison bc automake autoconf \
	    pidgin alsa-utils i2c-tools hwinfo android-tools-adb unrar-free \
	    android-tools-fastboot android-tools-fsutils smartmontools \
	    xfce4-goodies xfce4-power-manager xfce4-mixer xfce4-terminal \
	    mousepad orage dbus-x11 quodlibet evince-gtk irssi strace \
	    tango-icon-theme network-manager-gnome synaptic pkg-config \
	    gnome-orca ncurses-dev gdb lzop gawk bison g++ gcc flex \
	    pm-utils qalc qalculate-gtk memtester locate mousetweaks \
	    iptraf iperf iotop initramfs-tools gnupg-agent exfat-fuse \
	    exfat-utils dict aptitude libqt5core5a libqt5gui5 \
	    libqt5widgets5 console-setup lightdm"

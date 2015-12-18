#!/bin/bash
if [ -z $1 ]
then
	echo "Usage: $0 [device]"
	echo "E.g. $0 /dev/mmcblk1"
	exit 1
fi

echo "Constructing a disk image on $1"
exec sudo ./novena-image.sh \
	-d $1 \
	-t sata \
	-s jessie \
	-l "sudo openssh-server ntp ntpdate dosfstools btrfs-tools \
	    novena-eeprom xserver-xorg-video-modesetting task-xfce-desktop \
	    hicolor-icon-theme gnome-icon-theme tango-icon-theme keychain \
	    avahi-daemon avahi-dnsconfd libnss-mdns btrfs-tools \
	    parted debootstrap python build-essential xscreensaver vlc vim \
	    emacs x11-xserver-utils usbutils unzip apt-file xz-utils \
	    subversion make screen tmux read-edid powertop powermgmt-base \
	    pavucontrol p7zip-full paprefs pciutils nmap ntfs-3g \
	    network-manager-vpnc network-manager-pptp network-manager-openvpn \
	    network-manager-iodine mplayer2 libreoffice imagemagick icedove \
	    iceweasel gtkwave gnupg2 git git-email git-man fuse freecad \
	    enigmail dc curl clang bridge-utils bluez bluez-tools \
	    bluez-hcidump bison bc automake autoconf pidgin alsa-utils verilog \
	    i2c-tools hwinfo android-tools-adb android-tools-fastboot \
	    android-tools-fsutils bash-completion kicad ncurses-dev gdb lzop \
	    gawk bison g++ gcc flex pkg-config valgrind lconv netcat wireshark \
	    kismet aircrack-ng socat locales \
            pulseaudio-novena irqbalance-imx novena-disable-ssp \
	    u-boot-novena linux-image-novena" \
	${@:2}

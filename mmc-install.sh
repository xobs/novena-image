#!/bin/bash
if [ -z $1 ]
then
	echo "Usage: $0 [device] <additional_args>"
	echo "E.g. $0 /dev/mmcblk1"
	exit 1
fi

echo "Constructing a disk image on $1"
time sudo /bin/bash -x ./novena-image.sh \
	-d $1 \
	-t mmc \
	-s jessie \
	-k kosagi.key \
	-l "sudo openssh-server ntp ntpdate dosfstools novena-eeprom \
            xserver-xorg-video-modesetting arandr user-setup vim emacs \
	    keychain locales evtest libbluetooth3 \
	    avahi-daemon avahi-dnsconfd libnss-mdns debootstrap \
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
	    mousepad orage dbus-x11 irssi strace \
	    synaptic pkg-config \
	    ncurses-dev gdb lzop gawk bison g++ gcc flex \
	    pm-utils qalc memtester locate \
	    iptraf iperf iotop initramfs-tools gnupg-agent exfat-fuse \
	    exfat-utils dict aptitude libqt5core5a libqt5gui5 \
	    libqt5widgets5 console-setup lightdm \
	    x11-apps x11-session-utils xbitmaps xfce4 xfce4-appfinder \
	    xfce4-notifyd xfce4-session xfce4-settings xfdesktop4 \
	    xfdesktop4-data xfonts-100dpi xfonts-75dpi xfonts-scalable \
	    xfwm4 xfwm4-themes xinit xorg xorg-docs-core \
            u-boot-novena irqbalance-imx libdrm-armada2-dbg \
            novena-usb-hub libetnaviv-dev libetnaviv-dbg \
            linux-headers-novena linux-image-novena novena-disable-ssp novena-eeprom \
            novena-eeprom-gui kosagi-repo novena-firstrun xorg-novena xserver-xorg-video-armada \
            xserver-xorg-video-armada-dbg xserver-xorg-video-armada-etnaviv" \
        ${@:2}

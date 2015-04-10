#!/bin/bash
if [ -z $1 ]
then
	echo "Usage: $0 [device]"
	echo "E.g. $0 /dev/mmcblk1"
	exit 1
fi

echo "Constructing a disk image on $1"
time sudo /bin/bash -x ./novena-image.sh \
	-d $1 \
	-e \
	-t sata \
	-s jessie \
	-k kosagi.key \
	-a u-boot-novena_2014.10-novena-rc12_armhf.deb \
	-a irqbalance-imx_0.56-1ubuntu4-rmk1_armhf.deb \
	-a novena-eeprom_2.1-1_armhf.deb \
	-a kosagi-repo_1.0-r1_all.deb \
	-a novena-firstrun_1.4-r1_all.deb \
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
	    synaptic pkg-config cryptsetup network-manager \
	    ncurses-dev gdb lzop gawk bison g++ gcc flex \
	    pm-utils qalc memtester locate \
	    iptraf iperf iotop initramfs-tools gnupg-agent exfat-fuse \
	    exfat-utils dict aptitude libqt5core5a libqt5gui5 \
	    libqt5widgets5 console-setup lightdm \
	    x11-apps x11-session-utils xbitmaps xfce4 xfce4-appfinder \
	    xfce4-notifyd xfce4-session xfce4-settings xfdesktop4 \
	    xfdesktop4-data xfonts-100dpi xfonts-75dpi xfonts-scalable \
	    xfwm4 xfwm4-themes xinit xorg xorg-docs-core"

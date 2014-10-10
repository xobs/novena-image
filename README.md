Novena Image
============

Create Debian disk images that can be used to boot Novena systems.


Synopsis
--------

The script comes with a help screen that can be used to customize the
resulting image.  For examples, see wraper scripts such as "novena-mmc.sh"
and "novena-sata.sh".


Recommended package lists
-------------------------

Different board configurations have different suggested package lists.  This
is because different boards have different SD sizes installed.

For the 4 GB "Bare Board" model, we recommend the following package list:

    -l "sudo openssh-server ntp ntpdate dosfstools novena-eeprom \
        xserver-xorg-video-modesetting task-xfce-desktop hicolor-icon-theme \
	gnome-icon-theme tango-icon-theme keychain avahi-daemon avahi-dnsconfd \
	libnss-mdns dosfstools debootstrap python \
	build-essential xscreensaver vlc vim emacs x11-xserver-utils \
	usbutils unzip xz-utils subversion git make screen tmux \
	read-edid powertop powermgmt-base pavucontrol p7zip-full paprefs \
	pciutils nmap ntfs-3g network-manager-vpnc network-manager-pptp \
	network-manager-openvpn network-manager-iodine libreoffice \
	icedove iceweasel gnupg2 git git-email git-man \
	fuse enigmail dc curl clang bridge-utils bluez bluez-tools \
	bluez-hcidump bison bc automake autoconf pidgin alsa-utils \
	i2c-tools hwinfo android-tools-adb android-tools-fastboot \
	android-tools-fsutils"

For the 16 GB "Desktop" model and the SSD-based "Laptop" models, the following,
more-complete package list is recommended:

    -l "sudo openssh-server ntp ntpdate dosfstools btrfs-tools novena-eeprom \
        xserver-xorg-video-modesetting task-xfce-desktop hicolor-icon-theme \
	gnome-icon-theme tango-icon-theme keychain avahi-daemon avahi-dnsconfd \
	libnss-mdns btrfs-tools dosfstools parted debootstrap python \
	build-essential xscreensaver vlc vim emacs x11-xserver-utils \
	usbutils unzip apt-file xz-utils subversion git make screen tmux \
	read-edid powertop powermgmt-base pavucontrol p7zip-full paprefs \
	pciutils nmap ntfs-3g network-manager-vpnc network-manager-pptp \
	network-manager-openvpn network-manager-iodine mplayer2 libreoffice \
	imagemagick icedove iceweasel gtkwave gnupg2 git git-email git-man \
	fuse freecad enigmail dc curl clang bridge-utils bluez bluez-tools \
	bluez-hcidump bison bc automake autoconf pidgin alsa-utils verilog \
	i2c-tools hwinfo android-tools-adb android-tools-fastboot \
	android-tools-fsutils libcap-ng0 libglib2.0-0"

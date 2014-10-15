Novena Image
============

Create Debian disk images that can be used to boot Novena systems.


Synopsis
--------

The script comes with a help screen that can be used to customize the
resulting image.  For examples, see wraper scripts such as "mmc-install.sh"
and "sata-install.sh".


Recommended package lists
-------------------------

Different board configurations have different suggested package lists.  This
is because different boards have different SD sizes installed.

For the 4 GB "Bare Board" model and laptop recovery partition, we recommend
the following package list:

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

#!/bin/bash

rootpass="kosagi"
version="1.0"
mirror="http://127.0.0.1:3142/ftp.hk.debian.org/debian"
packages=""
debs=""

# Indicates whether we're bootstrapping onto a real disk
realdisk=0

# Set to 1 once things get mounted to the root
things_mounted=0

info() {
	func="${FUNCNAME[1]}"
	if [ -z ${func} ]
	then
		func="main"
	fi
	FG="1;32m"
	BG="40m"
	echo -e "[\033[${FG}\033[${BG}${func}\033[0m] $*"
}

warn() {
	func="${FUNCNAME[1]}"
	if [ -z ${func} ]
	then
		func="main"
	fi
	FG="1;31m"
	BG="40m"
	echo -e "[\033[${FG}\033[${BG}${func}\033[0m] $*"
}

fail() {
	func="${FUNCNAME[1]}"
	if [ -z ${func} ]
	then
		func="main"
	fi
	FG="1;31m"
	BG="40m"
	echo -en "[\033[${FG}\033[${BG}${func}\033[0m] "
	if [ -z "$1" ]
	then
		echo "Exiting due to error"
	else
		echo "Error: $*"
	fi
	exit 1
}

unmount_in_dir() {
	local dir="$1"
	for mnt in $(grep "${dir}" /proc/mounts | awk '{print $2}' | sort -r | uniq)
	do
		umount "${mnt}" 2> /dev/null || warn "Unable to umount ${mnt}"
	done
}

cleanup() {
	info "Unmounting devices from chroot"
	unmount_in_dir "${root}"
}

partition_disk() {
	local diskname="$1"
	local disktype="$2"

	if [ -z ${diskname} ]
	then
		fail "Must specify a path to a disk device"
		exit 1
	fi

	# Come up with the disk signature based on the requested type
	if [ "x${disktype}" = "xmmc" ]
	then
		# "NovM"
		disksig=4e6f764d
		swapsize=+32M
	elif [ "x${disktype}" = "xsata" ]
	then
		# "NovS"
		disksig=4e6f7653
		swapsize=+4G
	else
		fail "Must specify a disk type of either mmc or sata"
		exit 1
	fi

	fdisk ${diskname} -C32 -H32 <<EOF
o
n
p
1

+32M
n
p
2

${swapsize}
n
p
3


t
1
b
t
2
82
x
i
0x${disksig}
w
q
EOF
	stat=$?
	if [ $stat -ne 0 ]
	then
		fail "fdisk returned error $stat"
	fi
}

prepare_disk() {
	local diskname="$1"
	local disktype="$2"
	local root="$3"

	partition_disk "${diskname}" "${disktype}"

	# MMC devices are weirdly labeled mmcblk0p1 rather than mmcblk01
	if echo "${diskname}" | grep -q mmcblk
	then
		diskname="${diskname}p"
	fi

	mkfs.vfat ${diskname}1 || fail "Unable to make boot partition"
	mkswap -f ${diskname}2 || fail "Unable to make swap"
	mkfs.ext4 -F ${diskname}3 || fail "Unable to make root filesystem"

	mkdir -p "${root}" || fail "Unable to create factory mount directory"
	mount ${diskname}3 "${root}" || fail "Unable to mount new root filesystem"
	mkdir -p "${root}/boot" || fail "Unable to create boot directory"
	mount ${diskname}1 "${root}/boot" || fail "Unable to mount new boot filesystem"

}

bootstrap() {
	local suite="$1"
	local root="$2"
	local mirror="$3"

	info "Bootstrapping ${suite} onto ${root} from ${mirror}"
	debootstrap "${suite}" "${root}" "${mirror}" || fail "Unable to debootstrap"
}

prepare_root() {
	local root="$1"

	if [ -z "${root}" ]
	then
		fail "Must specify a path to the root"
	fi

	info "Binding useful mountpoints into new root"
	mkdir -p "${root}"
	mount -obind /proc "${root}/proc"
	mount -obind /sys "${root}/sys"
	mount -obind /dev "${root}/dev"
	mount -obind /dev/pts "${root}/dev/pts"
	things_mounted=1

	info "Preventing daemons from starting in the chroot"
	echo '#!/bin/sh' > "${root}/usr/sbin/policy-rc.d"
	echo 'echo "All runlevel operations denied by policy" >&2' >> "${root}/usr/sbin/policy-rc.d"
	echo 'exit 101' >> "${root}/usr/sbin/policy-rc.d"
	chmod a+x "${root}/usr/sbin/policy-rc.d" || fail "Couldn't make file executable"

	info "Creating a 'first-run' file"
	touch "${root}/var/run/firstrun"
}

reset_password() {
	local root="$1"
	local rootpass="$2"

	# Reset the root password
	info "Resetting root password to '${rootpass}'"
	echo "root:${rootpass}" | chroot "${root}" /usr/sbin/chpasswd || fail "Unable to reset root password"
}

add_sources() {
	local root="$1"
	warn "!!! NEED TO ADD SOURCES HERE !!!"
}

apt_install() {
	local root="$1"
	local packages="$2"
	export DEBIAN_FRONTEND=noninteractive
	export DEBCONF_NONINTERACTIVE_SEEN=true

	info "Updating package listing"
	chroot "${root}" apt-get -y update || fail "Couldn't update packages"

	info "Cleaning up previous apt-get (if any)"
	chroot "${root}" apt-get -y -f install || fail "Couldn't clean up"

	if [ -z "${packages}" ]
	then
		info "No packages were requested to be installed"
	else
		info "Installing selected packages: ${packages}"
		chroot "${root}" apt-get -y install ${packages} || fail "Couldn't install packages"
	fi

	info "Cleaning up downloaded debs"
	chroot "${root}" apt-get -y clean || fail "Couldn't clean packages"
}

deb_install() {
	local root="$1"
	shift
	export DEBIAN_FRONTEND=noninteractive

	while (( "$#" ))
	do
		pkgfile="$1"
		base="$(basename ${pkgfile})"
		info "Installing ${base} from ${pkgfile}"
		cp "${pkgfile}" "${root}"
		chroot "${root}" dpkg -i "${base}" || fail "Couldn't install package ${base} from ${pkgfile}"
		chroot "${root}" rm -f "${base}"
		shift
	done
}

configure_fstab() {
	local root="$1"

	warn "!!! NEED TO CONFIGURE FSTAB HERE !!!"
}

remove_ssh_keys() {
	local root="$1"

	info "Removing generated SSH keys"
	rm -f "${root}/etc/ssh/*key" "${root}/etc/ssh/*.key.pub" || fail "Unable to remove SSH keys"
}

finalize_root() {
	local root="$1"

	info "Enabling serial console support"
	chroot "${root}" sudo systemctl enable serial-getty@ttymxc1.service || fail "Couldn't enable serial console"

	info "Allowing scripts to start up on boot"
	rm -f "${root}/usr/sbin/policy-rc.d"
}

write_uboot_spl() {
	local root="$1"
	local spl="$2"
	local device="$3"

	if [ ! -e "${root}/${spl}" ]
	then
		warn "SPL file '${spl}' does not exist, disk won't boot"
		return 1
	fi

	info "Writing U-Boot SPL file '${spl}' to disk"
	dd if="${root}/${spl}" of="${device}" bs=1024 seek=1 conv=notrunc || fail "Unable to write SPL"
}

usage() {
	echo "Novena Image Creator ${version}"
	echo "Generate a root filesystem, and optionally write it to an SD card"
	echo "or SATA drive.  It will install a complete set of packages and"
	echo "prepare the system for first boot."
	echo ""
	echo "An Internet connection is required."
	echo ""
	echo "Options:"
	echo "    -m  --mirror   Specify which Debian mirror to use."
	echo "                   We suggest using apt-cacher-ng."
	echo "    -d  --disk     A path to the block device to partition,"
	echo "                   format, and create the image on.  Requires"
	echo "                   you specify a --type as well."
	echo "    -t  --type     Either 'mmc' or 'sata', the type of disk"
	echo "                   specified by --disk."
	echo "    -r  --root     Directory to install files into.  If no --disk"
	echo "                   is specified, then this argument is required."
	echo "    -p  --rootpass Which root password to use.  If unspecified,"
	echo "                   defaults to 'kosagi'."
	echo "    -l  --packages Specify a comma-separated list of packages"
	echo "                   to install.  A default list is built-in."
	echo "    -s  --suite    Which Debian suite to install.  A list"
	echo "                   of supported suites available may be found"
	echo "                   at /usr/share/debootstrap/scripts"
	echo "    -a  --add-deb  Specify additional .deb files to include in"
	echo "                   the disk image.  You may use --add-deb"
	echo "                   multiple times to install more than one .deb."
	echo "    -h  --help     Print this help message."
	echo ""
}



##########################################################

temp=`getopt -o m:d:t:p:r:l:s:a:h \
	--long mirror:,disk:,type:,rootpass:,root:,packages:,suite:,add-deb:,help \
	-n 'novena-image' -- "$@"`
if [ $? != 0 ] ; then fail "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$temp"
while true ; do
	case "$1" in
		-m|--mirror) mirror="$2"; shift 2 ;;
		-d|--disk) diskname="$2"; shift 2 ;;
		-t|--type) disktype="$2"; shift 2 ;;
		-p|--rootpass) rootpass="$2"; shift 2 ;;
		-r|--root) root="$2"; shift 2 ;;
		-l|--packages) packages="$2"; info "Packages: $2"; shift 2 ;;
		-s|--suite) suite="$2"; shift 2 ;;
		-a|--add-deb) debs="${debs} $2"; shift 2 ;;
		-h|--help) usage; exit 0 ;;
		--) shift ; break ;;
		*) fail "Internal getopt error!" ; exit 1 ;;
	esac
done

if [ -z "${suite}" ]
then
	fail "Must specify a suite (e.g. jessie) with -s or --suite"
fi

if [ "$(id -u)" != "0" ]; then
	fail "As scary as it is, this script must be run as root"
fi

# Unmount things, and generally clean up on exit
trap cleanup EXIT

# If a disk path and a type are specified, we're writing to a real disk
if [ ! -z "${diskname}" ] && [ ! -z "${disktype}" ]
then
	realdisk=1
	info "Ensuring disk is unmounted"
	unmount_in_dir "${diskname}"
	if [ -z "${root}" ]
	then
		root="/tmp/newroot"
	fi
	prepare_disk "${diskname}" "${disktype}" "${root}"
elif [ ! -z "${diskname}" ] || [ ! -z "${disktype}" ]
then
	fail "Must specify both a --disk path and a disk --type"
elif [ -z "${root}" ]
then
	fail "Must specify a root directory with -r or --root"
fi

bootstrap "${suite}" "${root}" "${mirror}"

prepare_root "${root}"

reset_password "${root}" "${rootpass}"

add_sources "${root}"

info "Selected packages: '${packages}'"
apt_install "${root}" "${packages}"

if [ ! -z "${debs}" ]
then
	deb_install "${root}" ${debs}
else
	info "No additional .deb files were requested"
fi

configure_fstab "${root}"

remove_ssh_keys "${root}"

finalize_root "${root}"

if [ ${realdisk} -ne 0 ]
then
	write_uboot_spl "${root}" "/boot/u-boot.spl" "${diskname}"
fi

#!/bin/bash

rootpass="kosagi"
version="1.0"
mirror="http://127.0.0.1:3142/ftp.hk.debian.org/debian"
packages=""
debs=""
disktype="mmc"
bootsize=+32M

# Indicates whether we're bootstrapping onto a real disk
realdisk=0

# Set to 1 once things get mounted to the root
things_mounted=0

# Set to 1 (using -q) to skip partitioning, formatting, and bootstrapping.
quick=0

# If creating a disk using loopback, set to 1
loopback=0

# This is the size of the "4GiB" cards we've worked with.
loopback_size=3965190144

# Sometimes the SHA1 sum comes out as all zeroes.  For reasons why I don't know.
allzeros_shasum="3b71f43ff30f4b15b5cd85dd9e95ebc7e84eb5a3"

checksha1sum() {
	local file="$1"

	if [ ! -z ${file} ]
	then
		checksum=$(dd if="${file}" bs=1M skip=1 count=1 | shasum - | awk '{print $1}')
		if [ "x${checksum}" = "x${allzeros_shasum}" ]
		then
			fail "Checksum failed.  File appears to be all zeroes"
		fi
	else
		info "Not checking file sum"
	fi
}

info() {
	func="$(echo "${FUNCNAME[1]}" | tr _ ' ')"
	if [ "x${func}" = "x" ]
	then
		func="main"
	fi
	FG="1;32m"
	BG="40m"
	echo -e "[\033[${FG}\033[${BG}${func}\033[0m] $*"
}

warn() {
	func="$(echo "${FUNCNAME[1]}" | tr _ ' ')"
	if [ "x${func}" = "x" ]
	then
		func="main"
	fi
	FG="1;33m"
	BG="40m"
	echo -e "[\033[${FG}\033[${BG}${func}\033[0m] $*"
}

fail() {
	func="$(echo "${FUNCNAME[1]}" | tr _ ' ')"
	if [ "x${func}" = "x" ]
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

	if [ ${loopback} -ne 0 ]
	then
		info "Unmounting loopback"
		if [ ! -z "${loopname}" ]
		then
			losetup -d "${loopname}"
			unset loopname
		fi
		kpartx -v -d "${diskname}"
		for disk in $(losetup | grep "${diskname}" | awk '{print $1}')
		do
			losetup -d "${disk}"
		done
	fi
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

${bootsize}
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
r
w
q
EOF
	stat=$?
	if [ $stat -ne 0 ]
	then
		fail "fdisk returned error $stat"
	fi
}

prepare_loopback() {
	local imgname="$1"
	local imgsize="$2"
	local quick="$3"

	filename="${imgname}"

	info "Creating a new file ${imgname} with size ${imgsize}"
	truncate "-s${imgsize}" "${imgname}" || error "Unable to create file"

	if [ ${quick} -ne 1 ]
	then
		partition_disk "${filename}" "${disktype}"
	fi

	diskname=$(kpartx -s -v -a "${imgname}" | cut -d' ' -f8 | uniq | grep loop)
	if [ $? -ne 0 ]
	then
		fail "Unable to map image to /dev/maper using kpartx"
	fi
}

prepare_disk() {
	local diskname="$1"
	local disktype="$2"
	local root="$3"
	local quick="$4"

	# Loopback devices are also weird, /dev/loop0 becomes /dev/mapper/loop0p1
	if [ ${loopback} -ne 0 ]
	then
		base="$(echo "${diskname}" | cut -d/ -f3)"
		diskname="/dev/mapper/${base}p"

	# MMC devices are weirdly labeled mmcblk0p1 rather than mmcblk01
	elif echo "${diskname}" | grep -q mmcblk
	then
		diskname="${diskname}p"
	fi

	if [ "${quick}" != "1" ]
	then
		mkfs.vfat ${diskname}1 || fail "Unable to make boot partition"
		mkswap -f ${diskname}2 || fail "Unable to make swap"
		mkfs.ext4 -F ${diskname}3 || fail "Unable to make root filesystem"
	fi

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
	mkdir -p "${root}/usr/sbin/"
	chmod a+x "${root}/usr/sbin/policy-rc.d" || fail "Couldn't make file executable"

	info "Creating a 'first-run' file"
	mkdir -p "${root}/var/lib"
	touch "${root}/var/lib/firstrun"
}

reset_password() {
	local root="$1"
	local rootpass="$2"

	# Reset the root password
	info "Resetting root password to '${rootpass}'"
	echo "root:${rootpass}" | chroot "${root}" /usr/sbin/chpasswd || fail "Unable to reset root password"
}

add_key() {
	local root="$1"
	local key="$2"

	info "Adding key from ${key}"
	if ! chroot "${root}" /usr/bin/apt-key add - < "${key}"
	then
		error "Unable to add key"
	fi
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

setup_recovery() {
	local root="$1"

	if [ -e "${root}/boot/zImage" -a -e "${root}/boot/novena.dtb" ]
	then
		if [ -e "${root}/boot/zImage.recovery" ]
		then
			info "Not setting up recovery kernel, one already exists"
			return
		fi

		info "Setting up recovery kernel"
		cp "${root}/boot/zImage" "${root}/boot/zImage.recovery" || fail "Couldn't copy recovery kernel"
		cp "${root}/boot/novena.dtb" "${root}/boot/novena.recovery.dtb" || fail "Couldn't copy recovery device tree file"
	else
		info "No kernel installed, not setting up recovery kernel"
	fi
}

configure_fstab() {
	local root="$1"

	if [ "${disktype}" = "mmc" ]
	then
		rootpath="/dev/disk/by-path/platform-2198000.usdhc-part"
	elif [ "${disktype}" = "sata" ]
	then
		rootpath="/dev/sda"
	else
		fail "Unrecognized disktype: ${disktype}"
	fi

	cat > "${root}/etc/fstab" <<EOF
${rootpath}3   /                    ext4       barrier=1,noatime,nodiratime,errors=remount-ro     0  1
proc                 /proc                proc       defaults                      0  0
devpts               /dev/pts             devpts     mode=0620,gid=5               0  0
tmpfs                /tmp                 tmpfs      defaults                      0  0
pstore               /var/pstore          pstore     defaults                      0  0
/dev/disk/by-path/platform-2198000.usdhc-part1 /boot     vfat       defaults                      2  2
${rootpath}2   swap                 swap       defaults                      0  0
EOF
}

remove_ssh_keys() {
	local root="$1"

	info "Removing generated SSH keys"
	rm -f "${root}/etc/ssh/ssh_host_"* || fail "Unable to remove SSH keys"
}

finalize_root() {
	local root="$1"

	info "Resetting hostname to 'novena'"
	echo "novena" > "${root}/etc/hostname"

	info "Enabling serial console support"
	chroot "${root}" systemctl enable serial-getty@ttymxc1.service || fail "Couldn't enable serial console"

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
	echo "    -l  --packages Specify a space-separated list of packages"
	echo "                   to install."
	echo "    -s  --suite    Which Debian suite to install.  A list"
	echo "                   of supported suites available may be found"
	echo "                   at /usr/share/debootstrap/scripts"
	echo "    -a  --add-deb  Specify additional .deb files to include in"
	echo "                   the disk image.  You may use --add-deb"
	echo "                   multiple times to install more than one .deb."
	echo "    -q  --quick    Don't repartition, reformat, or botstrap."
	echo "    -h  --help     Print this help message."
	echo ""
}



##########################################################

temp=`getopt -o m:d:t:p:r:l:s:a:k:hq \
	--long key:,quick,mirror:,disk:,type:,rootpass:,root:,packages:,suite:,add-deb:,help \
	-n 'novena-image' -- "$@"`
if [ $? != 0 ] ; then fail "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$temp"
while true ; do
	case "$1" in
		-m|--mirror) mirror="$2"; shift 2 ;;
		-k|--key) key="$2"; shift 2 ;;
		-d|--disk) diskname="$2"; shift 2 ;;
		-t|--type) disktype="$2"; shift 2 ;;
		-p|--rootpass) rootpass="$2"; shift 2 ;;
		-r|--root) root="$2"; shift 2 ;;
		-l|--packages) packages="$2"; info "Packages: $2"; shift 2 ;;
		-s|--suite) suite="$2"; shift 2 ;;
		-a|--add-deb) debs="${debs} $2"; if [ ! -e "$2" ]; then fail "Couldn't locate package: $2"; fi; shift 2 ;;
		-q|--quick) quick=1; shift 1 ;;
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

info "Creating a ${disktype} image"

# If a disk path and a type are specified, we're writing to a real disk
if [ ! -z "${diskname}" ]
then
	realdisk=1
	info "Ensuring disk is unmounted"
	unmount_in_dir "${diskname}"
	if [ -z "${root}" ]
	then
		root="/tmp/newroot.$$"
	fi

	if [ ! -e "${diskname}" ] || [ "$(stat -L -c '%F' ${diskname})" != "block special file" ]
	then
		if [ -e "${diskname}" ]
		then
			warn "Disk exists, overwriting it"
		else
			info "Disk does not exist.  Creating loopback device."
		fi

		loopback=1
		# prepare_loopback will partition the disk if necessary
		prepare_loopback "${diskname}" "${loopback_size}" "${quick}"
	else

		# Partition a regular disk here
		if [ ${quick} -ne 1 ]
		then
			partition_disk "${diskname}" "${disktype}"
		fi
	fi
	prepare_disk "${diskname}" "${disktype}" "${root}" "${quick}"

elif [ -z "${root}" ]
then
	fail "Must specify a root directory with -r or --root"
fi

checksha1sum "${filename}"

if [ "${quick}" != "1" ]
then
	bootstrap "${suite}" "${root}" "${mirror}"
	checksha1sum "${filename}"
fi

prepare_root "${root}"
checksha1sum "${filename}"

reset_password "${root}" "${rootpass}"
checksha1sum "${filename}"

if [ ! -z "${key}" ]
then
	add_key "${root}" "${key}"
fi
checksha1sum "${filename}"

info "Selected packages: '${packages}'"
apt_install "${root}" "${packages}"
checksha1sum "${filename}"

if [ ! -z "${debs}" ]
then
	deb_install "${root}" ${debs}
	checksha1sum "${filename}"
else
	info "No additional .deb files were requested"
fi

configure_fstab "${root}" "${disktype}"
checksha1sum "${filename}"

setup_recovery "${root}"
checksha1sum "${filename}"

remove_ssh_keys "${root}"
checksha1sum "${filename}"

finalize_root "${root}"
checksha1sum "${filename}"

if [ ${realdisk} -ne 0 ]
then
	write_uboot_spl "${root}" "/boot/u-boot.spl" "${diskname}"
	checksha1sum "${filename}"
fi

checksha1sum "${filename}"

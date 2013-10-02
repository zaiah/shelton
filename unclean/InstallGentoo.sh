#!/bin/bash - 
#------------------------------------------------------
# InstallGentoo.sh 
# 
# Installs a gentoo system.  
# Didn't know it was quite so loose.
#-----------------------------------------------------#

# Set up popular variables ahead of
# time. (ROOTFS, etc.)
# -----------------------------------
TOP="/mnt/gentoo"
BOOTFS="${TOP}/boot"
ROOTFS="${TOP}/root"
HOMEFS="${TOP}/home"
TMPFS="${TOP}/tmp"
FETCH="wget"				# I guess this will always exist, should check anyway.

# Check for and configure network
# -----------------------------------
# ...

# Create Partitions 
# -----------------------------------
# fdisk  / parted...
# (you could script the file sizes)
#
# Perhaps use static sizes for a few and percents on the others.
parted -s mkpart logical ext2 0 50mb					# /boot
parted -s mkpart logical linux-swap 50mb 1074mb  # swap
parted -s mkpart logical ext4 1074mb 5064mb 		# /root
parted -s mkpart logical ext4 5064mb -1s			# /home
parted -s print					# Check that we're all good.

# Create Filesystems 
# -----------------------------------
# mkfs.ext2 /dev/sdaN 	( /boot )
# mkfs.ext4 				( or whatever ... for /home & /root )
# ??? tmpfs (these can get mega fast)
# mkswap /dev/swap   	 

# Make & Mount Directories
# -----------------------------------
mkdir -p /mnt/gentoo/{home,root,boot}
# mount /dev/sdaN $BOOTFS 
# mount /dev/sdaN $HOMEFS 
# mount /dev/sdaN $ROOTFS
# mount /dev/sdaN $TMPFS 


# Set Date & Time
# -----------------------------------
# (What can we set this up with??)


# Mirrors & Stage tarballs
# -----------------------------------
# you might have to do some research...
# Example Mirror:
#  http://www.gtlib.gatech.edu/pub/gentoo/releases/amd64/autobuilds/
#
# Example tarball:
#  http://www.gtlib.gatech.edu/pub/gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20130130.tar.bz2
cd $ROOTFS
STAGE3="stage3-amd64-20130130.tar.bz2"
#
# Calculate the checksum:
# Example checksum file:
#  http://www.gtlib.gatech.edu/pub/gentoo/releasES/AMD64/autobuilds/current-stage3-amd64/stage3-amd64-20130130.tar.bz2.DIGESTS
DIGESTS="stage3-amd64-20130130.tar.bz2.DIGESTS"
#
# Check for validity of file. 
[ ! -z $( cat $DIGESTS | grep $(openssl dgst -r -sha512 | awk '{print $1}') ) ] && tar xzpvf $STAGE3
cd -


# Package Management
# -----------------------------------
# Portage is one choice of pkgmgr
# cave is the other....
# Guess we'll use Portage... 

PMAKE="$ROOTFS/etc/portage/make.conf"
# (either)
# vi $PMAKE
# 	or
# sed trickery to create the CFLAGS... 

# Tell Gentoo how you want things built. 
sed -i $PMAKE "s/`grep CFLAGS $PMAKE`/CFLAGS='-march=?? -02 -pipl'"	# Pipes instead of files for comm
sed -i $PMAKE "s/`grep CXXFLAGS $PMAKE`/CXXFLAGS='${CFLAGS}'"
sed -i $PMAKE "s/`grep MAKEOPTS $PMAKE`/MAKEOPTS='-j2'" 
 
# Then get some mirrors setup.
mirrorselect -i -o >> $PMAKE
mirrorselect -i -r -o >> $PMAKE  	# What is SYNC, stuff for rsync?


# Chrooting & carrying over settings
# ----------------------------------
cp -L /etc/resolv.conf "$TOP/etc"
mount -t proc none $ROOTFS/proc 
mount --rbind /sys $ROOFS/sys
mount --rbind /dev $ROOFS/dev
chroot $ROOTFS /bin/bash
source /etc/profile
export PS1="(chroot) $PS1" 


# Configure Portage (how cage?)
# ----------------------------------
# Dunno how to check if there were chroot errors...
mkdir /usr/portage
emerge-webrsync		# This takes a while....
							# The timestamp should go to log...
							# Is very large....

# Kernel
# (fetch the kernel source?)
# ----------------------------------
#eselect profile set 1  # Dunno how to check this and keep up...
emerge gentoo-sources	# Get the kernel.
[ -L /usr/src/linux ] && emerge genkernel 
#genkernel all				# Generate a kernel from somewhere... 
# /dev/BOOT does not exist?  OH! SHIT!!!
# I wonder what will happen....

# Configure your modules, use some list....

# This looks crazy...
# emerge pciutils & lspci from here to figure out what to do...

# fstab Setup
# -----------------------------------
echo "
/dev/sda5	/boot		ext2	defaults	0 2
/dev/sda6	none		swap	sw			0 0
/dev/sda7	/			ext4	noatime	0 1
/dev/cdrom  /mnt/cdrom auto noauto,user 0 1" >> /etc/fstab
#/dev/sdaN	/boot		ext2	defaults	0 2


# Networking setup.
# -----------------------------------
echo "hostname=\"$HOSTNAME\"" > /etc/conf.d/hostname
echo "dns_domain_lo=\"$SERVERNAME\"" > /etc/conf.d/net

# Be wary b/c only certain systems
# will use these settings.
# Maybe we should stop after the kernel to 
# copy the VM or disk as a snapshot.
#
# Alternatively, stop and use a seperate script
# to setup all the boxes.
echo "config_eth0=\"dhcp\"" >> /etc/conf.d/net


# Additional stuff...
# A DHCP/DNS server is going to use a different hosts file.
 

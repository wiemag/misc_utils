#!/bin/bash -
set -o nounset
VERSION=0.99
function usage () {
	echo -e "Run:\n\t\e[1m${0##*/}\e[0m ISO PARTITION"
	echo -e "Where:\n\tISO = path/name of installation image file"
	echo -e "\tPARTITION = /dev/sd\e[1;32mX\e[1;34mN, \e[1;32mX\e[0m={a,b,c,...}, \e[1;34mN\e[0m={1,2,3,...}\n"
}
function descr () {
	echo -e "\e[36;1m${0##*/}\e[0m, ver. ${VERSION}\e[0m, installs Arch Linux"
	echo installation image file on a chosen partition of a flash disk
	echo -e "or a USB drive. The installation can only be made on an \e[36;1mext2/3/4\e[0m"
	echo -e "file system partition."
	echo -e "\e[36;1mThe flash/USB drive remains usable for other purposes.\e[0m\n"
}
function partspace () {
	FREESIZE=$(df -k /dev/sdb2 | awk 'FNR>1{print $2" "$4}')
	PARTSIZE=${FREESIZE%% *}
	FREESIZE=${FREESIZE##* }
	FREEMIN=1800000
	if [[ $FREESIZE -lt $FREEMIN ]]; then
		echo -e "\n\e[1mWarning!\e[0m Too little free space in partition ${PART}"
		echo Partition size: ${PARTSIZE} kiB
		printf  "Free space:     %${#PARTSIZE}d %s\n" ${FREESIZE} 'kiB'
		echo The minimal free space required for install is about 1.8 GiB
		echo if you mean to use openbox.
		return 99
	fi
	return 0
}

((UID)) && { usage; descr; echo -e "\e[1;32mRun as root.\e[0m"; exit 1;}

# ---Dependencies------------------------------------------
# PKG
# e2fsprogs: e2label - To change partition label w/o touching fs
# syslinux:  syslinux - To install MBR on MRB/GPT disks
# coreutils: dd - To instal MBR on MBR/GPT disks
# coreutils: df - To check spree space size in partition
# gptfdisk:  sgdisk - To set partition on an MRB/GPT disk bootable (legacy)
# gawk:      awk
# grep:      grep
# sed:       sed

# ---Installation image file-------------------------------
ISO=${1-}
[[ -z "$ISO" ]] && { usage;
	echo -e "\e[1;32mNo installation file (*.iso).\e[0m";
	exit 2;}
[[ -f "$ISO" ]] || { echo -e "The installation file\n\t${ISO}\ndoes not exist."; exit 3;}

# ---Partition to install in-------------------------------
PART=${2-}
[[ -z "$PART" ]] && { usage;
	echo -e "\e[1;32mNo partition chosen.\e[0m";
	exit 4;}
[[ "$PART" =~ ^/dev/sd[a-z][0-9]+$ ]] || { usage;
	echo -e "\e[1;32mIncorrect partition format.\e[0m";
	exit 5;}
[[ -b "$PART" ]] || { usage;
	echo -e "\e[1;32mDevice/partition does not exist.\e[0m";
	exit 6;}
CURLABEL=$(lsblk -no FSTYPE,LABEL ${PART})
PARTFS=${CURLABEL%% *}   	# Partition file system
[[ "$PARTFS" =~ ^ext[234]+$ ]] || { usage; descr;
	echo -e "\e[32mWrong partition file system. Only ext2/3/4 allowed.";
	echo -e "Current partition file system is ${PARTFS}.\e[0m";
	exit 7;}
CURLABEL=${CURLABEL##* } 	# Current partition label

# ---Mount partition---------------------------------------
M=$(awk "/$(echo ${PART} | sed 's/\//\\\//g')/"' {print $2}' /proc/self/mounts)
USB=/mnt/usb
if [[ -n "$M" ]]; then
	echo -e "\n\e[1mWarning!\e[0m Partition $PART is mounted to ${M}."
	echo Check what it is, and unmount it manually.
	[[ "$M" == $USB ]] && echo Consider removing ${M}, too.
	partspace 	# Check available free space in $PART
	exit 9
fi
[[ -d $USB ]] || mkdir $USB
M=$(awk "/$(echo ${USB} | sed 's/\//\\\//g')/"' {print $1}' /proc/self/mounts)
if [[ -n "$M" ]]; then
	echo -e "Warning. Partition ${M} is mounted to ${USB}."
	echo Check what it is, and unmount it manually.
	exit 10
fi
mount "$PART" $USB
echo 1. $PART has been mounted to $USB

# ---Check free memory size of the chosen partition--------
partspace
[[ $? == 99 ]] && { umount ${USB}; exit 11;}

# ---The last warning--------------------------------------
echo -e "\n\e[1mThe last and only warning!\e[0m"
echo -ne "Are you sure you want to install on the partition \e[1m${PART}\e[0m?  (y/\e[1mN\e[0m) "
read -n1 -t3
[[ ! $REPLY = [yY] ]] && { [[ -n $REPLY ]] && echo; umount ${USB}; exit 0;}
echo; echo

# ---Mount installation image file-------------------------
I=/mnt/iso
[[ -d $I ]] || mkdir $I
M=$(awk "/$(echo ${I} | sed 's/\//\\\//g')/"' {print $1}' /proc/self/mounts)
if [[ -n "$M" ]]; then
	echo -e "Warning. Partition ${M} is mounted to ${I}."
	echo Check what it is, and unmount it manually.
	exit 12
fi
echo 2. Mounting ${ISO}
mount -o loop "$ISO" $I
[[ $? -gt 0 ]] && { echo Most likely a wrong or corrupted ISO file.;
	umount ${USB};
	rm -r ${USB} $I;
	exit;}
echo "   "$ISO has been monted to $I
#LABEL=$(grep label ${I}/arch/boot/syslinux/archiso.cfg |cut -d= -f3)
LABEL=$(grep label ${I}/arch/boot/syslinux/archiso_sys32.cfg |cut -d= -f3)

# ---Copy files to /mnt/usb--------------------------------
echo 3. Copying ${I}/* to ${USB}
cp -a ${I}/* ${USB}
sudo sync
umount ${I}
rm -r ${I}   	# Not needed any longer

# ---Install syslinux on the ${PART} disk------------------
echo 4. Installing syslinux on ${PART%?}
#cp -r /usr/lib/syslinux/bios/*.c32 ${USB}/arch/boot/syslinux/
extlinux --install ${USB}/arch/boot/syslinux
umount ${USB}
rm -r ${USB} 	# Not needed any longer

# ---Set label, set partition bootable, install MBR--------
echo 5. Setting partition label to \"$LABEL\"
[[ "$LABEL" == "$CURLABEL" ]] || { e2label $PART "$LABEL";
	echo $PART partition labeled \"$LABEL\";}
# What disklabel/disk partition table is used (MBR or GPT)?
PARTAB=$(blkid -s PTTYPE -o value ${PART%?})
if [[ $PARTAB = "dos" ]]; then
	echo 6. Setting the ${PART} partition bootable not possible here.
	echo "   "Set it manually with fdisk or other tools.
	echo 7. Installing MBR \(440 bytes\) with command
	echo "   "dd bs=440 count=1 conv=notrunc if=/usr/lib/syslinux/bios/mbr.bin of=${PART%?}
	dd bs=440 count=1 conv=notrunc if=/usr/lib/syslinux/bios/mbr.bin of=${PART%?}
fi
if [[ $PARTAB = "gpt" ]]; then
	echo 6. Setting the ${PART} partition bootable
	N="${PART: -1}"  # The last character
	sgdisk ${PART%?} --attributes=${N}:set:2 	# The 2 sets the bootable flag.
	echo 7. Installing MBR \(440 bytes\) with command
	echo "   "dd bs=440 conv=notrunc count=1 if=/usr/lib/syslinux/bios/gptmbr.bin of=${PART%?}
	dd bs=440 conv=notrunc count=1 if=/usr/lib/syslinux/bios/gptmbr.bin of=${PART%?}
fi

#!/bin/sh

IMAGE=$1

DEPLOYDIR="/build/v2012.12/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone/"
MOUNTPOINT="/media/2"
MOUNTPOINT1="/media/1"
FLASHIMG="Angstrom-Cloud9-IDE-GNOME-eglibc-ipk-v2012.12-beaglebone.rootfs.tar.gz"
SCRATCHDIR="/build/images"

DATE="$(date +'%Y.%m.%d')"

if [ -e ${IMAGE}.xz ] ; then
	echo "uncompressing image"
	xz -d -v ${IMAGE}.xz
fi

if ! [ -e ${IMAGE} ] ; then
	echo "${IMAGE} not found!"
	exit 1
fi

echo "Trying to attach image file"
LOOPFILE="$(kpartx -a -v ${IMAGE} | grep /dev | grep p2 | tail -n1 | awk '{print $8}' | sed s:/dev/::)"

echo "Loopdev: ${LOOPFILE}"

sleep 1

if ! [ -e /dev/mapper/${LOOPFILE}p1 ] ; then
	echo "Incorrect partitioning, /dev/mapper/${LOOPFILE}p1 not found"
	exit 1
fi

umount ${MOUNTPOINT1} >& /dev/null
mount ${MOUNTPOINT1}

echo "Mounting /dev/mapper/${LOOPFILE}p1"
mount /dev/mapper/${LOOPFILE}p1 ${MOUNTPOINT1} || exit 1

echo "BeagleBone ${DATE}" > ${MOUNTPOINT1}/ID.txt

echo "Copying over bootloader"
cp -vf ${DEPLOYDIR}/MLO ${MOUNTPOINT1} && cp -vf ${DEPLOYDIR}/u-boot.img ${MOUNTPOINT1}

sync && sleep 1

umount ${MOUNTPOINT1} || exit 1

if ! [ -e /dev/mapper/${LOOPFILE}p2 ] ; then
	echo "Incorrect partitioning, /dev/mapper/${LOOPFILE}p2 not found"
	exit 1
fi

echo "Zeroing /dev/mapper/${LOOPFILE}p2"
dd if=/dev/zero of=/dev/mapper/${LOOPFILE}p2

echo "Creating ext4 on /dev/mapper/${LOOPFILE}p2"
mkfs.ext4 -L ${FLASHIMG} /dev/mapper/${LOOPFILE}p2 || exit 1

echo "Mounting /dev/mapper/${LOOPFILE}p2"
umount ${MOUNTPOINT} >& /dev/null
mount /dev/mapper/${LOOPFILE}p2 ${MOUNTPOINT} || exit 1

echo "Untarring contents"
tar zxf ${DEPLOYDIR}${FLASHIMG} -C ${MOUNTPOINT}

sync && sleep 1

echo "Ummounting ${MOUNTPOINT}"
umount ${MOUNTPOINT}

sleep 1

echo "detaching loopfile"
kpartx -d -v ${IMAGE}

echo "Compressing image"
xz -v -z -T0 -e -9 ${IMAGE} 
#cp -f ${IMAGE}.xz /build/dominion/beaglebone/

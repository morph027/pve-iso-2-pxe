#!/bin/bash

cat << EOF

#########################################################################################################
# Create PXE bootable Proxmox image including ISO                                                       #
#                                                                                                       #
# Author: mrballcb @ Proxmox Forum (06-12-2012)                                                         #
# Thread: http://forum.proxmox.com/threads/8484-Proxmox-installation-via-PXE-solution?p=55985#post55985 #
# Modified: morph027 @ Proxmox Forum (23-02-2015) to work with 3.4                                      #
#########################################################################################################

EOF

if [ ! $# -eq 1 ]; then
  echo -ne "Usage: (sudo) pve-iso-2-pxe.sh /path/to/pve.iso\n\n"
  exit
fi

BASEDIR="$(dirname "$(readlink -f "$1")")"
pushd $BASEDIR >/dev/null

[ -L "proxmox.iso" ] && rm proxmox.iso &>/dev/null

for ISO in *.iso; do
    if [ "$ISO" = "*.iso" ]; then continue; fi
    if [ "$ISO" = "proxmox.iso" ]; then continue; fi
    echo "Using ${ISO}..."
    ln -s "$ISO" proxmox.iso
done

if [ ! -f "proxmox.iso" ]; then
    echo "Couldn't find a proxmox iso, aborting." 
    echo "Add /path/to/iso_dir to the commandline." 
    exit 2
fi
[ -d pxeboot ] || mkdir pxeboot
pushd pxeboot >/dev/null
[ -d mnt ] || mkdir  mnt
echo "Mounting iso image..." 
if ! mount -t iso9660 -o ro,loop ../proxmox.iso mnt/ ; then
    echo "Failed to mount iso image, aborting." 
    exit 3
fi
echo "copying kernel..."
cp  mnt/boot/linux26 .
rm -f  initrd.orig initrd.orig.img initrd.img
echo "copying initrd..."
cp  mnt/boot/initrd.img initrd.orig.img
if ! umount  mnt ; then
    echo "Couldn't unmount iso image, aborting."
    exit 4
fi

echo "Unmounted iso, extracting contents of initrd..." 
gzip -d -S ".img" ./initrd.orig.img
rm -rf initrd.tmp
mkdir  initrd.tmp
pushd initrd.tmp >/dev/null
echo "Added iso, creating and compressing the new initrd..." 
cpio -i -d < ../initrd.orig 2>/dev/null
cp ../../proxmox.iso proxmox.iso
(find . | cpio -H newc -o > ../initrd.iso) 2>/dev/null
popd 2>/dev/null
rm -f initrd.iso.img
gzip -9 -S ".img" initrd.iso

# Now clean up temp stuff
echo "Cleaning up temp files..." 
rmdir  mnt
rm -rf initrd.tmp
rm  ./initrd.orig

echo "Done! Look in $PWD for pxeboot files." 
popd 2>/dev/null
popd 2>/dev/null

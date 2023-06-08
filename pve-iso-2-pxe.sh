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
  echo -ne "Usage: bash pve-iso-2-pxe.sh /path/to/pve.iso\n\n"
  exit 1
fi

BASEDIR="$(dirname "$(readlink -f "$1")")"
pushd "$BASEDIR" >/dev/null || exit 1

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

rm -rf pxeboot
[ -d pxeboot ] || mkdir pxeboot

pushd pxeboot >/dev/null || exit 1
echo "extracting kernel..."
if [ -x $(which isoinfo) ] ; then
  isoinfo -i ../proxmox.iso -R -x /boot/linux26 > linux26 || exit 3
else
  7z x ../proxmox.iso boot/linux26 -o/tmp || exit 3
  mv /tmp/boot/linux26 /tmp/
fi
echo "extracting initrd..."
if [ -x $(which isoinfo) ] ; then
  isoinfo -i ../proxmox.iso -R -x /boot/initrd.img > /tmp/initrd.img
else
  7z x ../proxmox.iso boot/initrd.img -o/tmp
  mv /tmp/boot/initrd.img /tmp/
fi

mimetype="$(file --mime-type --brief /tmp/initrd.img)"
case "${mimetype##*/}" in
  "zstd"|"x-zstd")
    decompress="zstd -d /tmp/initrd.img -c"
    ;;
  "gzip"|"x-gzip")
    decompress="gzip -S img -d /tmp/initrd.img -c"
    ;;
  *)
    echo "unable to detect initrd compression method, exiting"
    exit 1
    ;;
esac
$decompress > initrd || exit 4
echo "adding iso file ..."
if [ -x $(which cpio) ] ; then
  echo "../proxmox.iso" | cpio -L -H newc -o >> initrd || exit 5
else
  7z x "../proxmox.iso" >> initrd || exit 5
fi
popd >/dev/null 2>&1 || exit 1

echo "Finished! pxeboot files can be found in ${PWD}."
popd >/dev/null 2>&1 || true  # don't care if these pops fail
popd >/dev/null 2>&1 || true

# Create PXE bootable Proxmox installation

## Preparation

1. download **Proxmox VE ISO Installer** from [Proxmox](http://proxmox.com)
2. run this script with ISO file as parameter (you probably need sudo rights to loop mount)
3. the *kernel* and *initramfs* (including ISO) will copied to sub-directory *pxeboot*

## PXE

1. On you PXE server, create a directory *proxmox/$version* in your PXE root directory (e.g. */var/lib/tftpboot/* or */srv/pxe/*)
2. copy/move *linux26* and *initrd.img* to this directory
3. Add the following lines to your PXE config file (mind the important parameter *ramdisk_size* or the initrd won't fit into default memory):

    ```
    label proxmox
            menu label Proxmox $version
            linux proxmox/$version/linux26
            append vga=791 video=vesafb:ywrap,mtrr ramdisk_size=524288
            initrd proxmox/$version/initrd.img splash=verbose
    ```

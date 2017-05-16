# Create PXE bootable Proxmox installation

* 2016-12-13: successfully pxe-installed 4.4
* 2016-09-27: successfully pxe-installed 4.3

## Preparation

1. download **Proxmox VE ISO Installer** from [Proxmox](http://proxmox.com/downloads) into a folder somewhere (e.g. ```/tmp/pve-iso```)
2. run the script ```pve-iso-2-pxe.sh``` with the folder containing the ISO file as parameter (you need to be root or sudo for the loop mount)
3. the ```linux26``` and ```initrd.iso.img``` (including ISO) will copied to sub-directory ```pxeboot```

## PXE

1. on you PXE server, create a directory *proxmox/$version* in your PXE root directory (e.g. */var/lib/tftpboot/* or */srv/pxe/*)
2. copy/move ```linux26``` and ```initrd.iso.img``` to this directory
3. add the following lines to your PXE config file (mind the important parameter *ramdisk_size* or the initrd won't fit into default memory):

    ```
    label proxmox-install
            menu label Install Proxmox
            linux proxmox/$version/linux26
            append vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet splash=silent
            initrd proxmox/$version/initrd.iso.img
    
    label proxmox-debug-install
            menu label Install Proxmox (Debug Mode)
            linux proxmox/$version/linux26
            append vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet splash=verbose proxdebug
            initrd proxmox/$version/initrd.iso.img
    ```

4. be happy and think about [supporting](http://proxmox.com/proxmox-ve/support) the great guys at Proxmox!

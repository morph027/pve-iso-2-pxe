# Create PXE bootable Proxmox installation

* 2021-07-09: successfully pxe-installed 7.0
* 2020-10-26: successfully pxe-installed 6.2
* 2019-12-30: successfully pxe-installed 6.1
* 2018-08-27: successfully pxe-installed 5.2
* 2017-07-11: successfully pxe-installed 5.0 (despite #1)
* 2017-06-07: successfully ipxe-installed 4.4
* 2016-12-13: successfully pxe-installed 4.4
* 2016-09-27: successfully pxe-installed 4.3

## Preparation

* install `zstd gzip genisoimage` packages
* download **Proxmox VE ISO Installer** from [Proxmox](http://proxmox.com/downloads) into a folder somewhere (e.g. `~/Downloads/proxmox-ve_6.4-1.iso`)
* run the script `pve-iso-2-pxe.sh` with the path to the ISO file as parameter
  * `bash pve-iso-2-pxe.sh ~/Downloads/proxmox-ve_6.4-1.iso`
* the `linux26` and `initrd` (including ISO) will copied to the sub-directory `pxeboot` located relative to the iso file (e.g. `~/Downloads/pxeboot`)

## [iPXE](https://ipxe.org/) (recommended)

1. copy/move ```linux26``` and ```initrd``` to a directory of your webserver (e.g. */var/www/proxmox/${version}*)
2. mofiy the ip adress of the server in the following ipxe bootscripct according to your setup:
    ```
    #!ipxe
    dhcp
    set serverip http://192.168.1.1 //Modify this to match the ip adress or domain of your webserver
    set pveversion 6.2 //Modify this to match the version you want to install
    set opts "vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet initrd=initrd"
    menu Please choose an operating system to boot
        item normal Install Proxmox
        item debug Install Proxmox (Debug Mode)
    choose --default normal --timeout 5000 target && goto ${target}
    :debug
        set kernel "${webserver}/proxmox/${pveversion}/linux26 ${opts} splash=verbose proxdebug"
        goto init
    :normal
        set kernel "${webserver}/proxmox/${pveversion}/linux26 ${opts} splash=silent"
        goto init
    :init
    initrd ${webserver}/proxmox/${pveversion}/initrd
    chain ${kernel}
    ```
3. embed the bootscript into your ipxe build or start the script from ipxe using the chain command
4. be happy and think about [supporting](http://proxmox.com/proxmox-ve/support) the great guys at Proxmox!

## PXE (HTTP - faster)

1. on your PXE server, use lpxelinux.0 as pxelinux.0 (overwrite or set filename via DHCP option)
2. copy/move ```linux26``` and ```initrd``` to a directory of your webserver (e.g. */var/www/proxmox/${version}*)
3. add the following lines to your PXE config file (mind the important parameter *ramdisk_size* or the initrd won't fit into default memory):
    ```
    label proxmox-install-http
            menu label Install Proxmox HTTP
            linux http://${webserver}/proxmox/${version}/linux26
            initrd http://${webserver}/proxmox/${version}/initrd
            append vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet splash=silent
            
    label proxmox-install-http
            menu label Install Proxmox HTTP (Debug)
            linux http://${webserver}/proxmox/${version}/linux26
            initrd http://${webserver}/proxmox/${version}/initrd
            append vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet splash=silent proxdebug
    ```
4. be happy and think about [supporting](http://proxmox.com/proxmox-ve/support) the great guys at Proxmox!

## PXE (TFTP)

1. on your PXE server, create a directory *proxmox/${version}* in your PXE root directory (e.g. */var/lib/tftpboot/* or */srv/pxe/*)
2. copy/move ```linux26``` and ```initrd``` to this directory
3. add the following lines to your PXE config file (mind the important parameter *ramdisk_size* or the initrd won't fit into default memory):

    ```
    label proxmox-install
            menu label Install Proxmox
            linux proxmox/${version}/linux26
            append vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet splash=silent
            initrd proxmox/${version}/initrd
    
    label proxmox-debug-install
            menu label Install Proxmox (Debug Mode)
            linux proxmox/${version}/linux26
            append vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet splash=verbose proxdebug
            initrd proxmox/${version}/initrd
    ```

4. be happy and think about [supporting](http://proxmox.com/proxmox-ve/support) the great guys at Proxmox!

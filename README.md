# PVE ISO to PXE

Script to extract files from Proxmox VE ISO file needed to PXE boot

## Instructions

1. Install dependencies (optional)

    ```
    apt-get install -y cpio file zstd gzip genisoimage
    ```

2. Clone repository

    ```
    git clone https://github.com/morph027/pve-iso-2-pxe.git
    cd pve-iso-2-pxe
    ```

2. Download [Proxmox VE ISO](https://www.proxmox.com/en/downloads)

    ```
    wget https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso/proxmox-ve-8-1-iso-installer
    ```

3. Execute Script

    ```
    -> bash pve-iso-2-pxe.sh proxmox-ve_8.1-1.iso

    #########################################################################################################
    # Create PXE bootable Proxmox image including ISO                                                       #
    #                                                                                                       #
    # Author: mrballcb @ Proxmox Forum (06-12-2012)                                                         #
    # Thread: http://forum.proxmox.com/threads/8484-Proxmox-installation-via-PXE-solution?p=55985#post55985 #
    # Modified: morph027 @ Proxmox Forum (23-02-2015) to work with 3.4                                      #
    #########################################################################################################

    Using proxmox-ve_8.1-1.iso...
    extracting kernel...
    extracting initrd...
    adding iso file ...
    2524621 blocks
    Finished! pxeboot files can be found in /root/pve-iso-2-pxe.
    ```

5. Verify `initrd` and `linux26` files are in `pxeboot` directory

    ```
    -> ls pxeboot/
    initrd  linux26
    ```

### Methods

#### iPXE (recommended)

1. Copy `initrd` and `linux26` to a directory on a web server
2. Modify `server variable` variables in iPXE script below to be an IP or hostname of web server

    ```
    #!ipxe

    dhcp
    set webserver http://192.168.1.1

    set opts "vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet initrd=initrd"
    menu Please choose an operating system to boot
        item normal Install Proxmox
        item debug Install Proxmox (Debug Mode)
    choose --default normal --timeout 5000 target && goto ${target}
    :debug
        set kernel "${webserver}/proxmox/linux26 ${opts} splash=verbose proxdebug"
        goto init
    :normal
        set kernel "${webserver}/proxmox/linux26 ${opts} splash=silent"
        goto init
    :init
    initrd ${webserver}/proxmox/initrd
    chain ${kernel}
    ```

3. Embed the iPXE script into iPXE iso or start it from iPXE using chain command

#### PXE (HTTP)

1. Copy `initrd` and `linux26` to a directory on a web server
2. Add the following lines to your PXE config file

    **Note**: Modify `webserver` to be an IP or hostname of web server

    ```
    label proxmox-install-http
            menu label Install Proxmox HTTP
            linux http://${webserver}/proxmox/linux26
            initrd http://${webserver}/proxmox/initrd
            append vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet splash=silent
            
    label proxmox-install-http
            menu label Install Proxmox HTTP (Debug)
            linux http://${webserver}/proxmox/linux26
            initrd http://${webserver}/proxmox/initrd
            append vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet splash=silent proxdebug
    ```

#### PXE (TFTP)

1. Copy `initrd` and `linux26` to a directory on a TFTP server
2. Add the following lines to your PXE config file

    ```
    label proxmox-install
            menu label Install Proxmox
            linux proxmox/linux26
            append vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet splash=silent
            initrd proxmox/initrd
    
    label proxmox-debug-install
            menu label Install Proxmox (Debug Mode)
            linux proxmox/linux26
            append vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet splash=verbose proxdebug
            initrd proxmox/initrd
    ```

### Tested Versions

[Think about supporting the great guys at Proxmox](http://proxmox.com/proxmox-ve/support)

* 11-24-2023: Proxmox VE 8.1
* 06-22-2023: Proxmox VE 8.0
* 03-23-2023: Proxmox VE 7.4
* 11-22-2022: Proxmox VE 7.3
* 08-18-2022: Proxmox VE 7.2
* 07-09-2021: Proxmox Backup Server 2.2-1
* 07-09-2021: Proxmox VE 7.0
* 10-26-2020: Proxmox VE 6.2
* 12-30-2019: Proxmox VE 6.1
* 08-27-2018: Proxmox VE 5.2
* 07-11-2017: Proxmox VE 5.0
* 06-07-2017: Proxmox VE 4.4
* 12-13-2016: Proxmox VE 4.4
* 09-27-2016: Proxmox VE 4.3

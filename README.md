# Simple virsh / virt-install / virt-clone / virt-sysprep wrapper 

Wrapper script to control the creation and cloning of **Red Hat Enterprise Linux (RHEL)**  template VMs using virsh / virt-install / virt-clone / virt-sysprep wrapper

### Requirements

This script is based and tested on a Fedora host (other distro may also work) and requires:

1. Python
1. qemu-kvm + libvirt + libguestfs

        $ sudo dnf install @virtualization virt-install guestfs-tool

1. sudo access to run virsh / virt-install / virt-clone / virt-sysprep / mv
1. Red Hat Enterprise Linux installation DVD iso's for the templates downloaded from http://access.redhat.com to `/var/lib/libvirt/images`

### Setup

The setup script will ask the `root` and `user1` password and update the kickstart templates before copying them into `$HOME/.local/kickstart` together with `vmctl` in `$HOME/.local/bin`

    $ bash setup.sh

### Usage

## Creating a template

With a default Fedora host with libvirt installed, this script uses the `default` storage pool for hosting the VM disk and iso images as well the `default` network. The kickstart templates are installing template VMs that can later being cloned to easily and quickly create a new VM.

The template VM are not especially secure and thus should **not** be used to production workload unless secured/locked afterwards. Core details of the template VM
* Minimal setup with `core` packages only
* RHEL DVD ISO File attached as a CD-ROM
* CD-ROM automatically mounted and configured to be used for installing packages using `dnf`
* Default domainname `example.com` (network should have a entry with `<domain name='example.com'/>` in the xml definition)
* Serial console enabled (accessible via `sudo virsh console <domain>`)
* The root user enabled
* Default SSH pub key of the local user configured for root access
* New user created named user1

After kickstarting, the template VM's disk is sparcified to alllow minimal disk usage and fast cloning times.

Example kickstarting a RHEL8.6 template VM:

    $ vmctl kickstart -r 8.6 -n rhel86base

or with 2 GB of memory and 4 vCPUs configured:

    $ vmctl kickstart -r 8.6 -m 2 -c 4 -n rhel86base

## Creating a new VM by cloing a template

Using `virt-clone` a new VM is created from a template kickstarted earlier. After cloning the new VM is preped by `virt-sysprep` removing traces of the old name etc. (including for eample the MAC address of the NIC).

Example:

    $ vmvtl clone -r 8.6 -n mynewvm

After the cloning and prepping, the new VM is started and ready to be used. Besides the serial console access, the new VM can be used to find the IP address using:

    $ dig @192.168.122.1 nynewvm.example.com


(replace the IP address of the virbr0 interface for the default domain)

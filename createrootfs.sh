#!/bin/sh
#
# Create a rootfs environment for chroot building.
#
# Requires 
# - OS installing CDROM at the current directory,
# - the root authority.
#
wget http://archive.kernel.org/centos-vault/7.4.1708/isos/x86_64/CentOS-7-x86_64-Minimal-1708.iso
# mount install cd
mkdir /mnt/cdrom
mount ./CentOS-7-x86_64-Minimal-1708.iso /mnt/cdrom -t iso9660 -o loop

# mount squashfs
mkdir /mnt/squashfs
mount /mnt/cdrom/LiveOS/squashfs.img /mnt/squashfs -t squashfs

# mount rootfs
mkdir /mnt/rootfs
mount /mnt/squashfs/LiveOS/rootfs.img /mnt/rootfs -t ext4

# copy rootfs
cp -r /mnt/rootfs rootfs
umount /mnt/rootfs
umount /mnt/squashfs
umount /mnt/cdrom
rm -r /mnt/rootfs /mnt/squashfs /mnt/cdrom

# mount dvd image under rootfs
mkdir rootfs/mnt/cdrom
mount ./CentOS-7-x86_64-Minimal-1708.iso rootfs/mnt/cdrom -t iso9660 -o loop

# chroot
mount -o bind /dev rootfs/dev/
mount -t proc none rootfs/proc/
mount -o bind /sys rootfs/sys/
chroot rootfs /bin/bash -xe << _END_CHROOT_

cd /mnt/cdrom/Packages
rpm -ivh --nodeps rpm-4.11.3-25.el7.x86_64.rpm
rpm -ivh --nodeps yum-3.4.3-154.el7.centos.noarch.rpm

# add the cdrom image to yum repository
cat << _END_ > /etc/yum.repos.d/cdrom.repo
[cdrom]
name=Install CD-ROM 
baseurl=file:///mnt/cdrom
enabled=0
gpgcheck=1
gpgkey=file:///mnt/cdrom/RPM-GPG-KEY-CentOS-7
_END_

yum --disablerepo=\* --enablerepo=cdrom -y reinstall yum
yum --disablerepo=\* --enablerepo=cdrom -y groupinstall "Minimal Install"
# yum --disablerepo=\* --enablerepo=cdrom -y install <required packages>

rm /etc/yum.repos.d/cdrom.repo

_END_CHROOT_

cp -r plymouth-start.service rootfs/usr/lib/systemd/system/
cp -r plymouth-quit-wait.service rootfs/usr/lib/systemd/system/

# Clean up
umount rootfs/mnt/cdrom
umount rootfs/dev
umount rootfs/proc
umount rootfs/sys


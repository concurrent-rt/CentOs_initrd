
__________________________________________________________________________________

                                Steps to build centos initrd image 
__________________________________________________________________________________



1)Download files from concurrent git repo to create rootfs and initrd image


   http://github.com/concurrent-rt/CentOs_initrd


This repo will download centos ISO image and other required files to create initrd image

1. createrootfs.sh  ->  This script will check out centos ISO image, create roofts and copy reqired files for virtual console


* Before runnning createrootfs.sh script make sure that you have plymouth-quit-wait.service and plymouth-start.service
  files are present in current working directory.

2) Run createrootfs.sh script which installs the minimal packages to rootfs for CentOS.

3) Use live.tar.gz to create the initrd by following these instructions:

	=> tar -xvf live.tar.gz
        => cd live
        => make install
        => cd RAMDISK
        => make ROOT=<your_rootfs_dir_created_by_createrootfs.sh>

* The above steps will build initrd.img file.

* We can use initrd.img file for Non-root cell.
  



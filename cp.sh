#!/bin/bash

rm -rf /root/lnmp
cp -r /mnt/vm_shared/lnmp  /root/
[ ! -d /root/lnmp_src ] && { cp -r /mnt/vm_shared/lnmp_src  /root/ ;}
ls /root/lnmp


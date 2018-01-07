#!/bin/bash
##################################################
#  LNMP for CentOS/RadHat Debian/Ubuntu 64bit
#  http://github.com/panxuepeng/lnmp
##################################################

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# 判断是否联网
isnetwork=`ping -c 2  mirrors.aliyun.com | grep ttl`

# Check if user is root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

lnmp_dir=`pwd`

installLog="/root/install.log"
script="$lnmp_dir/script.run"
stderr="$lnmp_dir/log"
stdout="$lnmp_dir/log"
firsttime=`date +%s`
starttime=$firsttime

. $lnmp_dir/func/check_os.sh

if [ OS_bit == 32 ]; then
    echo "Error: $OS must be 64bit"; exit 1
fi

echo `date "+%Y-%m-%d %H:%M:%S" ` >> $installLog

cd $lnmp_dir

. $lnmp_dir/func/log.sh
. $lnmp_dir/func/download.sh
. $lnmp_dir/func/check_memory.sh
. $lnmp_dir/func/set_service.sh
. $lnmp_dir/_version.conf
. $lnmp_dir/_options.conf

Install() {
    for file in ${script}/*.sh
    do
        echo $file
        sleep 5
        name=`basename $file`
        . $file 
        #1>$stdout/$name.txt 2>$stderr/$name.err
    done
}

if [ -d $etc_dir ]; then
    mkdir -p $etc_dir
fi

if [ ! -f $etc_dir/.copyed_etc ]; then
    cp -Rf $lnmp_dir/etc/*  $etc_dir/
    echo "have cp -Rf $lnmp_dir/etc/*  $etc_dir/" > $etc_dir/.copyed_etc
fi

if [ ! -d /data ]; then
    mkdir /data
fi

mkdir -p /data/logs/nginx
mkdir -p /data/logs/php
mkdir -p /data/wwwroot/default
mkdir -p /data/versions
mkdir -p /data/temp

if [ ! -f "/data/wwwroot/default/index.php" ]; then
    echo '<?php phpinfo();' > "/data/wwwroot/default/index.php"
fi

Install

echo -e "\n\n" >> $installLog
starttime=$firsttime
install_log_end
install_log '\nend'
  
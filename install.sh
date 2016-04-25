#!/bin/bash
##################################################
#        LNMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+  64bit
#                      http://github.com/panxuepeng/lnmp
##################################################
#
# mount -t vboxsf vm_shared /mnt/vm_shared
# ln -s /media/sf_lnmp

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Check if user is root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

lnmp_dir=`pwd`
script="$lnmp_dir/script"
oneName=$1
firsttime=`date +%s`
starttime=$firsttime

. $lnmp_dir/func/check_os.sh

if [ OS_bit == 32 ]; then
    echo "Error: $OS must be 64bit"; exit 1
fi

echo `date "+%Y-%m-%d %H:%M:%S" ` > $lnmp_dir/compile.log
echo `date "+%Y-%m-%d %H:%M:%S" ` >> $lnmp_dir/install.log

. $lnmp_dir/func/log.sh
. $lnmp_dir/func/download.sh
. $lnmp_dir/func/check_memory.sh
. $lnmp_dir/_version.conf
. $lnmp_dir/_options.conf

Install_All() {
    for name in init_$OS node mongodb mysql-$DB_version php-$PHP_version composer imagemagick graphicsmagick $Nginx_version redis memcached php-redis php-memcached demo phpmyadmin  
    do
        install_log_start $name
        . "$script/$name.sh"
        install_log_end
    done
}

Install_After() {
    # 只有整体安装时，才需要设置软连接和设置服务
    
    . $script/set_user.sh
    . $script/set_conf.sh
    . $script/set_service.sh
    . $script/set_link.sh
    
    
    # 最后重启服务
    # restart service
    for name in nginx  php-fpm  memcached  redis-server  mysqld
    do
        [ `ps aux|grep $name|grep -v grep|wc -l` -gt 0 ] && { killall $name; }
        service $name start
    done
}

Install() {

    if [ $oneName ]; then
        
        if [ -f "$script/$oneName.sh" ]; then
            .  "$script/$oneName.sh"
        else 
            echo "script name error, like php-7.0"
        fi
        
    else
        Install_All
        Install_After
        echo -e "\nInstall OK, Please reboot OS."
    fi
}

Install 2>&1 | tee -a /root/compile.log
#Install >> $lnmp_dir/compile.log
echo -e "\n\n" >> $lnmp_dir/install.log
starttime=$firsttime
install_log_end
install_log '\nend'
  
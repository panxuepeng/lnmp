#!/bin/bash

# 一般来说，本程序仅需要执行一次

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# 判断是否联网
isnetwork=`ping -c 2  mirrors.aliyun.com | grep ttl`
    
# Check if user is root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

lnmp_dir=`pwd`
installLog="/root/install.log"
stderr="$lnmp_dir/log"
stdout="$lnmp_dir/log"
firsttime=`date +%s`
starttime=$firsttime

. $lnmp_dir/func/check_os.sh

if [ OS_bit == 32 ]; then
    echo "Error: $OS must be 64bit"; exit 1
fi

echo `date "+%Y-%m-%d %H:%M:%S" ` >> $installLog

. $lnmp_dir/func/log.sh
. $lnmp_dir/func/download.sh
. $lnmp_dir/func/check_memory.sh
. $lnmp_dir/_version.conf
. $lnmp_dir/_options.conf

# 判断www用户是否存在，如果不存在则添加
id -u $www_user >/dev/null 2>&1
[ $? -ne 0 ] && useradd -M -s /sbin/nologin $www_user


# 安装PHP常见的依赖扩展等
Install_PHP_Require() {
    cd $lnmp_src
    src_url=http://ftp.gnu.org/pub/gnu/libiconv/libiconv-$libiconv_version.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/$libmcrypt_version/libmcrypt-$libmcrypt_version.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mhash/mhash/$mhash_version/mhash-$mhash_version.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mcrypt/MCrypt/$mcrypt_version/mcrypt-$mcrypt_version.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-$pcre_version.tar.gz && Download_src

    # libiconv
    tar xzf libiconv-$libiconv_version.tar.gz
    patch -d libiconv-$libiconv_version -p0 < libiconv-glibc-2.16.patch
    cd libiconv-$libiconv_version
    make clean
    ./configure --prefix=/usr/local
    make && make install
    cd ..

    # libmcrypt
    tar xzf libmcrypt-$libmcrypt_version.tar.gz
    cd libmcrypt-$libmcrypt_version
    make clean
    ./configure
    make && make install
    ldconfig
    cd libltdl
    make clean
    ./configure --enable-ltdl-install
    make && make install
    cd ../../

    # mhash
    tar xzf mhash-$mhash_version.tar.gz
    cd mhash-$mhash_version
    make clean
    ./configure
    make && make install
    cd ..

    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig

    [ "$OS" == 'CentOS' ] && { ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config; ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1; }

    # mcrypt
    tar xzf mcrypt-$mcrypt_version.tar.gz
    cd mcrypt-$mcrypt_version
    ldconfig
    make clean
    ./configure
    make && make install
    cd ..
    rm -rf mcrypt-$mcrypt_version

    # pcre
    tar xzf pcre-$pcre_version.tar.gz
    cd pcre-$pcre_version
    make clean
    ./configure
    make && make install
}

if [ -f "/root/lnmp-php-require.lock" ]; then
    install_log "/root/lnmp-php-require.lock is existing, nothing install."
else
    Install_PHP_Require
    touch /root/lnmp-php-require.lock
fi

#!/bin/bash

memcached_install_dir=$install_dir/memcached/$memcached_version

Install_memcached() {
    cd $lnmp_src
    src_url=http://www.memcached.org/files/memcached-$memcached_version.tar.gz && Download_src

    # memcached server
    id -u memcached >/dev/null 2>&1
    [ $? -ne 0 ] && useradd -M -s /sbin/nologin memcached

    tar xzf memcached-$memcached_version.tar.gz
    cd memcached-$memcached_version
    [ ! -d "$memcached_install_dir" ] && mkdir -p $memcached_install_dir
    make clean
    ./configure --prefix=$memcached_install_dir
    make && make install
    make clean
    
    if [ -d "$memcached_install_dir/include/memcached" ];then
        echo "memcached install success. "      
        install_log "$memcached_install_dir install success."
    else
        echo "memcached install failed. "
        install_log "$memcached_install_dir install failed!"
        kill -9 $$
    fi
}


if [ -d "$memcached_install_dir/include/memcached" ];then
    echo "memcached has installed"
    install_log "$memcached_install_dir is existing, nothing install."
else
    Install_memcached
fi


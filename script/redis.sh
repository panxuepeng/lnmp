#!/bin/bash

redis_install_dir=$install_dir/redis/$redis_version

Install_redis_server() {
    cd $lnmp_src
    src_url=http://download.redis.io/releases/redis-$redis_version.tar.gz && Download_src

    tar xzf redis-$redis_version.tar.gz
    cd redis-$redis_version
    
    make clean
    make

    if [ -f "src/redis-server" ];then
        mkdir -p $redis_install_dir/{bin,etc,var}
        /bin/cp src/{redis-benchmark,redis-check-aof,redis-check-dump,redis-cli,redis-sentinel,redis-server} $redis_install_dir/bin/
        /bin/cp redis.conf $redis_install_dir/etc/
        
        sed -i 's@pidfile.*@pidfile /var/run/redis.pid@' $redis_install_dir/etc/redis.conf
        sed -i "s@logfile.*@logfile $redis_install_dir/var/redis.log@" $redis_install_dir/etc/redis.conf
        sed -i "s@^dir.*@dir $redis_install_dir/var@" $redis_install_dir/etc/redis.conf
        sed -i 's@daemonize no@daemonize yes@' $redis_install_dir/etc/redis.conf
        sed -i "s@^# bind 127.0.0.1@bind 127.0.0.1@" $redis_install_dir/etc/redis.conf
        [ -z "`grep ^maxmemory $redis_install_dir/etc/redis.conf`" ] && sed -i "s@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory `expr $Mem / 8`000000@" $redis_install_dir/etc/redis.conf
        
        echo "Redis-server install success. "
        install_log "success: $redis_install_dir install"
    else
        echo "Redis-server install failed. "
        install_log "failed: $redis_install_dir install"
        kill -9 $$
    fi
}


if [ -d "$redis_install_dir" ];then
    echo "$redis_install_dir has installed"
    install_log "$redis_install_dir is existing, nothing install."
else
    Install_redis_server
fi

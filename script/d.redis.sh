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
        
        install_log "success: $redis_install_dir"
    else
        install_log "failed: $redis_install_dir"
        kill -9 $$
    fi
}


if [ -f "$redis_install_dir/bin/redis-server" ];then
    install_log "$redis_install_dir is existing, nothing install."
else
    Install_redis_server
fi

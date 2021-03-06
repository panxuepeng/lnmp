#!/bin/bash

mongodb_install_dir=$install_dir/mongodb/$mongodb_version

Install_mongodb() {
    cd $lnmp_src
    src_url=https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel62-$mongodb_version.tgz && Download_src
    tar -xzvf mongodb-linux-x86_64-rhel62-$mongodb_version.tgz
    mkdir -p $mongodb_install_dir/{bin,conf}
    mv  mongodb-linux-x86_64-rhel62-$mongodb_version/bin  $mongodb_install_dir/
    
    mkdir -p /data/mongodb
    
    /bin/cp $lnmp_dir/etc/mongodb/mongodb.conf $mongodb_install_dir/conf/mongodb.conf

    if [ -e "$mongodb_install_dir/bin/mongo" ]; then
        install_log "success: $mongodb_install_dir"
    else
        install_log "failed: $mongodb_install_dir"
    fi
}


if [ -e "$mongodb_install_dir/bin/mongo" ]; then
    install_log "$mongodb_install_dir is existing, nothing install."
else
    Install_mongodb
fi

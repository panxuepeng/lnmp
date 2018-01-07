#!/bin/bash
#pm2 startup centos

node_install_dir=$install_dir/node/$node_version

Install_node() {
    cd $lnmp_src
    src_url=https://nodejs.org/dist/v$node_version/node-v$node_version-linux-x64.tar.xz && Download_src
    xz -d node-v$node_version-linux-x64.tar.xz
    tar -xvf node-v$node_version-linux-x64.tar
    mkdir -p $node_install_dir
    mv  $lnmp_src/node-v$node_version-linux-x64/*  $node_install_dir
    

    if [ -e "$node_install_dir/bin/node" ]; then
        install_log "success: $node_install_dir"
    else
        install_log "failed: $node_install_dir"
    fi
}


if [ -e "$node_install_dir/bin/node" ]; then
    install_log "$node_install_dir is existing, nothing install."
else
    Install_node
fi

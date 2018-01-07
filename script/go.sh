#!/bin/bash
#pm2 startup centos
#export GOROOT=/home/forward/tools/go
#export PATH=$GOROOT/bin:$PATH
#export GOPATH=/home/forward/tools/gopkg
go_install_dir=$install_dir/go/$go_version

Install_Go() {
    cd $lnmp_src
    src_url=http://www.golangtc.com/static/go/$go_version/go$go_version.linux-amd64.tar.gz && Download_src
    tar -zxvf go$go_version.linux-amd64.tar.gz
    mkdir -p $go_install_dir
    mv  $lnmp_src/go/bin  $go_install_dir
    

    if [ -e "$go_install_dir/bin/go" ]; then
        install_log "success: $go_install_dir"
    else
        install_log "failed: $go_install_dir"
    fi
}


if [ -e "$go_install_dir/bin/go" ]; then
    install_log "$go_install_dir is existing, nothing install."
else
    Install_Go
fi

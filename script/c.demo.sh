#!/bin/bash

default_dir=$wwwroot_dir/default

DEMO() {
    cd $lnmp_src

    [ ! -d "$wwwroot_dir" ] && mkdir -p $wwwroot_dir
    [ ! -d "$wwwlogs_dir" ] && mkdir -p $wwwlogs_dir
    
    [ ! -d "$wwwroot_dir/default" ] && mkdir $default_dir
    [ -d "$wwwroot_dir" ] && chmod -R 755 $wwwroot_dir
    [ -d "$wwwlogs_dir" ] && chmod -R 755 $wwwlogs_dir
    
    #cp 之前判断文件是否存在
    if [ -d "$default_dir" ];then
    chown -R ${www_user}.$www_user  $default_dir
}

if [ -d "$default_dir" ];then
    install_log "$default_dir is existing, nothing install."
else
    DEMO
fi

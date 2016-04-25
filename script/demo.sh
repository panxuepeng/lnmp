#!/bin/bash



DEMO() {
    cd $lnmp_src

    [ ! -d "$wwwroot_dir" ] && mkdir -p $wwwroot_dir
    [ ! -d "$wwwlogs_dir" ] && mkdir -p $wwwlogs_dir
    
    [ ! -d "$wwwroot_dir/default" ] && mkdir $wwwroot_dir/default
    [ -d "$wwwroot_dir" ] && chmod 755 $wwwroot_dir
    [ -d "$wwwlogs_dir" ] && chmod 755 $wwwlogs_dir
    
    /bin/cp -rf $lnmp_src/default  $wwwroot_dir/
    chown -R ${run_user}.$run_user  $wwwroot_dir/default
}

DEMO



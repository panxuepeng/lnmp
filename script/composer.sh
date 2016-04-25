#!/bin/bash

composer_install_dir=$install_dir/composer/$composer_version

Install_composer() {
    

    cd $lnmp_src
    src_url=https://getcomposer.org/download/$composer_version/composer.phar && Download_src
    
    if [ ! -d $composer_install_dir ]; then
        mkdir -p $composer_install_dir
    fi
    
    /bin/cp -f $lnmp_src/composer.phar  $composer_install_dir/composer
    chmod +x  $composer_install_dir/composer
    

    if [ -e "$composer_install_dir/composer" ]; then
        install_log "success: $composer_install_dir install"
    else
        install_log "failed: $composer_install_dir install"
    fi
}


if [ -d "$composer_install_dir" ];then
    install_log "$composer_install_dir is existing, nothing install."
else
    Install_composer
fi

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

        [ -d "/usr/local/composer" ] && rm -f /usr/local/composer
        ln -s $composer_install_dir /usr/local/composer
        ln -s /usr/local/composer/composer  /usr/local/bin/composer

        # 设置国内镜像源
        composer config -g repo.packagist composer https://packagist.laravel-china.org
        
        install_log "success: $composer_install_dir install"
    else
        install_log "failed: $composer_install_dir install"
    fi
}


if [ -e "$composer_install_dir/composer" ];then
    install_log "$composer_install_dir is existing, nothing install."
elif [ -z "$isnetwork" ]; then
    install_log "failed: network is offline, not install composer"
else
    Install_composer
fi

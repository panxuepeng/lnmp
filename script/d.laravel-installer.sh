#!/bin/bash
if [ -z "$isnetwork" ]; then
        install_log "failed: network is offline, not install laravel"
else
    mkdir $install_dir/laravel
    cd $install_dir/laravel

    composer require "laravel/installer"|su - www
    rm -f /usr/local/bin/laravel
    ln -s /root/.composer/vendor/laravel/installer/laravel  /usr/local/bin/laravel
fi

#cd $wwwroot_dir/default
#laravel new todos
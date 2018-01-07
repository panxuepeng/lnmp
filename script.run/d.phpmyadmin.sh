#!/bin/bash

phpmyadmin_install_dir=$install_dir/phpMyAdmin/$phpMyAdmin_version

Install_phpMyAdmin() {
    cd $lnmp_src
    src_url=https://files.phpmyadmin.net/phpMyAdmin/${phpMyAdmin_version}/phpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz && Download_src

    tar xzf phpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz
    mkdir -p $install_dir/phpMyAdmin

    /bin/mv phpMyAdmin-${phpMyAdmin_version}-all-languages $phpmyadmin_install_dir
    /bin/cp $phpmyadmin_install_dir/{config.sample.inc.php,config.inc.php}
    mkdir $phpmyadmin_install_dir/{upload,save}
    
    sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" $phpmyadmin_install_dir/config.inc.php
    sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" $phpmyadmin_install_dir/config.inc.php
    sed -i "s@blowfish_secret.*;@blowfish_secret\'\] = \'`cat /dev/urandom | head -1 | md5sum | head -c 10`\';@" $phpmyadmin_install_dir/config.inc.php
    chown -R ${www_user}.$www_user $install_dir/phpMyAdmin

    if [ ! -d $install_dir/phpMyAdmin/default ];then
        ln -s $phpmyadmin_install_dir  $install_dir/phpMyAdmin/default
        install_log "ln -s $phpmyadmin_install_dir  $install_dir/phpMyAdmin/default"
    fi
}

if [ -d "$phpmyadmin_install_dir" ];then
    install_log "$phpmyadmin_install_dir is existing, nothing install."
else
    Install_phpMyAdmin
fi

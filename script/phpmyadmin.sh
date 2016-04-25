#!/bin/bash


Install_phpMyAdmin() {
    cd $lnmp_src
    src_url=https://files.phpmyadmin.net/phpMyAdmin/${phpMyAdmin_version}/phpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz && Download_src

    tar xzf phpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz
    /bin/mv phpMyAdmin-${phpMyAdmin_version}-all-languages $wwwroot_dir/default/phpMyAdmin
    /bin/cp $wwwroot_dir/default/phpMyAdmin/{config.sample.inc.php,config.inc.php}
    mkdir $wwwroot_dir/default/phpMyAdmin/{upload,save}
    sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" $wwwroot_dir/default/phpMyAdmin/config.inc.php
    sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" $wwwroot_dir/default/phpMyAdmin/config.inc.php
    sed -i "s@blowfish_secret.*;@blowfish_secret\'\] = \'`cat /dev/urandom | head -1 | md5sum | head -c 10`\';@" $wwwroot_dir/default/phpMyAdmin/config.inc.php
    chown -R ${run_user}.$run_user $wwwroot_dir/default/phpMyAdmin
}

Install_phpMyAdmin

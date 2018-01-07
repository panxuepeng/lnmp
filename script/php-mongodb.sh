#!/bin/bash

Install_php_mongodb() {
    php_install_dir=$1

    if [ -e "`$php_install_dir/bin/php-config --extension-dir`/mongodb.so" ]; then
        install_log "$php_install_dir: mongodb.so is existing, nothing install."
    else
        cd $lnmp_src
        src_url=http://pecl.php.net/get/mongodb-$mongodb_pecl_version.tgz && Download_src
        tar xzf mongodb-$mongodb_pecl_version.tgz
        cd mongodb-$mongodb_pecl_version
        
        make clean
        $php_install_dir/bin/phpize
        ./configure --with-php-config=$php_install_dir/bin/php-config
        make && make install
        
        if [ -f "`$php_install_dir/bin/php-config --extension-dir`/mongodb.so" ];then
            cat > $php_install_dir/etc/php.d/ext-mongodb.ini << EOF
[redis]
extension=mongodb.so
EOF
            install_log "success: $php_install_dir: mongodb.so"
        else
            install_log "failed: $php_install_dir: mongodb.so"
        fi
    fi
}

[ -e "$php70_install_dir/bin/php" ] && Install_php_mongodb  $php70_install_dir
[ -e "$php56_install_dir/bin/php" ] && Install_php_mongodb  $php56_install_dir
#[ -e "$php53_install_dir/bin/php" ] && Install_php_mongodb  $php53_install_dir

#!/bin/bash

Install_php_mongo() {
    php_install_dir=$1

    if [ -e "`$php_install_dir/bin/php-config --extension-dir`/mongo.so" ]; then
        install_log "$php_install_dir: mongo.so is existing, nothing install."
    else
        cd $lnmp_src
        src_url=http://pecl.php.net/get/mongo-$mongo_pecl_version.tgz && Download_src
        tar xzf mongo-$mongo_pecl_version.tgz
        cd mongo-$mongo_pecl_version
        
        make clean
        $php_install_dir/bin/phpize
        ./configure --with-php-config=$php_install_dir/bin/php-config
        make && make install
        
        if [ -f "`$php_install_dir/bin/php-config --extension-dir`/mongo.so" ];then
            cat > $php_install_dir/etc/php.d/ext-mongo.ini << EOF
[redis]
extension=mongo.so
EOF
            install_log "success: $php_install_dir: mongo.so"
        else
            install_log "failed: $php_install_dir: mongo.so"
        fi
    fi
}

#[ -e "$php70_install_dir/bin/php" ] && Install_php_mongo  $php70_install_dir

[ -e "$php56_install_dir/bin/php" ] && Install_php_mongo  $php56_install_dir
[ -e "$php53_install_dir/bin/php" ] && Install_php_mongo  $php53_install_dir

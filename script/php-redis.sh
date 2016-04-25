#!/bin/bash


    Install_php_redis() {
    cd $lnmp_src
    if [ -e "$php_install_dir/bin/phpize" ];then
        if [ "`$php_install_dir/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ];then
            #git clone -b php7 https://github.com/phpredis/phpredis.git
            #cd phpredis
            src_url=http://mirrors.linuxeye.com/oneinstack/src/phpredis-php7.tgz && Download_src
            tar xzf phpredis-php7.tgz
            cd phpredis-php7
        else
            src_url=http://pecl.php.net/get/redis-$redis_pecl_version.tgz && Download_src
            tar xzf redis-$redis_pecl_version.tgz
            cd redis-$redis_pecl_version
        fi
        
        make clean
        $php_install_dir/bin/phpize
        ./configure --with-php-config=$php_install_dir/bin/php-config
        make && make install
        
        if [ -f "`$php_install_dir/bin/php-config --extension-dir`/redis.so" ];then
            cat > $php_install_dir/etc/php.d/ext-redis.ini << EOF
[redis]
extension=redis.so
EOF
            echo "PHP Redis module install success. "
            install_log "success: $php_install_dir/bin/php-config: redis.so"
        else
            echo "PHP Redis module install failed. "
            install_log "failed: $php_install_dir/bin/php-config: redis.so"
        fi
    fi
}

if [ -e "$php_install_dir/bin/phpize" ]; then
    if [ -e "`$php_install_dir/bin/php-config --extension-dir`/redis.so" ]; then
        install_log "redis.so is existing, nothing install."
    else
        Install_php_redis
    fi
else
   install_log "redis.so: $php_install_dir/bin/phpize is not existing, nothing install."
fi

#!/bin/bash

Install_php_redis() {
    php_install_dir=$1
    php_version=$2

    if [ -e "`$php_install_dir/bin/php-config --extension-dir`/redis.so" ]; then
        install_log "$php_install_dir: redis.so is existing, nothing install."
    else
        cd $lnmp_src
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
            cat > $etc_dir/php-$php_version/php.d/ext-redis.ini << EOF
[redis]
extension=redis.so
EOF
            install_log "success: $php_install_dir: redis.so"
        else
            install_log "failed: $php_install_dir: redis.so"
        fi
    fi
}

[ -e "$php70_install_dir/bin/php" ] && Install_php_redis  $php70_install_dir  "7.0"
[ -e "$php56_install_dir/bin/php" ] && Install_php_redis  $php56_install_dir  "5.6"
[ -e "$php53_install_dir/bin/php" ] && Install_php_redis  $php53_install_dir  "5.3"

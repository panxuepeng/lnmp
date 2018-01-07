#!/bin/bash

Install_php_memcache() {
    php_install_dir=$1

    if [ -e "`$php_install_dir/bin/php-config --extension-dir`/memcache.so" ]; then
        install_log "$php_install_dir: memcache.so is existing, nothing install."
    else
        cd $lnmp_src
        # php memcache extension
        if [ "`$php_install_dir/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ];then
            #git clone https://github.com/websupport-sk/pecl-memcache.git
            #cd pecl-memcache
            src_url=http://mirrors.linuxeye.com/oneinstack/src/pecl-memcache-php7.tgz && Download_src
            tar xzf pecl-memcache-php7.tgz
            cd pecl-memcache-php7
        else
            src_url=http://pecl.php.net/get/memcache-$memcache_pecl_version.tgz && Download_src
            tar xzf memcache-$memcache_pecl_version.tgz 
            cd memcache-$memcache_pecl_version 
        fi
        
        make clean
        $php_install_dir/bin/phpize
        ./configure --with-php-config=$php_install_dir/bin/php-config
        make && make install
        make clean
        
        if [ -f "`$php_install_dir/bin/php-config --extension-dir`/memcache.so" ];then
            cat > $php_install_dir/etc/php.d/ext-memcache.ini << EOF
extension=memcache.so
EOF
            install_log "success: $php_install_dir: memcache.so"
        else
            install_log "failed: $php_install_dir: memcache.so"
        fi
    fi
}

[ -e "$php70_install_dir/bin/php" ] && Install_php_memcache  $php70_install_dir

[ -e "$php56_install_dir/bin/php" ] && Install_php_memcache  $php56_install_dir


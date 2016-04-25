#!/bin/bash

Install_php_memcache() {
    cd $lnmp_src
    if [ -e "$php_install_dir/bin/phpize" ];then
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
            echo "PHP memcache module install success. "
            install_log "success: $php_install_dir/bin/php-config: memcache.so"
        else
            echo "PHP memcache module install failed." 
            install_log "failed: $php_install_dir/bin/php-config: memcache.so"
        fi
    fi
}

Install_php_memcached() {
    cd $lnmp_src
    if [ -e "$php_install_dir/bin/phpize" ];then
        src_url=https://launchpad.net/libmemcached/1.0/$libmemcached_version/+download/libmemcached-$libmemcached_version.tar.gz && Download_src
        # php memcached extension
        tar xzf libmemcached-$libmemcached_version.tar.gz
        cd libmemcached-$libmemcached_version
        [ "$OS" == 'CentOS' ] && yum -y install cyrus-sasl-devel 
        [[ $OS =~ ^Ubuntu$|^Debian$ ]] && sed -i "s@lthread -pthread -pthreads@lthread -lpthread -pthreads@" ./configure 
        ./configure --with-memcached=$memcached_install_dir
        make && make install
        make clean
        cd ..
        rm -rf libmemcached-$libmemcached_version

        if [ "`$php_install_dir/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ];then
            #git clone -b php7 https://github.com/php-memcached-dev/php-memcached.git 
            #cd php-memcached 
            src_url=http://mirrors.linuxeye.com/oneinstack/src/php-memcached-php7.tgz && Download_src
            tar xzf php-memcached-php7.tgz
            cd php-memcached-php7
        else
            src_url=http://pecl.php.net/get/memcached-$memcached_pecl_version.tgz && Download_src
            tar xzf memcached-$memcached_pecl_version.tgz
            cd memcached-$memcached_pecl_version
        fi
        make clean
        $php_install_dir/bin/phpize
        ./configure --with-php-config=$php_install_dir/bin/php-config
        make && make install
        
        if [ -f "`$php_install_dir/bin/php-config --extension-dir`/memcached.so" ];then
            cat > $php_install_dir/etc/php.d/ext-memcached.ini << EOF
extension=memcached.so
memcached.use_sasl=1
EOF
            echo "PHP memcached module install success. "
            install_log "success: $php_install_dir/bin/php-config: memcached.so"
        else
            echo "PHP memcached module install failed. " 
            install_log "failed: $php_install_dir/bin/php-config: memcached.so"
        fi
    fi
}


if [ -e "$php_install_dir/bin/phpize" ]; then

    if [ -e "`$php_install_dir/bin/php-config --extension-dir`/memcache.so" ]; then
        install_log "memcache.so is existing, nothing install."
    else
        Install_php_memcache
    fi
    
    if [ -e "`$php_install_dir/bin/php-config --extension-dir`/memcached.so" ]; then
        install_log "memcached.so is existing, nothing install."
    else
        Install_php_memcached
    fi
    
else
   install_log "memcached.so: $php_install_dir/bin/phpize is not existing, nothing install."
fi

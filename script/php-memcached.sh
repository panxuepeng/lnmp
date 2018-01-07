#!/bin/bash

Install_php_memcached() {
    php_install_dir=$1
    
    if [ -e "`$php_install_dir/bin/php-config --extension-dir`/memcached.so" ]; then
        install_log "$php_install_dir: memcached.so is existing, nothing install."
    else
        cd $lnmp_src
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
            install_log "success: $php_install_dir: memcached.so"
        else
            install_log "failed: $php_install_dir: memcached.so"
        fi
    fi
}

[ -e "$php70_install_dir/bin/php" ] && Install_php_memcached  $php70_install_dir
[ -e "$php56_install_dir/bin/php" ] && Install_php_memcached  $php56_install_dir
[ -e "$php53_install_dir/bin/php" ] && Install_php_memcached  $php53_install_dir

#!/bin/bash

php70_install_dir=$install_dir/php/$php_version_70

Install_PHP70() {
    cd $lnmp_src
    php_etc_dir=$etc_dir/php-7.0
    src_url=http://www.php.net/distributions/php-$php_version_70.tar.gz && Download_src

    # php
    tar xzf php-$php_version_70.tar.gz 
    cd php-$php_version_70
    make clean
    ./buildconf
    [ ! -d "$php70_install_dir" ] && mkdir -p $php70_install_dir

    ./configure --prefix=$php70_install_dir --with-config-file-path=$php_etc_dir/ \
    --with-config-file-scan-dir=$php_etc_dir/php.d \
    --with-fpm-user=$www_user --with-fpm-group=$www_user --enable-fpm --enable-opcache --disable-fileinfo \
    --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
    --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
    --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-inline-optimization \
    --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl \
    --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp --enable-intl --with-xsl \
    --with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug --without-pear

    make ZEND_EXTRA_LIBS='-liconv'
    make install

    if [ -e "$php70_install_dir/bin/phpize" ];then
        install_log "success: $php70_install_dir"

        rm -f /usr/local/php70
        ln -sf $php70_install_dir  /usr/local/php70

        if [ ! -f /usr/local/bin/php ];then
            ln -s $php70_install_dir/bin/php  /usr/local/bin/php
        fi

        set_service "php70-fpm"

 
    else
        rm -rf $php70_install_dir
        install_log "failed: $php70_install_dir"
        kill -9 $$
    fi
        
    
    [ -e "$php70_install_dir/bin/phpize" ] && rm -rf php-$php_version_70
}


if [ -e "$php70_install_dir/bin/phpize" ]; then
    install_log "$php70_install_dir is existing, nothing install."
else
    Install_PHP70
fi

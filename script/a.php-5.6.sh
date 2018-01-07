#!/bin/bash

php56_install_dir=$install_dir/php/$php_version_56

Install_PHP56() {
    cd $lnmp_src
    src_url=http://www.php.net/distributions/php-$php_version_56.tar.gz && Download_src

    tar xzf php-$php_version_56.tar.gz
    cd php-$php_version_56
    make clean
    [ ! -d "$php56_install_dir" ] && mkdir -p $php56_install_dir

    ./configure --prefix=$php56_install_dir --with-config-file-path=$php56_install_dir/etc \
    --with-config-file-scan-dir=$php56_install_dir/etc/php.d \
    --with-fpm-user=$www_user --with-fpm-group=$www_user --enable-fpm --enable-opcache --disable-fileinfo \
    --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
    --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
    --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-inline-optimization \
    --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl \
    --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp --enable-intl --with-xsl \
    --with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug --without-pear

    make ZEND_EXTRA_LIBS='-liconv'
    make install

    if [ -e "$php56_install_dir/bin/phpize" ];then
        install_log "success: $php56_install_dir"

        rm -f /usr/local/php56
        ln -s $php56_install_dir  /usr/local/php56
        set_service "php56-fpm"
    else
        rm -rf $php56_install_dir
        install_log "failed: $php56_install_dir"
        kill -9 $$
    fi
    
    [ -e "$php56_install_dir/bin/phpize" ] && rm -rf php-$php_version_56
}


if [ -e "$php56_install_dir/bin/phpize" ]; then
    install_log "$php56_install_dir is existing, nothing install."
else
    Install_PHP56
fi

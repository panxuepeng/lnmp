#!/bin/bash

php_version=$php_version_53
php53_install_dir=$install_dir/php/$php_version

Install_PHP53() {
    cd $lnmp_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/fpm-race-condition.patch && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch && Download_src
    src_url=http://www.php.net/distributions/php-$php_version.tar.gz && Download_src

    tar xzf php-$php_version.tar.gz
    patch -d php-$php_version -p0 < fpm-race-condition.patch
    cd php-$php_version
    patch -p1 < ../php5.3patch 
    patch -p1 < ../debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    make clean
    [ ! -d "$php53_install_dir" ] && mkdir -p $php53_install_dir
    ./configure --prefix=$php53_install_dir --with-config-file-path=$php53_install_dir/etc \
    --with-config-file-scan-dir=$php53_install_dir/etc/php.d \
    --with-fpm-user=$www_user --with-fpm-group=$www_user --enable-fpm --disable-fileinfo \
    --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
    --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
    --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex \
    --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl \
    --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp --enable-intl --with-xsl \
    --with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug --without-pear
    
    sed -i '/^BUILD_/ s/\$(CC)/\$(CXX)/g' Makefile
    make ZEND_EXTRA_LIBS='-liconv'
    make install

    if [ -e "$php53_install_dir/bin/phpize" ];then
       install_log "success: $php53_install_dir"
        ln -sf $php53_install_dir  /usr/local/php53

        [ ! -e "$php53_install_dir/etc/php.d" ] && mkdir -p $php53_install_dir/etc/php.d
        [ ! -e "$php53_install_dir/etc/php-fpm.d" ] && mkdir -p $php53_install_dir/etc/php-fpm.d
        /bin/cp -f $lnmp_dir/etc/php-5.3/php.ini  $php53_install_dir/etc/php.ini
        /bin/cp -f $lnmp_dir/etc/php-5.3/php-fpm.conf  $php53_install_dir/etc/php-fpm.conf
        /bin/cp -f $lnmp_dir/etc/php-5.3/php-fpm.d/www.conf  $php53_install_dir/etc/php-fpm.d/www.conf

    else
        rm -rf $php53_install_dir
        install_log "failed: $php53_install_dir"
        kill -9 $$
    fi

    [ -e "$php53_install_dir/bin/phpize" ] && rm -rf php-$php_version
}


if [ -e "$php53_install_dir/bin/phpize" ]; then
    install_log "$php56_install_dir is existing, nothing install."    
else
    Install_PHP53
fi

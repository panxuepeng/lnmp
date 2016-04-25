#!/bin/bash

php_version=$php_version_70
php_install_dir=$install_dir/php/$php_version

Install_PHP() {
    cd $lnmp_src
    src_url=http://ftp.gnu.org/pub/gnu/libiconv/libiconv-$libiconv_version.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/$libmcrypt_version/libmcrypt-$libmcrypt_version.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mhash/mhash/$mhash_version/mhash-$mhash_version.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mcrypt/MCrypt/$mcrypt_version/mcrypt-$mcrypt_version.tar.gz && Download_src
    src_url=http://www.php.net/distributions/php-$php_version.tar.gz && Download_src

    # libiconv
    tar xzf libiconv-$libiconv_version.tar.gz
    patch -d libiconv-$libiconv_version -p0 < libiconv-glibc-2.16.patch
    cd libiconv-$libiconv_version
    make clean
    ./configure --prefix=/usr/local
    make && make install
    cd ..

    # libmcrypt
    tar xzf libmcrypt-$libmcrypt_version.tar.gz
    cd libmcrypt-$libmcrypt_version
    make clean
    ./configure
    make && make install
    ldconfig
    cd libltdl
    make clean
    ./configure --enable-ltdl-install
    make && make install
    cd ../../

    # mhash
    tar xzf mhash-$mhash_version.tar.gz
    cd mhash-$mhash_version
    make clean
    ./configure
    make && make install
    cd ..

    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig

    [ "$OS" == 'CentOS' ] && { ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config; ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1; }

    # mcrypt
    tar xzf mcrypt-$mcrypt_version.tar.gz
    cd mcrypt-$mcrypt_version
    ldconfig
    make clean
    ./configure
    make && make install
    cd ..
    rm -rf mcrypt-$mcrypt_version

    id -u $run_user >/dev/null 2>&1
    [ $? -ne 0 ] && useradd -M -s /sbin/nologin $run_user 

    # php
    tar xzf php-$php_version.tar.gz 
    cd php-$php_version
    make clean
    ./buildconf
    [ ! -d "$php_install_dir" ] && mkdir -p $php_install_dir
    [ "$PHP_cache" == '1' ] && PHP_cache_tmp='--enable-opcache' || PHP_cache_tmp='--disable-opcache'

    ./configure --prefix=$php_install_dir --with-config-file-path=$php_install_dir/etc \
    --with-config-file-scan-dir=$php_install_dir/etc/php.d \
    --with-fpm-user=$run_user --with-fpm-group=$run_user --enable-fpm $PHP_cache_tmp --disable-fileinfo \
    --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
    --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
    --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-inline-optimization \
    --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl \
    --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp --enable-intl --with-xsl \
    --with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug --without-pear

    make ZEND_EXTRA_LIBS='-liconv'
    make install

    if [ -e "$php_install_dir/bin/phpize" ];then
        echo "PHP install success. "
        install_log "success: $php_install_dir install"
    else
        rm -rf $php_install_dir
        echo "PHP install failed! "
        install_log "failed: $php_install_dir install"
        kill -9 $$
    fi

    [ ! -e "$php_install_dir/etc/php.d" ] && mkdir -p $php_install_dir/etc/php.d
    /bin/cp php.ini-production $php_install_dir/etc/php.ini


    /bin/cp $lnmp_dir/etc/php-7.0/php-fpm.conf  $php_install_dir/etc/php-fpm.conf
    /bin/cp $lnmp_dir/etc/php-7.0/php-fpm.d/www.conf  $php_install_dir/etc/php-fpm.d/www.conf

    sed -i "s@^listen =.*@listen = $IPADDR:9000@" $php_install_dir/etc/php-fpm.conf
    
}


if [ -d "$php_install_dir" ]; then
    echo "$php_install_dir is existing"
    install_log "$php_install_dir is existing, nothing install."
else
    Install_PHP
    
fi

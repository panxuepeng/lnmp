#!/bin/bash

imagemagick_install_dir=$install_dir/imagemagick/$ImageMagick_version

Install_jpegsrc() {

    cd $lnmp_src
    src_url=http://www.ijg.org/files/jpegsrc.v9b.tar.gz && Download_src

    tar zxvf jpegsrc.v9b.tar.gz
    cd jpeg-9b
    make clean
    ./configure --prefix=/usr/local
    make libdir=/usr/lib64
    make libdir=/usr/lib64 install

    install_log "jpegsrc.v9b install commplete."
}

Install_libpng() {

    cd $lnmp_src
    src_url=http://prdownloads.sourceforge.net/libpng/libpng-1.6.21.tar.gz && Download_src
    
    tar zxvf libpng-1.6.21.tar.gz
    cd libpng-1.6.21
    make clean
    sudo LDFLAGS="-L/usr/local/lib" CPPFLAGS="-I/usr/local/include" ./configure --prefix=/usr/local
    make libdir=/usr/lib64
    make libdir=/usr/lib64 install

    install_log "libpng-1.6.21 install commplete."
}

Install_ImageMagick() {

    cd $lnmp_src
    src_url=http://downloads.sourceforge.net/project/imagemagick/old-sources/6.x/6.8/ImageMagick-$ImageMagick_version.tar.gz && Download_src

    tar xzf ImageMagick-$ImageMagick_version.tar.gz
    cd ImageMagick-$ImageMagick_version
    make clean
    ./configure --prefix=$imagemagick_install_dir --enable-shared --enable-static
    make && make install

    install_log "ImageMagick install commplete."
}

Install_php_imagick() {
    cd $lnmp_src
    if [ -e "$php_install_dir/bin/phpize" ];then
        if [ "`$php_install_dir/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ];then
            src_url=https://pecl.php.net/get/imagick-3.4.1.tgz && Download_src
            tar xzf imagick-3.4.1.tgz
            cd imagick-3.4.1
        else
            src_url=http://pecl.php.net/get/imagick-$imagick_version.tgz && Download_src
            tar xzf imagick-$imagick_version.tgz
            cd imagick-$imagick_version
        fi
        make clean
        export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
        $php_install_dir/bin/phpize
        ./configure --with-php-config=$php_install_dir/bin/php-config --with-imagick=$imagemagick_install_dir
        make && make install
        cd ..
        rm -rf imagick-$imagick_version

        if [ -f "`$php_install_dir/bin/php-config --extension-dir`/imagick.so" ];then
            cat > $php_install_dir/etc/php.d/ext-imagick.ini << EOF
[imagick]
extension=imagick.so
EOF
            install_log "success: $php_install_dir/bin/php-config: imagick.so"
        else
            echo "PHP imagick module install failed. "
            install_log "failed: $php_install_dir/bin/php-config: imagick.so"
        fi
    fi
}

if [ -d $imagemagick_install_dir ]; then
    install_log "$imagemagick_install_dir is existing, nothing install."
else
    Install_jpegsrc
    Install_libpng
    Install_ImageMagick
fi

if [ -e "`$php_install_dir/bin/php-config --extension-dir`/imagick.so" ]; then
    install_log "$php_install_dir/bin/php-config: imagick.so is existing, nothing install."
else
    Install_php_imagick
fi

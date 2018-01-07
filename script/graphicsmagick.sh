#!/bin/bash

graphicsmagick_install_dir=$install_dir/graphicsmagick/$GraphicsMagick_version

Install_GraphicsMagick() {
    cd $lnmp_src
    src_url=http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/$GraphicsMagick_version/GraphicsMagick-$GraphicsMagick_version.tar.gz && Download_src

    tar xzf GraphicsMagick-$GraphicsMagick_version.tar.gz 
    cd GraphicsMagick-$GraphicsMagick_version
    make clean
    ./configure --prefix=$graphicsmagick_install_dir --enable-shared --enable-static
    make && make install

    install_log "GraphicsMagick install commplete."
}

Install_php_gmagick() {
    php_install_dir=$1
    if [ -e "`$php_install_dir/bin/php-config --extension-dir`/gmagick.so" ]; then
        install_log "$php_install_dir: gmagick.so is existing, nothing install."
    else

        cd $lnmp_src
        if [ "`$php_install_dir/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ];then
            src_url=https://pecl.php.net/get/gmagick-2.0.2RC2.tgz && Download_src
            tar xzf gmagick-2.0.2RC2.tgz 
            cd gmagick-2.0.2RC2
        else
            src_url=http://pecl.php.net/get/gmagick-$gmagick_version.tgz && Download_src
            tar xzf gmagick-$gmagick_version.tgz 
            cd gmagick-$gmagick_version
        fi
        
        make clean
        export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
        $php_install_dir/bin/phpize
        ./configure --with-php-config=$php_install_dir/bin/php-config --with-gmagick=$graphicsmagick_install_dir
        make && make install

        if [ -f "`$php_install_dir/bin/php-config --extension-dir`/gmagick.so" ];then
            cat > $php_install_dir/etc/php.d/ext-gmagick.ini << EOF
[gmagick]
extension=gmagick.so
EOF
            install_log "success: $php_install_dir/bin/php-config: gmagick.so"
        else
            install_log "failed: $php_install_dir/bin/php-config: gmagick.so"
        fi
    fi
}

if [ -d $graphicsmagick_install_dir ]; then
    install_log "$graphicsmagick_install_dir is existing, nothing install."
else
    Install_GraphicsMagick
fi

[ -e "$php70_install_dir/bin/php" ] && Install_php_gmagick  $php70_install_dir
[ -e "$php56_install_dir/bin/php" ] && Install_php_gmagick  $php56_install_dir
[ -e "$php53_install_dir/bin/php" ] && Install_php_gmagick  $php53_install_dir

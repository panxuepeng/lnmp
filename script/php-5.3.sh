#!/bin/bash

php_version=$php_version_53
php_install_dir=$install_dir/php/$php_version

Install_PHP() {

    cd $lnmp_src
    src_url=http://ftp.gnu.org/pub/gnu/libiconv/libiconv-$libiconv_version.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/$libmcrypt_version/libmcrypt-$libmcrypt_version.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mhash/mhash/$mhash_version/mhash-$mhash_version.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mcrypt/MCrypt/$mcrypt_version/mcrypt-$mcrypt_version.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/fpm-race-condition.patch && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch && Download_src
    src_url=http://www.php.net/distributions/php-$php_version.tar.gz && Download_src

    tar xzf libiconv-$libiconv_version.tar.gz
    patch -d libiconv-$libiconv_version -p0 < libiconv-glibc-2.16.patch
    cd libiconv-$libiconv_version
    ./configure --prefix=/usr/local
    make && make install
    cd ..
    rm -rf libiconv-$libiconv_version

    tar xzf libmcrypt-$libmcrypt_version.tar.gz
    cd libmcrypt-$libmcrypt_version
    ./configure
    make && make install
    ldconfig
    cd libltdl
    ./configure --enable-ltdl-install
    make && make install
    cd ../../
    rm -rf libmcrypt-$libmcrypt_version

    tar xzf mhash-$mhash_version.tar.gz
    cd mhash-$mhash_version
    ./configure
    make && make install
    cd ..
    rm -rf mhash-$mhash_version 

    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig
    [ "$OS" == 'CentOS' ] && { ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config; ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1; }

    [ ! -e '/usr/include/freetype2/freetype' ] &&  ln -s /usr/include/freetype2 /usr/include/freetype2/freetype

    tar xzf mcrypt-$mcrypt_version.tar.gz
    cd mcrypt-$mcrypt_version
    ldconfig
    ./configure
    make && make install
    cd ..
    rm -rf mcrypt-$mcrypt_version 

    id -u $run_user >/dev/null 2>&1
    [ $? -ne 0 ] && useradd -M -s /sbin/nologin $run_user 

    tar xzf php-$php_version.tar.gz
    patch -d php-$php_version -p0 < fpm-race-condition.patch
    cd php-$php_version
    patch -p1 < ../php5.3patch 
    patch -p1 < ../debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    make clean
    [ ! -d "$php_install_dir" ] && mkdir -p $php_install_dir
    ./configure --prefix=$php_install_dir --with-config-file-path=$php_install_dir/etc \
    --with-config-file-scan-dir=$php_install_dir/etc/php.d \
    --with-fpm-user=$run_user --with-fpm-group=$run_user --enable-fpm --disable-fileinfo \
    --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
    --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
    --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex \
    --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl \
    --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp --enable-intl --with-xsl \
    --with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug
    
    sed -i '/^BUILD_/ s/\$(CC)/\$(CXX)/g' Makefile
    make ZEND_EXTRA_LIBS='-liconv'
    make install

    if [ -e "$php_install_dir/bin/phpize" ];then
        echo "PHP install success. "
    else
        rm -rf $php_install_dir
        echo "PHP install failed, Please Contact the author! "
        kill -9 $$
    fi

    . /etc/profile

    # wget -c http://pear.php.net/go-pear.phar
    # $php_install_dir/bin/php go-pear.phar

    [ ! -e "$php_install_dir/etc/php.d" ] && mkdir -p $php_install_dir/etc/php.d
    /bin/cp php.ini-production $php_install_dir/etc/php.ini

    sed -i "s@^memory_limit.*@memory_limit = ${Memory_limit}M@" $php_install_dir/etc/php.ini
    sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' $php_install_dir/etc/php.ini
    sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' $php_install_dir/etc/php.ini
    sed -i 's@^short_open_tag = Off@short_open_tag = On@' $php_install_dir/etc/php.ini
    sed -i 's@^expose_php = On@expose_php = Off@' $php_install_dir/etc/php.ini
    sed -i 's@^request_order.*@request_order = "CGP"@' $php_install_dir/etc/php.ini
    sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' $php_install_dir/etc/php.ini
    sed -i 's@^post_max_size.*@post_max_size = 100M@' $php_install_dir/etc/php.ini
    sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' $php_install_dir/etc/php.ini
    sed -i 's@^max_execution_time.*@max_execution_time = 5@' $php_install_dir/etc/php.ini
    sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' $php_install_dir/etc/php.ini
    [ -e /usr/sbin/sendmail ] && sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' $php_install_dir/etc/php.ini


    cat > $php_install_dir/etc/php-fpm.conf <<EOF
;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
; Global Options ;
;;;;;;;;;;;;;;;;;;

[global]
pid = run/php-fpm.pid
error_log = log/php-fpm.log
log_level = warning 

emergency_restart_threshold = 30
emergency_restart_interval = 60s 
process_control_timeout = 5s
daemonize = yes

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ;
;;;;;;;;;;;;;;;;;;;;

[$run_user]
listen = /dev/shm/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = $run_user 
listen.group = $run_user 
listen.mode = 0666
user = $run_user 
group = $run_user 

pm = dynamic
pm.max_children = 12
pm.start_servers = 8
pm.min_spare_servers = 6
pm.max_spare_servers = 12
pm.max_requests = 2048
pm.process_idle_timeout = 10s
request_terminate_timeout = 120
request_slowlog_timeout = 0

pm.status_path = /php-fpm_status
slowlog = log/slow.log
rlimit_files = 51200
rlimit_core = 0

catch_workers_output = yes
;env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
EOF

    [ -d "/run/shm" -a ! -e "/dev/shm" ] && sed -i 's@/dev/shm@/run/shm@' $php_install_dir/etc/php-fpm.conf $lnmp_dir/vhost.sh $lnmp_dir/config/nginx.conf 

    if [ $Mem -le 3000 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = $(($Mem/3/20))@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = $(($Mem/3/30))@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($Mem/3/40))@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($Mem/3/20))@" $php_install_dir/etc/php-fpm.conf
    elif [ $Mem -gt 3000 -a $Mem -le 4500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 50@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 30@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 20@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 50@" $php_install_dir/etc/php-fpm.conf
    elif [ $Mem -gt 4500 -a $Mem -le 6500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 60@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 40@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 30@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 60@" $php_install_dir/etc/php-fpm.conf
    elif [ $Mem -gt 6500 -a $Mem -le 8500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 70@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 50@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 40@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 70@" $php_install_dir/etc/php-fpm.conf
    elif [ $Mem -gt 8500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 80@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 60@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 50@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 80@" $php_install_dir/etc/php-fpm.conf
    fi

    #[ "$Web_yn" == 'n' ] && sed -i "s@^listen =.*@listen = $IPADDR:9000@" $php_install_dir/etc/php-fpm.conf 

    cd ..
    [ -e "$php_install_dir/bin/phpize" ] && rm -rf php-$php_version
}


if [ -d "$php_install_dir" ]; then

    echo "$php_install_dir maybe installed"
    
else
    Install_PHP
fi

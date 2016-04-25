#!/bin/bash

nginx_install_dir=$install_dir/nginx/$nginx_version

Install_Nginx() {

    cd $lnmp_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-$pcre_version.tar.gz && Download_src
    src_url=http://nginx.org/download/nginx-$nginx_version.tar.gz && Download_src

    tar xzf pcre-$pcre_version.tar.gz
    cd pcre-$pcre_version
    make clean
    ./configure
    make && make install
    cd ..

    id -u $run_user >/dev/null 2>&1
    [ $? -ne 0 ] && useradd -M -s /sbin/nologin $run_user 

    tar xzf nginx-$nginx_version.tar.gz
    cd nginx-$nginx_version

    # close debug
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc

    if [ "$je_tc_malloc" == '1' ];then
        malloc_module="--with-ld-opt='-ljemalloc'"
    elif [ "$je_tc_malloc" == '2' ];then
        malloc_module='--with-google_perftools_module'
        mkdir /tmp/tcmalloc
        chown -R ${run_user}.$run_user /tmp/tcmalloc
    fi

    [ ! -d "$nginx_install_dir" ] && mkdir -p $nginx_install_dir
    make clean
    ./configure --prefix=$nginx_install_dir --user=$run_user --group=$run_user --with-http_stub_status_module --with-http_v2_module --with-http_ssl_module --with-ipv6 --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module $malloc_module
    make && make install
    if [ -e "$nginx_install_dir/conf/nginx.conf" ];then
        cd ..
        echo "Nginx install success. "
        install_log "$nginx_install_dir install success."
    else
        rm -rf $nginx_install_dir
        echo "Nginx install failed! "
        install_log "$nginx_install_dir install failed!"
        kill -9 $$
    fi

    . /etc/profile

    mv $nginx_install_dir/conf/nginx.conf{,_bk}

    /bin/cp $lnmp_dir/etc/nginx/nginx.conf $nginx_install_dir/conf/nginx.conf

    cat > $nginx_install_dir/conf/proxy.conf << EOF
proxy_connect_timeout 300s;
proxy_send_timeout 900;
proxy_read_timeout 900;
proxy_buffer_size 32k;
proxy_buffers 4 64k;
proxy_busy_buffers_size 128k;
proxy_redirect off;
proxy_hide_header Vary;
proxy_set_header Accept-Encoding '';
proxy_set_header Referer \$http_referer;
proxy_set_header Cookie \$http_cookie;
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
EOF
    sed -i "s@/data/wwwroot/default@$wwwroot_dir/default@" $nginx_install_dir/conf/nginx.conf
    sed -i "s@/data/wwwlogs@$wwwlogs_dir@g" $nginx_install_dir/conf/nginx.conf
    sed -i "s@^user www www@user $run_user $run_user@" $nginx_install_dir/conf/nginx.conf
    [ "$je_tc_malloc" == '2' ] && sed -i 's@^pid\(.*\)@pid\1\ngoogle_perftools_profiles /tmp/tcmalloc;@' $nginx_install_dir/conf/nginx.conf 

    ldconfig

}

if [ -d $nginx_install_dir ]; then
    install_log "$nginx_install_dir is existing, nothing install."
else
    Install_Nginx
fi

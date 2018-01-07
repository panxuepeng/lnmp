#!/bin/bash

nginx_install_dir=$install_dir/nginx/$nginx_version

Install_Nginx() {
    cd $lnmp_src
    
    src_url=http://nginx.org/download/nginx-$nginx_version.tar.gz && Download_src

    tar xzf nginx-$nginx_version.tar.gz
    cd nginx-$nginx_version

    # close debug
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc

    [ ! -d "$nginx_install_dir" ] && mkdir -p $nginx_install_dir
    make clean
    ./configure --prefix=$nginx_install_dir --user=$www_user --group=$www_user --with-http_stub_status_module --with-http_v2_module --with-http_ssl_module --with-ipv6 --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-http_mp4_module
    make && make install
    
    if [ -e "$nginx_install_dir/conf/nginx.conf" ];then
        install_log "success: $nginx_install_dir"

        if [ ! -d /usr/local/nginx ];then
            ln -s $nginx_install_dir  /usr/local/nginx
        fi

        # 设置服务
        set_service "nginx"
    else
        rm -rf $nginx_install_dir
        install_log "failed: $nginx_install_dir"
        kill -9 $$
    fi
}

if [ -f "$nginx_install_dir/sbin/nginx" ]; then
    install_log "$nginx_install_dir is existing, nothing install."
else
    Install_Nginx
fi

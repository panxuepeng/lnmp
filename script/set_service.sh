#!/bin/bash

# 服务启动也需要放到这里

for name in nginx  php-fpm  memcached  redis-server  mysqld
do
    rm -rf /etc/init.d/$name
    
    if [ "$OS" == 'CentOS' ]; then
        /bin/cp $lnmp_dir/init.d/$name-init-CentOS  /etc/init.d/$name
        chkconfig --add $name
        chkconfig $name on
    else
        /bin/cp $lnmp_dir/init.d/$name-init-Ubuntu  /etc/init.d/$name
        update-rc.d $name defaults
    fi
    
    chmod +x /etc/init.d/$name
    
done

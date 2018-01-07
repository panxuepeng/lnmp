#!/bin/bash

# 服务启动放到这里
# todo 判断相关软件是否已安装

for name in nginx  php-fpm70  php-fpm56  memcached  redis-server  mysqld mongod
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




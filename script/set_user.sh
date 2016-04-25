#!/bin/bash

# 添加用户和处理相关目录的权限

useradd -M -s /sbin/nologin redis
chown -R redis:redis $redis_install_dir/var/

chown mysql.mysql -R $mysql_data_dir
[ -d '/etc/mysql' ] && mv /etc/mysql{,_bk}

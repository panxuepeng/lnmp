#!/bin/bash


# 建立目录软链接
nginx_install_dir=$install_dir/nginx/$nginx_version
php_install_dir=$install_dir/php/$php_version
memcached_install_dir=$install_dir/memcached/$memcached_version
redis_install_dir=$install_dir/redis/$redis_version
mysql_install_dir=$install_dir/mysql/$mysql_version
composer_install_dir=$install_dir/composer/$composer_version
node_install_dir=$install_dir/node/$node_version

rm -rf /usr/local/{nginx,php,memcached,redis,mysql,node,composer}

ln -s $nginx_install_dir           /usr/local/nginx
ln -s $php_install_dir             /usr/local/php
ln -s $memcached_install_dir /usr/local/memcached
ln -s $redis_install_dir            /usr/local/redis
ln -s $mysql_install_dir          /usr/local/mysql
ln -s $node_install_dir          /usr/local/node
ln -s $composer_install_dir          /usr/local/composer

# 链接软件软链接
if [ ! -e  '/usr/local/bin/mysql' ]; then
    ln -s /usr/local/mysql/bin/mysql  /usr/local/bin/mysql
    rm -f /etc/my.cnf
    ln -s /usr/local/mysql/my.cnf  /etc/my.cnf
    
fi

if [ ! -e  '/usr/local/sbin/nginx' ]; then
    ln -s /usr/local/nginx/sbin/nginx  /usr/local/sbin/nginx
fi

if [ ! -e  '/usr/local/bin/memcached' ]; then
    ln -s /usr/local/memcached/bin/memcached  /usr/local/bin/memcached
fi

if [ ! -e  '/usr/local/bin/php' ]; then
    ln -s /usr/local/php/bin/*  /usr/local/bin/
fi

if [ ! -e  '/usr/local/bin/redis-server' ]; then
    ln -s /usr/local/redis/bin/* /usr/local/bin/
fi

if [ ! -e  '/usr/local/bin/node' ]; then
    ln -s /usr/local/node/bin/* /usr/local/bin/
fi

if [ ! -e  '/usr/local/bin/composer' ]; then
    ln -s /usr/local/composer/composer  /usr/local/bin/composer
    composer config -g repo.packagist composer  https://packagist.phpcomposer.com
fi



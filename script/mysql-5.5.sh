#!/bin/bash

mysql_version=$mysql_version_55
mysql_install_dir=$install_dir/mysql/$mysql_version

Install_MySQL() {

    cd $lnmp_src
    src_url=http://cdn.mysql.com/Downloads/MySQL-5.5/mysql-$mysql_version.tar.gz && Download_src

    id -u mysql >/dev/null 2>&1
    [ $? -ne 0 ] && useradd -M -s /sbin/nologin mysql

    mkdir -p $mysql_data_dir;chown mysql.mysql -R $mysql_data_dir
    tar zxf mysql-$mysql_version.tar.gz
    cd mysql-$mysql_version
    
    if [ "$je_tc_malloc" == '1' ];then
        EXE_LINKER="-DCMAKE_EXE_LINKER_FLAGS='-ljemalloc'"
    elif [ "$je_tc_malloc" == '2' ];then
        EXE_LINKER="-DCMAKE_EXE_LINKER_FLAGS='-ltcmalloc'"
    fi
    
    make clean
    [ ! -d "$mysql_install_dir" ] && mkdir -p $mysql_install_dir
    cmake . -DCMAKE_INSTALL_PREFIX=$mysql_install_dir \
    -DMYSQL_DATADIR=$mysql_data_dir \
    -DSYSCONFDIR=/etc \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_PARTITION_STORAGE_ENGINE=1 \
    -DWITH_FEDERATED_STORAGE_ENGINE=1 \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DWITH_MYISAM_STORAGE_ENGINE=1 \
    -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
    -DWITH_READLINE=1 \
    -DENABLED_LOCAL_INFILE=1 \
    -DENABLE_DTRACE=0 \
    -DDEFAULT_CHARSET=utf8mb4 \
    -DDEFAULT_COLLATION=utf8mb4_general_ci \
    -DWITH_EMBEDDED_SERVER=1 \
    $EXE_LINKER
    make -j `grep processor /proc/cpuinfo | wc -l` 
    make install

    if [ -d "$mysql_install_dir/support-files" ];then
        echo "MySQL install success. "
        install_log "success: $mysql_install_dir install"
        
        
        $mysql_install_dir/scripts/mysql_install_db --user=mysql --basedir=$mysql_install_dir --datadir=$mysql_data_dir
        /bin/cp -f $lnmp_dir/etc/mysql-$mysql_version/my.conf  $mysql_install_dir/my.cnf
        #rm -rf /etc/ld.so.conf.d/{mysql,mariadb,percona}*.conf
        #echo "$mysql_install_dir/lib" > /etc/ld.so.conf.d/mysql.conf 

    else
        echo "MySQL install failed. "
        install_log "failed: $mysql_install_dir install"
    fi
}

if [ -d "$mysql_install_dir" ]; then
    install_log "$mysql_install_dir is existing, nothing install."
else
    Install_MySQL
fi

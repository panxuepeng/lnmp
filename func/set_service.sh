#!/bin/bash

set_service() {
    name=$1
    
    if [ -f /etc/init.d/$name ]; then
        mv /etc/init.d/$name "/etc/init.d/${name}_bk"
        install_log "mv /etc/init.d/$name /etc/init.d/${name}_bk"
    fi

    if [ "$OS" == 'CentOS' ]; then
        /bin/cp $lnmp_dir/init.d/$name-init-CentOS  /etc/init.d/$name
        chkconfig --add $name
        chkconfig $name on
    else
        /bin/cp $lnmp_dir/init.d/$name-init-Ubuntu  /etc/init.d/$name
        update-rc.d $name defaults
    fi
    
    chmod +x /etc/init.d/$name

    #service $name start

    install_log "set_service: $name"
}
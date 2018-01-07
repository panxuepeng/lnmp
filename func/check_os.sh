#!/bin/bash

if [ -n "`grep 'Aliyun Linux release' /etc/issue`" -o -e /etc/redhat-release ];then
    OS=CentOS
    [ -n "`grep ' 7\.' /etc/redhat-release`" ] && CentOS_RHEL_version=7
    [ -n "`grep ' 6\.' /etc/redhat-release`" -o -n "`grep 'Aliyun Linux release6 15' /etc/issue`" ] && CentOS_RHEL_version=6
    [ -n "`grep ' 5\.' /etc/redhat-release`" -o -n "`grep 'Aliyun Linux release5' /etc/issue`" ] && CentOS_RHEL_version=5
elif [ -n "`grep bian /etc/issue`" -o "`lsb_release -is 2>/dev/null`" == 'Debian' ];then
    OS=Debian
    [ ! -e "`which lsb_release`" ] && { apt-get -y update; apt-get -y install lsb-release; } 
    Debian_version=`lsb_release -sr | awk -F. '{print $1}'`
elif [ -n "`grep Ubuntu /etc/issue`" -o "`lsb_release -is 2>/dev/null`" == 'Ubuntu' ];then
    OS=Ubuntu
    [ ! -e "`which lsb_release`" ] && { apt-get -y update; apt-get -y install lsb-release; } 
    Ubuntu_version=`lsb_release -sr | awk -F. '{print $1}'`
else
    echo "Does not support this OS."
    kill -9 $$
fi


if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ]; then
    OS_bit=64
else
    OS_bit=32
fi

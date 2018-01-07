#!/bin/bash

install_log_start() {
    starttime=`date +%s`
    echo -e "\n\nstart $1" >> $installLog
    echo -e "\n\nstart $1"
}

install_log() {
    echo -e "    $1" >> $installLog
    echo -e "\n\nstart $1"
}

install_log_end() {
    timestamp=`date +%s`
    seconds=$[$timestamp - $starttime]
    minute=$[$seconds/60]
    second=$[$seconds%60]

    printf "%02d:%02d %s" $minute $second >> $installLog
    printf "%02d:%02d %s" $minute $second
}

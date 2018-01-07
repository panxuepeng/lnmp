#!/bin/bash

Download_src() {
    [ -s "${src_url##*/}" ] && echo "[${src_url##*/}] found" || wget -c --no-check-certificate $src_url
    if [ ! -e "${src_url##*/}" ];then
        echo "${src_url##*/} download failed. "
        kill -9 $$
    fi
}

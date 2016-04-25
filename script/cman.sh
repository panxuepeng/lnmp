#!/bin/bash

./configure --disable-zhtw
make && make install

echo "alias cman='man -M /usr/local/share/man/zh_CN'" >> /etc/profile.d/cman.sh

source /etc/profile.d/cman.sh
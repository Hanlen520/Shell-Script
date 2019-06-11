#!/usr/bin/env bash
# Author: Shengjie.Liu
# Date: 2019-06-11
# Version: 1.0
# Description: 批量卸载应用
# How to use: sh +x uninstall_all.sh

#读取文件
read -p "Please input the path that file exists:" FILE_PATH
#遍历文件每一行，运行卸载命令
cat ${FILE_PATH} | while read line
do
    adb uninstall ${line}
done

#!/usr/bin/env bash
# Author: Shengjie.Liu
# Date: 2019-06-10
# Version: 1.0
# Description: 批量安装应用
# How to use: sh +x install.sh

#输入目录
read -p "Please input the directory that has apk files：" directory
#列出应用&安装应用
ls ${directory} | while read line
do
    adb install ${directory}/${line}
done

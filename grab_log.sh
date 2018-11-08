#!/bin/bash
# https://developer.android.com/studio/command-line/logcat?hl=zh-cn

DATE=$(date "+%Y%m%d%H%M%S")
# 读取包名
echo -n "Please enter the package name:"
read tag
# 读取log文件名
echo -n "Please enter the app name:"
read app_name
# 日志级别：V/D/I/W/E/F/S
echo -n "Please enter the priority of log:"
read priority
# log命令
adb logcat -d -v time "${tag}:${priority}" > ~/Desktop/logg/${app_name}${DATE}.log
# anr日志
adb pull /data/anr/traces.txt ~/Desktop/logg
# 清空日志
adb logcat -c

#!/bin/bash
#
# Author: Shengjie.Liu
# Date: 2018-10-25
# Version: 2.1
# Description: 基于mu.li的1.0版本
# 首次安装间隔时间由5s调为10s

# 获取包名和活动名
component=$1
package=$(echo $1 | cut -d"/" -f1) 
echo "Package name is '$package'"

# 清除app进程及数据
adb shell am force-stop $package
adb shell pm clear $package
# 首次安装
starttime1=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)
sleep 10s
adb shell am force-stop $package
adb shell pm clear $package

starttime2=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)
sleep 10s
adb shell am force-stop $package
adb shell pm clear $package

starttime3=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)
sleep 10s
echo "首次安装时间：$starttime1 $starttime2 $starttime3"
echo "($starttime1+$starttime2+$starttime3)/3" | bc

# 首次安装测试完毕，按back键退出
adb shell input keyevent 4
adb shell input keyevent 4
adb shell input keyevent 4
sleep 2s

# 热启动
starttime1=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)
sleep 5s
adb shell input keyevent 4
adb shell input keyevent 4
adb shell input keyevent 4
sleep 2s

starttime2=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)
sleep 5s
adb shell input keyevent 4
adb shell input keyevent 4
adb shell input keyevent 4
sleep 2s

starttime3=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)
sleep 5s
adb shell input keyevent 4
adb shell input keyevent 4
adb shell input keyevent 4
sleep 2s

echo "热启动时间： $starttime1 $starttime2 $starttime3"
echo "($starttime1+$starttime2+$starttime3)/3" | bc

# 冷启动
sleep 3s
adb reboot
sleep 60s
adb shell input keyevent 3
sleep 2s
starttime1=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)

sleep 3s
adb reboot
sleep 60s
adb shell input keyevent 3
sleep 2s
starttime2=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)

sleep 3s
adb reboot
sleep 60s
adb shell input keyevent 3
sleep 2s
starttime3=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)

sleep 3s
echo "冷启动时间： $starttime1 $starttime2 $starttime3"
echo "($starttime1+$starttime2+$starttime3)/3" | bc

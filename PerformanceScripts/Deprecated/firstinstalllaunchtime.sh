#!/bin/bash

# 获取包名和活动名
component=$1
package=$(echo $1 | cut -d"/" -f1) 
echo "Package name is '$package'"

adb shell am force-stop $package
adb shell pm clear $package

starttime1=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)
echo $starttime1
sleep 10s
adb shell am force-stop $package
adb shell pm clear $package

starttime2=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)
echo $starttime2
sleep 10s
adb shell am force-stop $package
adb shell pm clear $package

starttime3=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)
echo $starttime3
sleep 10s
echo "首次安装时间：$starttime1 $starttime2 $starttime3"
echo "($starttime1+$starttime2+$starttime3)/3" | bc

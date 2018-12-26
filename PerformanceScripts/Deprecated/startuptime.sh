#!/bin/bash
#
# Author: ScottLee
# Date:2018-07-06
# Version: 1.0
# Description:
# Deprecated 12/26 2018

component=$1
package=$(echo $1 | cut -d"/" -f1) 
echo "Package name is '$package'"

adb shell am force-stop $package
adb shell pm clear $package
starttime1=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | cut -d":" -f 2)
sleep 5s
adb shell am force-stop $package
adb shell pm clear $package

starttime2=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | cut -d":" -f 2)
sleep 5s
adb shell am force-stop $package
adb shell pm clear $package

starttime3=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | cut -d":" -f 2)
sleep 5s
echo "首次启动时间 $starttime1 $starttime2 $starttime3"
echo "($starttime1+$starttime2+$starttime3)/3" | bc



adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | cut -d":" -f 2
sleep 5s
adb shell input keyevent 4
adb shell input keyevent 4
adb shell input keyevent 4
sleep 2s


starttime1=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | cut -d":" -f 2)
sleep 5s
adb shell input keyevent 4
adb shell input keyevent 4
adb shell input keyevent 4
sleep 2s

starttime2=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | cut -d":" -f 2)
sleep 5s
adb shell input keyevent 4
adb shell input keyevent 4
adb shell input keyevent 4
sleep 2s

starttime3=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | cut -d":" -f 2)
sleep 5s
adb shell input keyevent 4
adb shell input keyevent 4
adb shell input keyevent 4
sleep 2s

echo "热启动时间： $starttime1 $starttime2 $starttime3"
echo "($starttime1+$starttime2+$starttime3)/3" | bc

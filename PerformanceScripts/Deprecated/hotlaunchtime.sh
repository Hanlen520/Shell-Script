#!/bin/bash

function quitApp() {
  adb shell input keyevent 4
  adb shell input keyevent 4
  adb shell input keyevent 4
  sleep 2s
}

# 获取包名和活动名
component=$1
package=$(echo $1 | cut -d"/" -f1)
echo "Package name is '$package'"

starttime1=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)
echo $starttime1
quitApp

starttime2=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)
echo $starttime2
quitApp

starttime3=$(adb shell am start -W  $component | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2)
echo $starttime3
quitApp

echo "热启动时间：$starttime1 $starttime2 $starttime3"
echo "($starttime1+$starttime2+$starttime3)/3" | bc

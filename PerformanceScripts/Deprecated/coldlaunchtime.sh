#!/usr/bin/env bash
# Author: Shengjie.Liu
# Date: 2019-03-26
# Version: 1.0
# Description:  冷启动

# parameter: package_name
function uninstall() {
  adb uninstall ${1}
  sleep 2s
}

# parameter: component
function getStartupTime() {
  adb shell am start -W  ${1} | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2
  sleep 2s
}

# parameter: package_name
function clearApp() {
  adb shell am force-stop ${1}
#  adb shell pm clear ${1}
  sleep 10s
}

read -p "请输入包名：" package_name
read -p "请输入包名和活动名：" component

# cold boot
clearApp ${package_name}
starttime1=`getStartupTime ${component}`

clearApp ${package_name}
starttime2=`getStartupTime ${component}`

clearApp ${package_name}
starttime3=`getStartupTime ${component}`

echo "冷启动时间（ms）：$starttime1 $starttime2 $starttime3"
echo "($starttime1+$starttime2+$starttime3)/3" | bc

# back to zero
# uninstall ${package_name}

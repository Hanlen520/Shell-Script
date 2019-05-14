#!/bin/bash

echo "已连接设备："
adb devices
echo "设备型号："
adb shell getprop ro.product.model
echo "品牌："
adb shell getprop ro.product.brand
echo "系统版本："
adb shell getprop ro.build.version.release

release=$(adb shell getprop ro.build.version.release | sed 's/ //g' | tr -d $'\r')
release_one=$(echo ${release} | awk -F. '{print $1}')

# screen resolution/density
if [[ ${release_one} > 4 ]]; then
    density=$(adb shell wm density | tr -d $'\r' | awk '{print $3}')
    size=$(adb shell wm size | tr -d $'\r' | awk '{print $3}')
    display="${size}/${density}dpi"
else
    size=`adb shell dumpsys window displays | grep "init" | tr -d $'\r' | awk '{print $1}' | cut -d"=" -f 2`
    density=`adb shell dumpsys window displays | grep "init" | tr -d $'\r' | awk '{print $2}'`
    display="${size}/${density}"
fi

echo $display

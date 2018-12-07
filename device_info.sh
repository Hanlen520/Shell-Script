#!/bin/bash

echo "已连接设备："
adb devices
sleep 2
echo "设备型号："
adb shell getprop ro.product.model
sleep 2
echo "品牌："
adb shell getprop ro.product.brand
sleep 2
echo "系统版本："
adb shell getprop ro.build.version.release

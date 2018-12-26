#!/bin/bash

echo "已连接设备："
adb devices
echo "设备型号："
adb shell getprop ro.product.model
echo "品牌："
adb shell getprop ro.product.brand
echo "系统版本："
adb shell getprop ro.build.version.release


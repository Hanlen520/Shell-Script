#!/bin/bash

echo "系统版本："
adb shell getprop ro.build.version.release
sleep 2
echo "应用程序包名和活动名："
adb shell dumpsys window | grep mCurrentFocus
sleep 2
echo "设备名："
adb devices
echo "记得启动Appium哦！"

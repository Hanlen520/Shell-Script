#!/bin/bash
# 清理应用数据与缓存

echo "Please input the Package Name:"
read packagename
adb shell pm clear $packagename

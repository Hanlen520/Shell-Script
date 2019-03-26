#!/usr/bin/env bash
# Author: Shengjie.Liu
# Date: 2019-03-26
# Version: 1.0
# Description: DumpHierarchy 的辅助脚本
# 1.截图
# 2.将截图和.uix文件导入电脑
# 适配sony8.0

DATE=$(date "+%Y%m%d%H%M%S")

# 截图
adb shell screencap -p /sdcard/Pictures/Screenshots/${DATE}.png
sleep 10s

# 导出截图到电脑
adb pull /sdcard/Pictures/Screenshots/${DATE}.png ~/Downloads/DumpHierarchy/

# 导出.uix文件到当前文件夹
adb shell 'ls /sdcard/DumpHierarchy/*.uix' | tr -d '\r' | xargs -n1 adb pull

# move *.uix to ~/Downloads/DumpHierarchy/
mv *.uix ~/Downloads/DumpHierarchy/





#!/bin/bash
# Killing the monkey's process

pid=$(adb shell ps | grep monkey | awk '{print $2}')
adb shell kill ${pid}
echo "killed"

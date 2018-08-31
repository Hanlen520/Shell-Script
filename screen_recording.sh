#!/bin/bash

echo "Please input the video name:"
read videoname
adb shell screenrecord --time-limit 30 /sdcard/$videoname.mp4
adb pull /sdcard/$videoname.mp4 /Users/a140/Desktop/video

#!/bin/bash
echo "Please input the vieo time:"
read videotime
echo "Please input the video name:"
read videoname
adb shell screenrecord --time-limit ${videotime} /sdcard/${videoname}.mp4
adb pull /sdcard/${videoname}.mp4 ~/Downloads/

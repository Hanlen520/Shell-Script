#!/bin/bash
echo "Please input the vieo time:"
read videotime
echo "Please input the video name:"
read videoname
adb shell screenrecord --time-limit ${videotime} /sdcard/${videoname}.mp4
adb pull /sdcard/${videoname}.mp4 ~/Downloads/


#adb exec-out screencap -p > sc.png
#adb shell screencap -p /sdcard/sc.png
#adb pull /sdcard/sc.png
#adb shell screencap -p | gsed "s/\r$//" > sc.png
#brew install gnu-sed

#!/bin/bash

DATE=$(date +%Y%m%d)
echo -n "Please enter the package name:"
read package_name
echo -n "Please enter the app name:"
read app_name
echo -n "Please enter the priority of log:"
read priority
adb logcat -d -v time "$package_name:$priority" > /Users/shengjie.liu/Desktop/logg/$app_name$DATE.log
adb logcat -c
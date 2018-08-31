#!/bin/bash
# 获取app的启动活动名

echo "apk path:"
read apk_path
apkInformation=$(aapt dump badging $apk_path | grep launchable-activity)
if [ ! -n "$apkInformation" ]; then
	echo "Sorry, here is not have information about launchable-activity."
	# apkInformation=$(aapt dump badging $apk_path)
	# echo $apkInformation
else
    echo $apkInformation
fi
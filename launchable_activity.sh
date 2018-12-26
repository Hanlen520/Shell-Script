#!/bin/bash
# 获取app的启动活动名

echo "apk path:"
read apk_path
launch_activity=$(aapt dump badging $apk_path | grep launchable-activity | sed 's/ //g' | tr -d $'\r' | cut -d"'" -f2) 
packagename=$(aapt dump badging $apk_path | grep package: | sed 's/ //g' | tr -d $'\r' | cut -d"'" -f2)
if [ ! -n "$launch_activity" ]; then
	echo "Sorry, here is not have information about launchable-activity."
else
    echo $launch_activity
    echo $packagename
    echo "${packagename}/${launch_activity}"
fi

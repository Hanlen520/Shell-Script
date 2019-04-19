#!/bin/bash
# Author: Shengjie.Liu
# Date: 2019-04-19
# Version: 1.0
# Description: 批量卸载安卓应用
# How to use: sh +x uninstall.sh

WORkSPACE=`pwd`

adb shell pm list packages -3 > ${WORkSPACE}/apps_for_uninstall/list.txt

sleep 3s

# 遍历手机里的第三方app的包名
for line in $(cat ${WORkSPACE}/apps_for_uninstall/list.txt); do
	# 将packagename截取出来
	name=${line:8}
	# 遍历要卸载的包名
	for line2 in $(cat ${WORkSPACE}/apps_for_uninstall/all_list.txt); do
		# 判断是否包含
		if [[ ${name} =~ $line2 ]]; then
		# 删除包名结尾的\r
		package_name=$(echo ${name} | tr '\r' ' ')
		# 执行adb卸载命令
		adb uninstall ${package_name}
		# 打印已卸载的包名
		echo ${package_name}"已卸载"
		fi	
	done
done

#!/bin/bash

adb shell pm list packages -3 > ~/Shell-Script/apps_for_uninstall/list.txt

sleep 3s

# 遍历手机里的第三方app的包名
for line in $(cat ~/Shell-Script/apps_for_uninstall/list.txt); do
	# 将packagename截取出来
	name=${line:8}
	# 遍历要卸载的包名
	for line2 in $(cat ~/Shell-Script/apps_for_uninstall/all_list.txt); do
		# 判断是否包含
		if [[ $name =~ $line2 ]]; then
		# 删除包名结尾的\r
		package_name=$(echo $name | tr '\r' ' ')
		# 执行adb卸载命令
		adb uninstall $package_name
		# 打印已卸载的包名
		echo $package_name"已卸载"
		fi	
	done
done

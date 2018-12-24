#!/bin/bash
# Author: Shengjie.Liu
# Date: 2018-10-30
# Version: 2.1
# Description: 启动流量脚本
# 此脚本运行前，应用安装后未启动过
# 添加启动时间自定义
# 添加测试次数自定义，默认3次
# How to use: sh +x startupcellmdataV4.sh <packagename>/<activityname> <sleeptime> <times> 

# 获取命令行输入参数
component=$1
# 包名
packagename=$(echo $1 | cut -d"/" -f1)
echo "Package name is '$packagename'"
# 活动名
activityname=$(echo $1 | cut -d"/" -f2)
echo "Activity name is '$activityname'"
# 待启动页活动名
startactivity=${packagename}"/"${activityname}
echo "Start activity is '$startactivity'"
# UID
userid=$(adb shell dumpsys package $packagename | grep userId= | sed 's/ //g' | tr -d $'\r' | cut -c 8-12)
echo "uid = $userid"

# 启动后等待时间
sleeptime=$2
if [ ! -n "$sleeptime" ] ;then
    sleeptime=10s
    echo "Sleep time is '10s'"
else
    echo "Sleep time is '$sleeptime'"
fi

# 默认测试次数为3，可在命令行输入参数自定义
times=$3
if [ ! -n "$times" ] ;then
    times=3
    echo "启动消耗流量测试次数：3 次"
else
    echo "启动消耗流量测试次数：$times 次"
fi

# 创建临时文件夹
init_data(){
	if [[ ! -d $OUTPUT ]]; then
	mkdir -p $OUTPUT
	fi
}

WORKSPACE=`pwd`
OUTPUT=${WORKSPACE}/tmp_folder

init_data

# 第一次启动
firstlaunchtime(){
	# 启动应用
	adb shell am start -n $1
	# 等待n秒（自定义的启动时间），应用启动后可能会在后台异步加载一些数据资源
	sleep $2
	# 获取启动后的应用流量数值
	startrcv1=$(adb shell cat /proc/uid_stat/$3/tcp_rcv | sed 's/ //g' | tr -d $'\r')
	startsnd1=$(adb shell cat /proc/uid_stat/$3/tcp_snd | sed 's/ //g' | tr -d $'\r')
	echo $startrcv1
	echo $startsnd1
	# 本次启动耗费的总流量
	data1=`echo "($startrcv1+$startsnd1)" | bc`
	echo "启动消耗流量测试1：$data1"
}

# 测试次数>1，调用此方法
launchtime(){
	int=2
	while(( $int<=$1 ))
	do
 		adb shell am force-stop $2
 		adb shell pm clear $2
 		br=$(adb shell cat /proc/uid_stat/${3}/tcp_rcv | sed 's/ //g' | tr -d $'\r')
 		bs=$(adb shell cat /proc/uid_stat/${3}/tcp_snd | sed 's/ //g' | tr -d $'\r')
 		adb shell am start -n $4
 		sleep $5
 		ac=$(adb shell cat /proc/uid_stat/$3/tcp_rcv | sed 's/ //g' | tr -d $'\r')
 		as=$(adb shell cat /proc/uid_stat/$3/tcp_snd | sed 's/ //g' | tr -d $'\r')
 		echo $ac
 		echo $as
 		data=`echo "($ac+$as)-($br+$bs)" | bc`
 		echo "启动消耗流量测试${int}：$data"
 		echo $data >> $6/tmp_file.txt
 		let "int++"
	done
}

if [[ $times == 1 ]]; then
	firstlaunchtime $startactivity $sleeptime $userid 
else
	firstlaunchtime $startactivity $sleeptime $userid
	launchtime $times $packagename $userid $startactivity $sleeptime $OUTPUT
	echo "------------------------------------"
	datasum=$(cat $OUTPUT/tmp_file.txt | awk '{sum+=$1} END {print sum}')
	dataall=`echo "$datasum+$data1" | bc`
	average=`echo "$dataall/$times" | bc`
	# 删除临时文件夹
	rm -r $OUTPUT
	echo "应用启动时流量消耗（取${times}次测试平均值）：$average bytes"
fi

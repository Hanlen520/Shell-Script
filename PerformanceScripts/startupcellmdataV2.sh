#!/bin/bash
# Author: Shengjie.Liu
# Date: 2018-10-09
# Version: 1.0
# Description: 启动流量脚本
# 此脚本运行前，应用安装后未启动过

# 获取包名和UID
component=$1
packagename=$(echo $1 | cut -d"/" -f1) 
echo "Package name is '$packagename'"
userid=$(adb shell dumpsys package $packagename | grep userId= | sed 's/ //g' | tr -d $'\r' | cut -c 8-12)
echo "uid = $userid"

# 第一次
# 启动应用
adb shell am start -n $component
# 等待10s，应用启动后可能会在后台异步加载一些数据资源
sleep 10s

# 获取启动后的应用流量数值
startrcv1=$(adb shell cat /proc/uid_stat/$userid/tcp_rcv | sed 's/ //g' | tr -d $'\r')
startsnd1=$(adb shell cat /proc/uid_stat/$userid/tcp_snd | sed 's/ //g' | tr -d $'\r')
echo $startrcv1
echo $startsnd1

# 本次启动耗费的总流量
data1=`echo "($startrcv1+$startsnd1)" | bc`
echo "启动消耗流量测试一：$data1"

# 第二次
adb shell am force-stop $packagename
adb shell pm clear $packagename
beforestartrcv2=$(adb shell cat /proc/uid_stat/$userid/tcp_rcv | sed 's/ //g' | tr -d $'\r')
beforestartsnd2=$(adb shell cat /proc/uid_stat/$userid/tcp_snd | sed 's/ //g' | tr -d $'\r')
echo $beforestartrcv2
echo $beforestartsnd2

adb shell am start -n $component
sleep 10s

afterstartrcv2=$(adb shell cat /proc/uid_stat/$userid/tcp_rcv | sed 's/ //g' | tr -d $'\r')
afterstartsnd2=$(adb shell cat /proc/uid_stat/$userid/tcp_snd | sed 's/ //g' | tr -d $'\r')
echo $afterstartrcv2
echo $afterstartsnd2

data2=`echo "($afterstartrcv2+$afterstartsnd2)-($beforestartrcv2+$beforestartsnd2)" | bc`
echo "启动消耗流量测试二：$data2"

# 第三次
adb shell am force-stop $packagename
adb shell pm clear $packagename
beforestartrcv3=$(adb shell cat /proc/uid_stat/$userid/tcp_rcv | sed 's/ //g' | tr -d $'\r')
beforestartsnd3=$(adb shell cat /proc/uid_stat/$userid/tcp_snd | sed 's/ //g' | tr -d $'\r')
echo $beforestartrcv3
echo $beforestartsnd3

adb shell am start -n $component
sleep 10s

afterstartrcv3=$(adb shell cat /proc/uid_stat/$userid/tcp_rcv | sed 's/ //g' | tr -d $'\r')
afterstartsnd3=$(adb shell cat /proc/uid_stat/$userid/tcp_snd | sed 's/ //g' | tr -d $'\r')
echo $afterstartrcv3
echo $afterstartsnd3

data3=`echo "($afterstartrcv3+$afterstartsnd3)-($beforestartrcv3+$beforestartsnd3)" | bc`
echo "启动消耗流量测试三：$data3"

echo "------------------------------------"

# 计算三次测试结果的平均值
averagedata=`echo "($data1+$data2+$data3)/3" | bc`
echo "应用启动时流量消耗（取三次测试平均值）：$averagedata bytes"


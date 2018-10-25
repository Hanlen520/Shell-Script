#!/bin/bash
# Author: Shengjie.Liu
# Date: 2018-10-25
# Version: 1.0
# Description: monkey脚本
# How to use: sh +x easy_monkey.sh <packagename> <extime>

packagename=$1
echo "应用包名：$packagename"
extime=$2
echo "执行次数：$extime"

mkdir output_monkey
WORKSPACE=`pwd`
OUTPUT=${WORKSPACE}/output_monkey

adb shell monkey -p ${packagename} --ignore-crashes --ignore-timeouts --ignore-security-exceptions \
-v ${extime} 1>$OUTPUT/monkey_log.txt 2>$OUTPUT/error.txt

showerror(){
	cat $OUTPUT/error.txt | grep "CRASH"
	cat $OUTPUT/error.txt | grep "ANR"
}

crashtime=$(cat $OUTPUT/error.txt | grep "CRASH" -c)
anrtime=$(cat $OUTPUT/error.txt | grep "ANR" -c)

date
echo
echo "分析结果："
echo "------------------------------------"
echo "关键字 CRASH 共有 ${crashtime} 处"
echo "关键字 ANR 共有 ${anrtime} 处"
echo
echo "崩溃日志："
showerror
echo "详细日志请查看 $OUTPUT/error.txt"

#!/bin/bash
# Author: Shengjie.Liu
# Date: 2018-10-31
# Version: 1.1
# Description: script of monkey
# How to use: sh +x easy_monkey.sh <packagename> <extime>

packagename=$1
echo "应用包名：$packagename"

extime=$2
case $extime in
    1)  extime=54000
    ;;
    2)  extime=108000
    ;;
    8)  extime=432000
    ;;
    *)  echo "执行次数：$extime"
    ;;
esac

init_data(){
	if [[ ! -d $OUTPUT ]]; then
	mkdir -p $OUTPUT
	fi
}

WORKSPACE=`pwd`
OUTPUT=${WORKSPACE}/output_monkey

init_data
echo "开始时间：`date`"
# adb shell monkey -p ${packagename} --ignore-crashes --ignore-timeouts --ignore-security-exceptions \
# -s 1024 --throttle 200 -v ${extime} 1>$OUTPUT/monkey_log.txt 2>$OUTPUT/error.txt

adb shell monkey -p ${packagename} --pct-touch 40 --pct-motion 25 --pct-appswitch 10 --pct-rotation 5 \
--ignore-crashes --ignore-timeouts --ignore-security-exceptions \
-s 1024 --throttle 200 -v ${extime} 1>$OUTPUT/monkey_log.txt 2>$OUTPUT/error.txt

showerror(){
	cat $OUTPUT/error.txt | grep "CRASH"
	cat $OUTPUT/error.txt | grep "ANR"
}

crashtime=$(cat $OUTPUT/error.txt | grep "CRASH" -c)
anrtime=$(cat $OUTPUT/error.txt | grep "ANR" -c)

echo "结束时间：`date`"
echo
echo "分析结果："
echo "------------------------------------"
echo "关键字 CRASH 共有 ${crashtime} 处"
echo "关键字 ANR 共有 ${anrtime} 处"
echo
echo "崩溃日志："
if [[ $crashtime == 0 && $anrtime == 0 ]]
then
echo "无"
else
showerror
fi
echo "详细错误日志请查看 $OUTPUT/error.txt"
echo "详细执行日志请查看 $OUTPUT/monkey_log.txt"
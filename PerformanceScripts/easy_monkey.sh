#!/bin/bash
# Author: Shengjie.Liu
# Date: 2018-11-09
# Version: 1.2
# Description: script of monkey
# How to use: sh +x easy_monkey.sh <packagename> <extime>
# Changelog: add logcat; code optimization

packagename=${1}
echo "应用包名：${packagename}"

extime=${2}
case ${extime} in
    1)  extime=54000
    ;;
    2)  extime=108000
    ;;
    8)  extime=432000
    ;;
    *)  echo "执行次数：${extime}"
    ;;
esac

init_data(){
	if [[ ! -d ${OUTPUT} ]]; then
        mkdir -p ${OUTPUT}
	fi
    if [[ ! -d ${CURRENT_OUTPUT} ]]; then
        mkdir -p ${CURRENT_OUTPUT}
    fi
}

WORKSPACE=`pwd`
OUTPUT=${WORKSPACE}/output_monkey
CURRENT_TIME=`date +%Y%m%d%H%M`
CURRENT_OUTPUT=${OUTPUT}/${CURRENT_OUTPUT}

init_data
# clear log
adb logcat -c

echo "开始时间：`date "+%Y-%m-%d %H:%M:%S"`"

# adb shell monkey -p ${packagename} --ignore-crashes --ignore-timeouts --ignore-security-exceptions \
# -s 1024 --throttle 200 -v ${extime} 1>${CURRENT_OUTPUT}/monkey_log.txt 2>${CURRENT_OUTPUT}/error.txt

adb shell monkey -p ${packagename} --pct-touch 40 --pct-motion 25 --pct-appswitch 10 --pct-rotation 5 \
--ignore-crashes --ignore-timeouts --ignore-security-exceptions \
-s 1024 --throttle 200 -v ${extime} 1>${CURRENT_OUTPUT}/monkey_log.txt 2>${CURRENT_OUTPUT}/error.txt

showerror(){
	cat ${CURRENT_OUTPUT}/error.txt | grep "CRASH"
	cat ${CURRENT_OUTPUT}/error.txt | grep "ANR"
}

crashtime=$(cat ${CURRENT_OUTPUT}/error.txt | grep "CRASH" -c)
anrtime=$(cat ${CURRENT_OUTPUT}/error.txt | grep "ANR" -c)

echo "结束时间：`date "+%Y-%m-%d %H:%M:%S"`"

# log命令
adb logcat -d -v time "${packagename}:V" > ${CURRENT_OUTPUT}/log.txt

echo
echo "分析结果："
echo "------------------------------------"
echo "关键字 CRASH 共有 ${crashtime} 处"
echo "关键字 ANR 共有 ${anrtime} 处"
echo
echo "崩溃日志："
if [[ ${crashtime} == 0 && ${anrtime} == 0 ]]
then
echo "无"
else
showerror
fi
echo "详细错误日志请查看 ${CURRENT_OUTPUT}/error.txt"
echo "详细执行日志请查看 ${CURRENT_OUTPUT}/monkey_log.txt"
echo "log日志请查看 ${CURRENT_OUTPUT}/log.txt"
if [[ ${anrtime} != 0 ]]
then
# anr日志
adb pull /data/anr/traces.txt ${CURRENT_OUTPUT}
echo "anr日志请查看 ${CURRENT_OUTPUT}/traces.txt"
fi

#!/bin/bash
# Author: Shengjie.Liu
# Date: 2018-11-13
# Version: 1.3
# Description: script of monkey
# How to use: sh +x easy_monkey.sh <packagename> <extime>
# Changelog: add report

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
CURRENT_OUTPUT=${OUTPUT}/${CURRENT_TIME}

init_data
# clear log
adb logcat -c

packagename=${1}
echo "应用包名：${packagename}" | tee -a ${CURRENT_OUTPUT}/result.txt

extime=${2}
case ${extime} in
    1)  extime=54000
    ;;
    2)  extime=108000
    ;;
    8)  extime=432000
    ;;
    *)  echo "执行次数：${extime}" | tee -a ${CURRENT_OUTPUT}/result.txt
    ;;
esac

echo "开始时间：`date "+%Y-%m-%d %H:%M:%S"`" | tee -a ${CURRENT_OUTPUT}/result.txt

# adb shell monkey -p ${packagename} --ignore-crashes --ignore-timeouts --ignore-security-exceptions \
# -s 1024 --throttle 200 -v ${extime} 1>${CURRENT_OUTPUT}/monkey_log.txt 2>${CURRENT_OUTPUT}/error.txt

adb shell monkey -p ${packagename} --pct-touch 40 --pct-motion 25 --pct-appswitch 10 --pct-rotation 5 \
--ignore-crashes --ignore-timeouts --ignore-security-exceptions \
-s 1024 --throttle 200 -v ${extime} 1>${CURRENT_OUTPUT}/monkey_log.txt 2>${CURRENT_OUTPUT}/error.txt

showerror(){
    cat ${CURRENT_OUTPUT}/error.txt | grep "CRASH" | tee -a ${CURRENT_OUTPUT}/result.txt
    cat ${CURRENT_OUTPUT}/error.txt | grep "ANR" | tee -a ${CURRENT_OUTPUT}/result.txt
}

crashtime=$(cat ${CURRENT_OUTPUT}/error.txt | grep "CRASH" -c)
anrtime=$(cat ${CURRENT_OUTPUT}/error.txt | grep "ANR" -c)

echo "结束时间：`date "+%Y-%m-%d %H:%M:%S"`" | tee -a ${CURRENT_OUTPUT}/result.txt

# log命令
adb logcat -d -v time "${packagename}:V" > ${CURRENT_OUTPUT}/log.txt

echo | tee -a ${CURRENT_OUTPUT}/result.txt
echo "分析结果：" | tee -a ${CURRENT_OUTPUT}/result.txt
echo "------------------------------------" | tee -a ${CURRENT_OUTPUT}/result.txt
echo "关键字 CRASH 共有 ${crashtime} 处" | tee -a ${CURRENT_OUTPUT}/result.txt
echo "关键字 ANR 共有 ${anrtime} 处" | tee -a ${CURRENT_OUTPUT}/result.txt
echo | tee -a ${CURRENT_OUTPUT}/result.txt
echo "崩溃日志：" | tee -a ${CURRENT_OUTPUT}/result.txt
if [[ ${crashtime} == 0 && ${anrtime} == 0 ]]
then
echo "无" | tee -a ${CURRENT_OUTPUT}/result.txt
else
showerror
echo "详细错误日志请查看 ${CURRENT_OUTPUT}/error.txt" | tee -a ${CURRENT_OUTPUT}/result.txt
fi
echo "详细执行日志请查看 ${CURRENT_OUTPUT}/monkey_log.txt" | tee -a ${CURRENT_OUTPUT}/result.txt
echo "log日志请查看 ${CURRENT_OUTPUT}/log.txt" | tee -a ${CURRENT_OUTPUT}/result.txt
echo "报告请查看 ${CURRENT_OUTPUT}/result.txt"
if [[ ${anrtime} != 0 ]]
then
# anr日志
adb pull /data/anr/traces.txt ${CURRENT_OUTPUT}
echo "anr日志请查看 ${CURRENT_OUTPUT}/traces.txt" | tee -a ${CURRENT_OUTPUT}/result.txt
fi

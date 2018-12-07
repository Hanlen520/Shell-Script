#!/bin/bash
# Author: Shengjie.Liu
# Date: 2018-12-07
# Version: 1.8
# Description: script of monkey
# How to use: sh +x easy_monkey.sh <packagename> <extime>

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
OUTPUT_RESULT=${CURRENT_OUTPUT}/result_monkey.txt

init_data
# clear log
adb logcat -c

# 手机型号（品牌/型号/系统版本）
brand=$(adb shell getprop ro.product.brand)
model=$(adb shell getprop ro.product.model)
release=$(adb shell getprop ro.build.version.release)

# 屏幕分辨率/密度
size=`adb shell dumpsys window displays | grep "init" | tr -d $'\r' | awk '{print $1}' | cut -d"=" -f 2`
density=`adb shell dumpsys window displays | grep "init" | tr -d $'\r' | awk '{print $2}'`
display=${size}/${density}

echo "手机型号：${brand} ${model} ${release} ${display}" | tee -a ${OUTPUT_RESULT}

packagename=${1}
echo "应用包名：${packagename}" | tee -a ${OUTPUT_RESULT}

version=$(adb shell dumpsys package ${packagename} | grep versionName | sed 's/ //g' | tr -d $'\r' | cut -d"=" -f 2)
echo "应用版本：${version}" | tee -a ${OUTPUT_RESULT}

extime=${2}
case ${extime} in
    1)  extime=54000
    ;;
    2)  extime=108000
    ;;
    8)  extime=432000
    ;;
    *)  echo "执行次数：${extime}" | tee -a ${OUTPUT_RESULT}
    ;;
esac

echo "开始时间：`date "+%Y-%m-%d %H:%M:%S"`" | tee -a ${OUTPUT_RESULT}

# 未设置各类型事件百分比
# adb shell monkey -p ${packagename} --ignore-crashes --ignore-timeouts --ignore-security-exceptions \
# -s 1024 --throttle 200 -v ${extime} 1>${CURRENT_OUTPUT}/monkey_log.txt 2>${CURRENT_OUTPUT}/error.txt

# keyboard
#adb shell monkey -p com.cootek.test  -p com.adroid.mms -p ${packagename} --throttle 10 --ignore-crashes \
#--ignore-timeouts --ignore-security-exceptions -s 1024 -v ${extime} \
#1>${CURRENT_OUTPUT}/monkey_log.txt 2>${CURRENT_OUTPUT}/error.txt

# 设置各类型事件百分比
adb shell monkey -p ${packagename} --pct-touch 40 --pct-motion 25 --pct-appswitch 10 --pct-rotation 5 \
--ignore-crashes --ignore-timeouts --ignore-security-exceptions \
-s 1024 --throttle 200 -v ${extime} 1>${CURRENT_OUTPUT}/monkey_log.txt 2>${CURRENT_OUTPUT}/error.txt

echo "结束时间：`date "+%Y-%m-%d %H:%M:%S"`" | tee -a ${OUTPUT_RESULT}

sleep 5s
# screenshot after the monkey done
adb exec-out screencap -p > ${CURRENT_OUTPUT}/end.png

# quit this app, back to home
count=1
while (( ${count}<=10 )); do
    adb shell input keyevent 4
    let "count++"
done

showerror(){
    cat ${CURRENT_OUTPUT}/error.txt | grep "CRASH" | tee -a ${OUTPUT_RESULT}
    cat ${CURRENT_OUTPUT}/error.txt | grep "ANR" | tee -a ${OUTPUT_RESULT}
}
crashtime=$(cat ${CURRENT_OUTPUT}/error.txt | grep "CRASH" -c)
anrtime=$(cat ${CURRENT_OUTPUT}/error.txt | grep "ANR" -c)

showmonkeylogcrash(){
    cat ${CURRENT_OUTPUT}/monkey_log.txt | grep "CRASH" | tee -a ${OUTPUT_RESULT}
}
monkeylogcrashtime=$(cat ${CURRENT_OUTPUT}/monkey_log.txt | grep "CRASH" -c)

# log命令
adb logcat -d -v time "${packagename}:V" > ${CURRENT_OUTPUT}/log.txt

showfatal(){
    cat ${CURRENT_OUTPUT}/log.txt | grep "FATAL" | tee -a ${OUTPUT_RESULT}
}
fataltime=$(cat ${CURRENT_OUTPUT}/log.txt | grep "FATAL" -c)

echo | tee -a ${OUTPUT_RESULT}
echo "分析结果：" | tee -a ${OUTPUT_RESULT}
echo "------------------------------------" | tee -a ${OUTPUT_RESULT}

echo "关键字 CRASH 共有 ${crashtime} 处（error.txt）" | tee -a ${OUTPUT_RESULT}
echo "关键字 ANR 共有 ${anrtime} 处（error.txt）" | tee -a ${OUTPUT_RESULT}
echo "关键字 CRASH 共有 ${monkeylogcrashtime} 处（monkey_log.txt）" | tee -a ${OUTPUT_RESULT}
echo "关键字 FATAL 共有 ${fataltime} 处（log.txt）" | tee -a ${OUTPUT_RESULT}

echo | tee -a ${OUTPUT_RESULT}
echo "崩溃日志：" | tee -a ${OUTPUT_RESULT}

if [[ ${crashtime} != 0 || ${anrtime} != 0 ]]; then
    showerror
    echo "详细错误日志请查看 ${CURRENT_OUTPUT}/error.txt" | tee -a ${OUTPUT_RESULT}
elif [[ ${crashtime} == 0 && ${anrtime} == 0 && ${fataltime} != 0 ]]; then
    showfatal
    echo "详细错误日志请查看 ${CURRENT_OUTPUT}/log.txt" | tee -a ${OUTPUT_RESULT}
elif [[ ${crashtime} == 0 && ${anrtime} == 0 && ${fataltime} == 0 && ${monkeylogcrashtime} != 0 ]]; then
    showmonkeylogcrash
    echo "详细错误日志请查看 ${CURRENT_OUTPUT}/monkey_log.txt" | tee -a ${OUTPUT_RESULT}
else
    echo "无" | tee -a ${OUTPUT_RESULT}
fi

echo "详细执行日志请查看 ${CURRENT_OUTPUT}/monkey_log.txt" | tee -a ${OUTPUT_RESULT}
echo "log日志请查看 ${CURRENT_OUTPUT}/log.txt" | tee -a ${OUTPUT_RESULT}
if [[ ${anrtime} != 0 ]]
then
# anr日志
adb pull /data/anr/traces.txt ${CURRENT_OUTPUT}
echo "anr日志请查看 ${CURRENT_OUTPUT}/traces.txt" | tee -a ${OUTPUT_RESULT}
fi
echo "报告请查看 ${OUTPUT_RESULT}"

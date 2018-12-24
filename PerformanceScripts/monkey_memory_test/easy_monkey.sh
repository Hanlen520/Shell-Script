#!/bin/bash
# Author: Shengjie.Liu
# Date: 2018-12-24
# Version: 2.1
# Description: script of monkey
# How to use: sh +x easy_monkey.sh <packagename> <extime>

init_data(){
    if [[ ! -d ${OUTPUT} ]]; then
        mkdir -p ${OUTPUT}
    fi
    if [[ ! -d ${CURRENT_OUTPUT} ]]; then
        mkdir -p ${CURRENT_OUTPUT}
    fi
    if [[ ! -d ${TEMP_FILE} ]]; then
        mkdir -p ${TEMP_FILE}
    fi
    touch ${OUTPUT_RESULT}
    touch ${CPUINFO_FILE}
    touch ${CPUTIME_FILE}
    touch ${CPUINFO_CSV}
    touch ${CPUINFO_BK_CSV}
}

# process id
function getPid() {
    adb shell ps | grep ${1} | tr -d $'\r' | awk '{print $2}' | head -n 1
}

# cpu kernel
function getCpuKer() {
    adb shell cat /proc/cpuinfo | grep "processor" > ${TEMP_FILE}/processor_count
    cpu_ker_count=`awk 'END{print NR}' ${TEMP_FILE}/processor_count`
    echo ${cpu_ker_count}
}

# process cpu time
function processCpuTime() {
    adb shell cat /proc/${1}/stat > ${TEMP_FILE}/process_cpu_time
    utime=$(cat ${TEMP_FILE}/process_cpu_time | awk '{print $14}')
    stime=$(cat ${TEMP_FILE}/process_cpu_time | awk '{print $15}')
    cutime=$(cat ${TEMP_FILE}/process_cpu_time | awk '{print $16}')
    cstime=$(cat ${TEMP_FILE}/process_cpu_time | awk '{print $17}')
    result=`expr ${utime} + ${stime} + ${cutime} + ${cstime}`
    echo ${result}
}

# total cpu time
function totalCpuTime() {
    adb shell cat /proc/stat > ${TEMP_FILE}/total_cpu_time
    cat ${TEMP_FILE}/total_cpu_time | grep "cpu" | head -n 1 > ${TEMP_FILE}/total_cpu
    user=$(cat ${TEMP_FILE}/total_cpu | awk '{print $2}')
    nice=$(cat ${TEMP_FILE}/total_cpu | awk '{print $3}')
    system=$(cat ${TEMP_FILE}/total_cpu | awk '{print $4}')
    idle=$(cat ${TEMP_FILE}/total_cpu | awk '{print $5}')
    iowait=$(cat ${TEMP_FILE}/total_cpu | awk '{print $6}')
    irq=$(cat ${TEMP_FILE}/total_cpu | awk '{print $7}')
    softirq=$(cat ${TEMP_FILE}/total_cpu | awk '{print $8}')
    result=`expr ${user} + ${nice} + ${system} + ${idle} + ${iowait} + ${irq} + ${softirq}`
    echo ${result}
}

# cpu usage rate
function getCpuRate() {
    process_cpu_time1=`processCpuTime ${1}`
    total_cpu_time1=`totalCpuTime`
    sleep 1s
    process_cpu_time2=`processCpuTime ${1}`
    total_cpu_time2=`totalCpuTime`
    process_cpu_time3=$(( ${process_cpu_time2} - ${process_cpu_time1} ))
    total_cpu_time3=$(( ${total_cpu_time2} - ${total_cpu_time1} ))
    cpu_rate=$(bc <<< "scale=3;(${process_cpu_time3}/${total_cpu_time3})*${2}*100")
    result=$(echo "scale=0;${cpu_rate}/1" | bc -l)
    echo ${result}
}

WORKSPACE=`pwd`
OUTPUT=${WORKSPACE}/output_monkey
CURRENT_TIME=`date +%Y%m%d%H%M`
# output directory
CURRENT_OUTPUT=${OUTPUT}/${CURRENT_TIME}
# monkey report
OUTPUT_RESULT=${CURRENT_OUTPUT}/result_monkey.txt
# temporary folder
TEMP_FILE=${CURRENT_OUTPUT}/temp
# CPU file
CPUINFO_FILE=${TEMP_FILE}/cpuinfo.txt
CPUTIME_FILE=${TEMP_FILE}/cputime.txt
# CSV file
CPUINFO_CSV=${CURRENT_OUTPUT}/cpuinfo.csv
CPUINFO_BK_CSV=${TEMP_FILE}/cpuinfo_bk.csv

init_data
# clear log
adb logcat -c

# phone info(brand/model/system version)
brand=$(adb shell getprop ro.product.brand | sed 's/ //g' | tr -d $'\r')
model=$(adb shell getprop ro.product.model | sed 's/ //g' | tr -d $'\r')
release=$(adb shell getprop ro.build.version.release | sed 's/ //g' | tr -d $'\r')
release_one=$(echo ${release} | awk -F. '{print $1}')

# screen resolution/density
if [[ ${release_one} > 4 ]]; then
	density=$(adb shell wm density | tr -d $'\r' | awk '{print $3}')
	size=$(adb shell wm size | tr -d $'\r' | awk '{print $3}')
	display="${size}/${density}dpi"
else
	size=`adb shell dumpsys window displays | grep "init" | tr -d $'\r' | awk '{print $1}' | cut -d"=" -f 2`
	density=`adb shell dumpsys window displays | grep "init" | tr -d $'\r' | awk '{print $2}'`
	display="${size}/${density}"
fi

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
# screen shot after the monkey done
adb exec-out screencap -p > ${CURRENT_OUTPUT}/end.png

# quit this app, back to home
count=1
while (( ${count}<=10 )); do
    adb shell input keyevent 4
    let "count++"
done
# press home key in case of back key that didn't work
adb shell input keyevent 3

# log command
adb logcat -d -v time "${packagename}:V" > ${CURRENT_OUTPUT}/log.txt
adb logcat -d -v time > ${CURRENT_OUTPUT}all_log.txt

echo "正在获取CPU使用率..."

# monkey跑完后的3、5、10分钟各取一次cpu值，超过40%可到内存脚本的输出文件夹里查看cpuinfo.txt文件以排查问题
# process id
pid=`getPid ${packagename}`
# cpu kernel
cpu_ker=`getCpuKer`
# start dump cpn info
echo "TIME FLAG:"  `date "+%Y-%m-%d %H:%M:%S"` >> ${CPUTIME_FILE}
#cpuinfo=$(adb shell dumpsys cpuinfo | grep ${packagename} | head -n 1 | sed 's/ //g' | tr -d $'\r' | cut -d"%" -f 1)
cpuinfo=`getCpuRate ${pid} ${cpu_ker}`
echo ${cpuinfo} >> ${CPUINFO_FILE}
# after 3minutes
sleep 180s
echo "TIME FLAG:"  `date "+%Y-%m-%d %H:%M:%S"` >> ${CPUTIME_FILE}
#cpuinfo3=$(adb shell dumpsys cpuinfo | grep ${packagename} | head -n 1 | sed 's/ //g' | tr -d $'\r' | cut -d"%" -f 1)
cpuinfo3=`getCpuRate ${pid} ${cpu_ker}`
echo ${cpuinfo3} >> ${CPUINFO_FILE}
# after 5minutes
sleep 120s
echo "TIME FLAG:"  `date "+%Y-%m-%d %H:%M:%S"` >> ${CPUTIME_FILE}
#cpuinfo5=$(adb shell dumpsys cpuinfo | grep ${packagename} | head -n 1 | sed 's/ //g' | tr -d $'\r' | cut -d"%" -f 1)
cpuinfo5=`getCpuRate ${pid} ${cpu_ker}`
echo ${cpuinfo5} >> ${CPUINFO_FILE}
# after 10minutes
sleep 300s
echo "TIME FLAG:"  `date "+%Y-%m-%d %H:%M:%S"` >> ${CPUTIME_FILE}
#cpuinfo10=$(adb shell dumpsys cpuinfo | grep ${packagename} | head -n 1 | sed 's/ //g' | tr -d $'\r' | cut -d"%" -f 1)
cpuinfo10=`getCpuRate ${pid} ${cpu_ker}`
echo ${cpuinfo10} >> ${CPUINFO_FILE}

echo "CPU走势：${cpuinfo}%（monkey结束时）-> ${cpuinfo3}%（3分钟后）-> ${cpuinfo5}%（5分钟后）-> ${cpuinfo10}%（10分钟后）" \
| tee -a ${OUTPUT_RESULT}

cat ${CPUTIME_FILE} | while read line
do
	echo ${line#*:} >> ${TEMP_FILE}/time
done

linecount=`awk 'END{print NR}' ${CPUINFO_FILE}`

echo "Time,Percent" > ${CPUINFO_CSV}
for ((j=1;j<=${linecount};j++));
do
    value_cpu=`tail -n ${j} ${CPUINFO_FILE} | head -n 1`
    time_cpu=`tail -n ${j} ${TEMP_FILE}/time | head -n 1`
    echo "${time_cpu},${value_cpu}" >> ${CPUINFO_BK_CSV}
done

line_count=`awk 'END{print NR}' ${CPUINFO_BK_CSV}`
for ((k=1;k<=${line_count};k++));
do
	total_line=`tail -n ${k} ${CPUINFO_BK_CSV} | head -n 1`
    echo "${total_line}" >> ${CPUINFO_CSV}
done

# delete temporary folder
rm -r ${TEMP_FILE}

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
echo "cpu日志请查看 ${CPUINFO_CSV}" | tee -a ${OUTPUT_RESULT}
echo "报告请查看 ${OUTPUT_RESULT}"

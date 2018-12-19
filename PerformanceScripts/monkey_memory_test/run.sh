#!/usr/bin/env bash

# 创建文件夹OUTPUT
# 创建文件夹CURRENT_OUTPUT
# 创建文件MEMINFO_FILE
# -d 目录
# -p 若指定路径的父目录不存在则一并创建
init_data()
{
    if [[ ! -d ${OUTPUT} ]];then
        mkdir -p ${OUTPUT}
    fi
    if [[ ! -d ${CURRENT_OUTPUT} ]];then
        mkdir -p ${CURRENT_OUTPUT}
    fi
    if [[ ! -d ${TEMP_FILE} ]];then
        mkdir -p ${TEMP_FILE}
    fi
    touch ${MEMINFO_FILE}
    touch ${CPUINFO_FILE}
    touch ${OUTPUT_RESULT}
    touch ${MOBILE_DATA_FILE}
    touch ${MOBILE_TIME_FILE}
}

# 将日期追加入MEMINFO_FILE
# 将内存信息追加入MEMINFO_FILE
dump_memory_info()
{
#    echo "dump memeryinfo:"
    echo "TIME FLAG:"  `date "+%Y-%m-%d %H:%M:%S"` >> ${1}
    adb shell dumpsys meminfo ${2} >> ${1}
}

dump_cpu_info()
{
    echo "TIME FLAG:"  `date "+%Y-%m-%d %H:%M:%S"` >> ${1}
#    adb shell dumpsys cpuinfo | grep ${2} >> ${1}
    adb shell top -n 1 >> ${1}
    echo "" >> ${1}
}

# 每隔一分钟拉取一次流量值，最后生成csv文件
# 部分手机cat /proc/uid_stat/uid/tcp_rcv方法无效，超过5次无效则改用cat /proc/net/xt_qtaguid/stats
dump_mobile_data()
{
    rcv=`adb shell cat /proc/uid_stat/${2}/tcp_rcv 2>&1 | sed 's/ //g' | tr -d $'\r'`
    snd=`adb shell cat /proc/uid_stat/${2}/tcp_snd 2>&1 | sed 's/ //g' | tr -d $'\r'`
    if [[ ${rcv} =~ "Nosuchfileordirectory" && ${4} -ge 5 ]]; then
        rcv_all=`adb shell cat /proc/net/xt_qtaguid/stats | grep ${2} | awk '{rx_bytes+=$6}END{print rx_bytes}'`
        snd_all=`adb shell cat /proc/net/xt_qtaguid/stats | grep ${2} | awk '{rx_bytes+=$8}END{print rx_bytes}'`
        data_all=`echo "($rcv_all+$snd_all)" | bc`
        echo "TIME FLAG:"  `date "+%Y-%m-%d %H:%M:%S"` >> ${1}
        echo ${data_all} >> ${3}
    elif [[ ${rcv} =~ "Nosuchfileordirectory" ]]; then
        echo ${rcv} >> /dev/null 2>&1
    else
        data=`echo "($rcv+$snd)" | bc`
        echo "TIME FLAG:"  `date "+%Y-%m-%d %H:%M:%S"` >> ${1}
        echo ${data} >> ${3}
    fi
}

# 输入的分钟乘以6后赋值给TIME
# 举例：输入5分钟，5*6=30，赋值给TIME
# i=1;i<=30;i++
# 每隔10秒钟记录一次内存值，总耗时300秒，300/60=5，也就是5分钟
#start_monitor_memory()
#{
#    TIME=$[TIME*6]
#    for((i=1;i<=$TIME;i++));
#    do
#        dump_memery_info
#        sleep 10
#    done
#}

#每隔一分钟拉取一次内存信息
start_monitor()
{
    for((i=1;i<=${1};i++));
    do
        dump_memory_info ${2} ${3}
        dump_cpu_info ${4}
        dump_mobile_data ${5} ${6} ${7} ${i}
        sleep 60
    done
}

# 调用memory_report脚本，传入参数MEMINFO_FILE和CURRENT_TIME
# 将logs/csv/t_u.csv文件复制到MEMINFO_CSV_FILE
report_memory_info()
{
    sh +x memory_report.sh ${1} ${2} ${4} ${5}
    cp -p logs/csv/t_u.csv ${3}
    cp -p logs/csv/mobile_data.csv ${6}
}

# 运行脚本时传入的第一个参数：包名
PACKAGE_NAME=$1
# 第二个参数：运行时间（分钟）
TIME=$2
# 当前时间
CURRENT_TIME=`date +%Y%m%d%H%M`
# 绝对路径
WORKSPACE=`pwd`
# 输出文件夹
OUTPUT=${WORKSPACE}/output_memory
# 用当前时间命名的输出文件夹
CURRENT_OUTPUT=${OUTPUT}/${CURRENT_TIME}
# 内存信息文件
MEMINFO_FILE=${CURRENT_OUTPUT}/meminfo.txt
# 内存csv文件
MEMINFO_CSV_FILE=${CURRENT_OUTPUT}/meminfo.csv
# 输出报告
OUTPUT_RESULT=${CURRENT_OUTPUT}/result_memory.txt
# cpu信息文件
CPUINFO_FILE=${CURRENT_OUTPUT}/cpuinfo.txt
# 临时文件夹
TEMP_FILE=${CURRENT_OUTPUT}/temp
# 流量文件
MOBILE_DATA_FILE=${TEMP_FILE}/mobile_data.txt
MOBILE_TIME_FILE=${TEMP_FILE}/mobile_time.txt
# 流量csv文件
MOBILE_DATA_CSV=${CURRENT_OUTPUT}/mobile_data.csv

# UID
userid=$(adb shell dumpsys package ${PACKAGE_NAME} | grep userId= | sed 's/ //g' | tr -d $'\r' | cut -c 8-12)

read -t 300 -p "请确认已联网用于收集流量数据(y/n) -> "
if [[ ${REPLY} == "y" || ${REPLY} == "Y" ]]; then
    init_data
    echo "`date "+%Y-%m-%d %H:%M:%S"`, start dump information about memory, cpu and mobile data." | tee -a ${OUTPUT_RESULT}
    start_monitor ${TIME} ${MEMINFO_FILE} ${PACKAGE_NAME} ${CPUINFO_FILE} ${MOBILE_TIME_FILE} ${userid} ${MOBILE_DATA_FILE}
    echo "`date "+%Y-%m-%d %H:%M:%S"`, stop dump information about memory, cpu and mobile data." | tee -a ${OUTPUT_RESULT}
    # 内存信息记录完后，调用此方法输出报告
    report_memory_info ${MEMINFO_FILE} ${CURRENT_TIME} ${MEMINFO_CSV_FILE} ${MOBILE_DATA_FILE} ${MOBILE_TIME_FILE} ${MOBILE_DATA_CSV}

    # delete logs&temp file
    rm -r logs
    rm -r ${TEMP_FILE}

    echo "============================" | tee -a ${OUTPUT_RESULT}
    echo "内存信息请查看：" | tee -a ${OUTPUT_RESULT}
    echo ${MEMINFO_FILE} | tee -a ${OUTPUT_RESULT}
    echo ${MEMINFO_CSV_FILE} | tee -a ${OUTPUT_RESULT}
    echo "CPU信息请查看：" | tee -a ${OUTPUT_RESULT}
    echo ${CPUINFO_FILE} | tee -a ${OUTPUT_RESULT}
    echo "流量数据请查看：" | tee -a ${OUTPUT_RESULT}
    echo ${MOBILE_DATA_CSV} | tee -a ${OUTPUT_RESULT}
    echo "报告请查看 ${OUTPUT_RESULT}"
else
	echo "手机未联网，脚本停止运行"
	exit 1
fi

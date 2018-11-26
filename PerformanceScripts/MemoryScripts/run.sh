#!/usr/bin/env bash

# 创建文件夹OUTPUT
# 创建文件夹CURRENT_OUTPUT
# 创建文件MEMINFO_FILE
# -d 目录
# -p 若指定路径的父目录不存在则一并创建
init_data()
{
    if [ ! -d $OUTPUT ];then
        mkdir -p $OUTPUT
    fi
    if [ ! -d $CURRENT_OUTPUT ];then
        mkdir -p $CURRENT_OUTPUT
    fi
    touch $MEMINFO_FILE
}

# 将日期追加入MEMINFO_FILE
# 将内存信息追加入MEMINFO_FILE
dump_memery_info()
{
#    echo "dump memeryinfo:"
    echo "TIME FLAG:"  `date "+%Y-%m-%d %H:%M:%S"` >> $MEMINFO_FILE
    adb shell dumpsys meminfo $PACKAGE_NAME >> $MEMINFO_FILE
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
start_monitor_memory()
{
    for((i=1;i<=${TIME};i++));
    do
        dump_memery_info
        sleep 60
    done
}

# 调用memory_report脚本，传入参数MEMINFO_FILE和CURRENT_TIME
# 将logs/csv/t_u.csv文件复制到MEMINFO_CSV_FILE
report_memory_info()
{
    sh +x memory_report.sh $MEMINFO_FILE $CURRENT_TIME
    cp -p logs/csv/t_u.csv $MEMINFO_CSV_FILE
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
OUTPUT=${WORKSPACE}/output
# 用当前时间命名的输出文件夹
CURRENT_OUTPUT=${OUTPUT}/${CURRENT_TIME}
# 完整内存信息文件
MEMINFO_FILE=${CURRENT_OUTPUT}/meminfo.txt
# total值csv文件
MEMINFO_CSV_FILE=${CURRENT_OUTPUT}/meminfo.csv
# 输出结果
OUTPUT_RESULT=${CURRENT_OUTPUT}/result_memory.txt

init_data
echo "`date "+%Y-%m-%d %H:%M:%S"`, start dump memoryinfo" | tee -a ${OUTPUT_RESULT}
start_monitor_memory
echo "`date "+%Y-%m-%d %H:%M:%S"`, stop dump memoryinfo" | tee -a ${OUTPUT_RESULT}
# 内存信息记录完后，调用此方法输出报告
report_memory_info

echo "============================" | tee -a ${OUTPUT_RESULT}
echo "report memory info output:" | tee -a ${OUTPUT_RESULT}
echo $MEMINFO_FILE | tee -a ${OUTPUT_RESULT}
echo $MEMINFO_CSV_FILE | tee -a ${OUTPUT_RESULT}
echo "SUCESS" | tee -a ${OUTPUT_RESULT}
echo "报告请查看 ${OUTPUT_RESULT}"

#!/bin/bash
# function: parse meminfo.txt
# How to use: sh +x run.sh <meminfo.txt path>

init_data()
{
    if [[ ! -d ${CURRENT_OUTPUT} ]];then
        mkdir -p ${CURRENT_OUTPUT}
    fi
}

report_memory_info()
{
    sh +x memory_report.sh ${1}
    cp -p logs/csv/t_u.csv ${2}
}

MEMINFO=$1
CURRENT_TIME=`date +%Y%m%d%H%M`
WORKSPACE=`pwd`
CURRENT_OUTPUT=${WORKSPACE}/${CURRENT_TIME}
REPORT=${CURRENT_OUTPUT}/meminfo.csv

init_data
report_memory_info ${MEMINFO} ${REPORT}
rm -r logs
echo "Report: ${REPORT}"
echo "Success"

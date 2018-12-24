#!/bin/bash
# How to use: sh +x run.sh <meminfo.txt path>

MEMINFO=$1
CURRENT_TIME=`date +%Y%m%d%H%M`

report_memory_info()
{
    sh +x memory_report.sh ${MEMINFO} ${CURRENT_TIME}
    cp -p logs/csv/t_u.csv meminfo.csv
}

report_memory_info
rm -r logs
echo "Success"

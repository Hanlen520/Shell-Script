#!/usr/bin/env bash

#读取apk文件地址
read -p "请输入上个版本apk文件存放地址：" apk_old
read -p "请输入最新版本apk文件存放地址：" apk_new

#检查apk size
b_size_old=`ls -l ${apk_old} | awk '{print $5}'`
echo $b_size_old
k_size_old=`awk 'BEGIN{printf "%.2f\n", "'${b_size_old}'"/'1024'}'`
echo $k_size_old
m_size_old=`awk 'BEGIN{printf "%.2f\n", "'${k_size_old}'"/'1024'}'`
echo $m_size_old

b_size_new=`ls -l ${apk_new} | awk '{print $5}'`
echo $b_size_new
k_size_new=`awk 'BEGIN{printf "%.2f\n", "'${b_size_new}'"/'1024'}'`
echo $k_size_new
m_size_new=`awk 'BEGIN{printf "%.2f\n", "'${k_size_new}'"/'1024'}'`
echo $m_size_new

#输出apk size
echo "------"
echo "上个版本apk size: ${m_size_old}MB(${k_size_old}KB)"
echo "最新版本apk size: ${m_size_new}MB(${k_size_new}KB)"
#对比两个版本的apk size大小变化
if [[ `echo "${m_size_new} > ${m_size_old}" | bc` -eq 1 ]]
then
exceeded_size=$(printf "%.2f" `echo "scale=2;${m_size_new}-${m_size_old}"|bc`)
echo "最新版本比上个版本增加${exceeded_size}MB"
else
echo "apk size未增加"
fi

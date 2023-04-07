#!/bin/bash
ADDR=要监测的DDNS
TMPSTR=`ping ${ADDR} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'` 
port=要监测的端口
check_ip=`nmap $TMPSTR -p $port|grep open|wc -l` 
if [ $check_ip -eq 0 ];then 
	curl "后台面板的API" >/dev/null 2>&1 & 
	nscd -i hosts
	nscd -i passwd
	nscd -i group
	/etc/init.d/nscd restart
fi
echo ${TMPSTR}

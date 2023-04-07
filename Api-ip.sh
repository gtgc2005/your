#!/bin/bash
ADDR=要監測的DDNS
TMPSTR=`ping ${ADDR} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'` 
port=要監測端的口
check_ip=`nmap $TMPSTR -p $port|grep open|wc -l` 
if [ $check_ip -eq 0 ];then 
	curl "後台面板的API" >/dev/null 2>&1 & 
	nscd -i hosts
	nscd -i passwd
	nscd -i group
	/etc/init.d/nscd restart
fi
echo ${TMPSTR}

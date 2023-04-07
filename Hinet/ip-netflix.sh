#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# NAME=自己定义，例如HKT,注意保留引号
NAME="Hinet"

# API=你更换IP的链接，每家不一样，自己替换，注意保留引号
API="htts://"

# TG_BOT_TOKEN=自行前往@Botfather获取,默认null
TG_BOT_TOKEN=null

# TG_CHATID=与机器人@userinfobot 对话,默认null
TG_CHATID=null
COUNT=0
SESSION=/usr/local/bin/.netflix_session
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"

function Initialize {
    if [ -f $SESSION ]; then
        echo "发现 Session 文件，退出中"
        exit 0
    else
        echo "" > $SESSION
    fi
    echo -e "Netflix检测自动换ip 1.01版"
    echo -e "修改自https://github.com/Netflixxp/changip"    
    Test
}

function Test {
    Netflix=$(curl --user-agent "${UA_Browser}" -4 -fsL --write-out %{http_code} --output /dev/null --max-time 30 "https://www.netflix.com/title/70143836" 2>&1)
    Analyse
}

function Analyse {
    if [[ "$Netflix" == "404" ]]; then
        NetflixResult="Originals Only"
    elif [[ "$Netflix" == "403" ]]; then
        NetflixResult="Banned"
    elif [[ "$Netflix" == "000" ]]; then
        NetflixResult="Network Error"
    elif [[ "$Netflix" == "200" ]]; then
        NetflixResult="Normal"
    else
        NetflixResult="Error"
    fi
    if [[ "$Netflix" == "404" ]] || [[ "$Netflix" == "403" ]]; then
        ChangeIP
    else
        AfterCheck
    fi
}

function ChangeIP {
    if [[ $COUNT -eq 0 ]]; then
        SendStartMsg
    fi
    let COUNT++
    echo "尝试更换 IP 中，次数: $COUNT"
    curl $API > /dev/null 2>&1
    sleep 5m
    Test
}

function AfterCheck {
    if [[ $COUNT -eq 0 ]]; then
        echo "状态正常，退出中"
        Terminate
    else
        SendEndMsg
        echo "成功更换 IP，退出中"
        Terminate
    fi
}

function SendStartMsg {
    TGMessage="解锁已失效%0A服务器：$NAME"
    curl -s -X POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d chat_id=$TG_CHATID -d text="$TGMessage" -d parse_mode="HTML" >/dev/null 2>&1
}

function SendEndMsg {
    TGMessage="已恢复解锁%0A服务器：$NAME%0A尝试次数：$COUNT"
    curl -s -X POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d chat_id=$TG_CHATID -d text="$TGMessage" -d parse_mode="HTML" >/dev/null 2>&1
}

function Terminate {
    rm -rf /usr/local/bin/.netflix_session
    exit 0
}

if [ "$1" == "1" ]; then
    echo -e "修改自https://github.com/Netflixxp/changip"
    FirstNetflixResult="Originals Only"
    FirstGoogle="CN"
    COUNT=1
    ChangeIP
else
    Initialize
fi

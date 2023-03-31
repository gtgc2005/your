#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

function parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --email)
                email="$2"
                shift
                shift
                ;;
            --number)
                docker_num="$2"
                shift
                shift
                ;;
            --debug-output)
                set -x
                shift
                ;;
            *)
                error "Unknown argument: $1"
                display_help
                exit 1
        esac
    done
}

mk_swap() {
    #检查是否存在swapfile
    grep -q "swapfile" /etc/fstab

    #如果不存在将为其创建swap
    if [ $? -ne 0 ]; then
        mem_num=$(awk '($1 == "MemTotal:"){print $2/1024}' /proc/meminfo|sed "s/\..*//g"|awk '{print $1*2}')
        echo -e "${Green}swapfile未发现，正在为其创建swapfile${Font}"
        fallocate -l ${mem_num}M /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo '/swapfile none swap defaults 0 0' >> /etc/fstab
            echo -e "${Green}swap创建成功，并查看信息：${Font}"
            cat /proc/swaps
            cat /proc/meminfo | grep Swap
    else
        echo -e "${Red}swapfile已存在，swap设置失败，请先运行脚本删除swap后重新设置！${Font}"
    fi
    
}

del_swap(){
    #检查是否存在swapfile
    grep -q "swapfile" /etc/fstab

    #如果存在就将其移除
    if [ $? -eq 0 ]; then
        echo -e "${Green}swapfile已发现，正在将其移除...${Font}"
        sed -i '/swapfile/d' /etc/fstab
        echo "3" > /proc/sys/vm/drop_caches
        swapoff -a
        rm -f /swapfile
        echo -e "${Green}swap已删除！${Font}"
    else
        echo -e "${Red}swapfile未发现，swap删除失败！${Font}"
    fi
}

#检查docker程序是否存在不存在就安装
install_docker() {
    if which docker >/dev/null; then
        echo "Docker已安装...略过"
    else
        echo "安装 Docker ..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        check_docker_version=$(docker version &>/dev/null; echo $?)
        if [[ $check_docker_version -eq 0 ]]; then
            echo "Docker 安装成功."
        else
            echo "Docker 安装失败."
            exit 1
        fi
        systemctl enable docker || service docker start
        rm get-docker.sh
    fi
}

#判断防火墙
if_waf() {
    firewalld_a=$(systemctl status firewalld | grep "Active:" | awk '{print $2}')
    iptables_a=$(systemctl status firewalld | grep "Active:" | awk '{print $2}')
    if [ $firewalld_a = active ]; then
        echo "firewalld 停止中..."
        systemctl stop firewalld &>/dev/null
        echo "firewalld 已停止!"
    fi
    if [ $iptables_a = active ]; then
        echo "iptables 停止中"
        systemctl stop iptables &>/dev/null
        echo "iptables 已停止!"
    fi
}
clear

stop_docker() {
    docker stop `docker ps -aq`
}

rm_docker() {
    docker rm `docker ps -aq`
}

start_all_docker() {
    docker start `docker ps -aq`
}

show_input() {
    #定义数据
    read -p "您的Peer2Profit帐号(邮箱):" email 
    read -p "开设的容器数量(建议10):" docker_num 

    clear

    #数据展示
    echo "您的Peer2Profit帐号:"$email
    echo "开设的容器数量:":$docker_num
}

one_install() {
    clear
    mk_swap
    install_docker
    if_waf
    clear
    echo "请自行添加docker节点"
}


start_docker() {
    #循环启动docker
    for ((i=1;i<=$docker_num;i++))
    do
        docker run -d --restart=on-failure -e DOCKER_ID=a$i -e P2P_EMAIL=$email peer2profit/peer2profit_linux:latest
    done
}


show_menu() {
    echo -e "
  ${green}Peer2Profit.Net - Docker批量节点脚本

  ${green}0.${plain} 退出脚本
————————————————
  ${green}1.${plain} 首次安装
  ${green}2.${plain} 一键启动docker
  ${green}3.${plain} 一键删docker
————————————————
  ${green}4.${plain} 添加节点并启动
  ${green}5.${plain} 防火墙检测
  ${green}6.${plain} SWAP检测
  ${green}7.${plain} 删除SWAP
 "
    echo && read -p "请输入选择 [0-7]: " num

    case "${num}" in
        0) exit 0
        ;;
        1) one_install
        ;;
        2) start_all_docker
        ;;
        3) stop_docker && rm_docker
        ;;
        4) show_input  && start_docker
        ;;
        5) if_waf
        ;;
        6) mk_swap
        ;;
        7) del_swap
        ;;
        *) echo -e "${red}请输入正确的数字 [0-7]${plain}"
        ;;
    esac
}


if [[ $# > 0 ]]; then
    parse_args "$@"
    one_install
    start_docker
else
    show_menu
fi
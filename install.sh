#!/bin/bash

# 判断当前是否是 root 权限
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# 判断当前系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
else
    echo "No OS found"
    exit
fi

# 打印系统类型
if [ "$OS" == "CentOS Linux" || "$OS"=="centos" ]; then
    wget -O sforum_centos.sh https://ghproxy.com/https://raw.githubusercontent.com/zhuchunshu/sforum-script/main/install/centos.sh && bash ./sforum_centos.sh
elif [ "$OS" == "Ubuntu" ] || [ "$OS" == "Debian GNU/Linux" ]; then
    wget -O sforum_ubuntu.sh https://ghproxy.com/https://raw.githubusercontent.com/zhuchunshu/sforum-script/main/install/ubuntu.sh && bash ./sforum_ubuntu.sh
else
    echo "无法获取你的Linux发行版信息，请手动选择安装脚本进行安装"
fi

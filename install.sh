#!/bin/bash

# 定义一些颜色编码
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
NC=$(tput sgr0) # No Color

# 判断当前是否是 root 权限
if [ "$EUID" -ne 0 ]
  then echo -e "${RED}Please run as root${NC}"
  exit
fi

# 生成随机端口号
get_random_port() {
    while true; do
        RANDOM_PORT=$(shuf -i 10000-65535 -n 1)
        if ! (netstat -lnt | grep -q ":$RANDOM_PORT "); then
            return $RANDOM_PORT
            break
        fi
    done
}

read -p "是否要进行一键安装SForum？(y/n): " choice

if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
    echo -e "${GREEN}开始安装SForum...${NC}"
    
    # 检查包管理器类型，并安装必要的依赖
    if command -v yum > /dev/null; then
        echo -e "发现yum包管理器"
        echo -e "开始更新yum源..."
        sudo yum update -y
        sudo yum install curl -y
    elif command -v apt > /dev/null; then
        echo -e "发现apt包管理器"
        echo -e "开始更新apt源..."
        sudo apt update -y
        sudo apt install curl -y
    fi

    # 检查与安装Docker的代码对于所有的Linux发行版来说都是相同的
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "未检测到Docker，正在安装Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo systemctl enable --now docker
        rm -f get-docker.sh
        echo -e "Docker安装完成"
    else
        echo -e "Docker已安装"
    fi

    # 检查与安装docker-compose的代码对于所有的Linux发行版来说都是相同的
    if ! command -v docker-compose >/dev/null 2>&1; then
        echo -e "未检测到docker-compose，正在安装docker-compose..."
        sudo curl -SL "https://ghproxy.com/https://github.com/docker/compose/releases/download/v2.19.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        echo -e "docker-compose安装完成"
    else
        echo -e "docker-compose已安装"
    fi

    # 检查并创建/www/wwwroot目录，以及剩余的安装与设置步骤对所有的Linux发行版来说都是相同的。
    # 在此省略以保持回答的简洁性。

else
    echo -e "${RED}安装已取消${NC}"
    exit 1
fi

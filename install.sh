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

    # 检查与安装Docker的代码对于所有的Linux发行版来说都是相同的
    if ! command -v docker >/dev/null 2>&1; then
    
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
        sudo curl -SL "https://ghproxy.typecho.ltd/https://github.com/docker/compose/releases/download/v2.19.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        echo -e "docker-compose安装完成"
    else
        echo -e "docker-compose已安装"
    fi

         # 检查并创建/www/wwwroot目录
    if [ ! -d "/www/wwwroot" ]; then
        sudo mkdir -p /www/wwwroot
        echo -e "/www/wwwroot目录创建成功"
    fi
    
    # 进入/www/wwwroot目录
    cd /www/wwwroot

    # 遍历查找新的SForum目录名
    i=1
    while [ -d "SForum_$i" ]; do
        ((i++))
    done

    # 创建新的SForum目录
    sforum_dir="SForum_$i"
    mkdir $sforum_dir
    echo -e "创建新目录：$sforum_dir"
    
    # 进入新创建的SForum目录
    cd $sforum_dir

    # 在这里添加SForum的安装代码
    # 生成未被使用的4-5位随机端口号
    get_random_port
    random_port=$?
    # echo -e "生成的随机端口号：$random_port"

    # 下载docker-compose.yml 文件
    read -p "${GREEN}是否需要国内服务器加速？(y/n):${NC} " server_location
    if [ "$server_location" == "y" ] || [ "$server_location" == "Y" ]; then
        wget https://ghproxy.typecho.ltd/https://raw.githubusercontent.com/zhuchunshu/SForum/master/docker-compose.yml
    else
        wget https://raw.githubusercontent.com/zhuchunshu/SForum/master/docker-compose.yml
    fi
    # 修改docker-compose.yml文件，将端口映射替换为新生成的随机端口号
    sed -i "s/- \"9501:9501/- \"${random_port}:9501/g" docker-compose.yml

    # 执行docker-compose up -d 来启动容器
    docker-compose up -d

    echo -e "请为您的 SForum 实例配置反向代理，目标地址：http://127.0.0.1:${random_port}"
    # 打印启动后的日志
    echo -e "等待几秒钟，容器正在启动..."

    sleep 15  # 等待几秒钟以确保容器完全启动

    echo -e "mysql容器名为：${GREEN}sforum_${i}-db-1${NC}"
    echo -e "redis容器名为：${GREEN}sforum_${i}-redis-1${NC}"
    echo -e "SForum容器名为：${GREEN}sforum_${i}-web-1${NC}"
    echo -e "docker-compose.yml文件目录：${GREEN}/www/wwwroot/${sforum_dir}${NC}"
    echo -e "${GREEN}SForum 安装完成！${GREEN}"

else
    echo -e "${RED}安装已取消${NC}"
    exit 1
fi

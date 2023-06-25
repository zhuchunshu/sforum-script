#!/bin/bash

# 生成随机端口号
get_random_port() {
    while true; do
        RANDOM_PORT=$(shuf -i "10000"-"65535" -n 1)
        if ! (netstat -lnt | awk -F"[ :]+" '$5 ~ "[0-9]+" {print $5}' | grep -q $RANDOM_PORT); then
            return $RANDOM_PORT
            break
        fi
    done
}

read -p "是否要进行一键安装SForum？(y/n): " choice

if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
    echo "开始安装SForum..."
    echo "开始更新yum源..."
    sudo yum update -y

    sudo yum install curl -y

    # 检查是否安装了docker
    if ! command -v docker >/dev/null 2>&1; then
        echo "未检测到Docker，正在安装Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh && systemctl enable docker
        rm -f get-docker.sh
        echo "Docker安装完成"
    else
        echo "Docker已安装"
    fi

    # 检查是否安装了docker-compose
    if ! command -v docker-compose >/dev/null 2>&1; then
        echo "未检测到docker-compose，正在安装docker-compose..."
        curl -L https://ghproxy.com/https://github.com/docker/compose/releases/download/v2.19.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        echo "docker-compose安装完成"
    else
        echo "docker-compose已安装"
    fi

     # 检查并创建/www/wwwroot目录
    if [ ! -d "/www/wwwroot" ]; then
        sudo mkdir -p /www/wwwroot
        echo "/www/wwwroot目录创建成功"
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
    echo "创建新目录：$sforum_dir"

    # 进入新创建的SForum目录
    cd $sforum_dir

    # 在这里添加SForum的安装代码
    # 生成未被使用的4-5位随机端口号
    get_random_port
    random_port=$?
    # echo "生成的随机端口号：$random_port"

    # 下载docker-compose.yml 文件
    read -p "是否需要国内服务器加速？(y/n): " server_location
    if [ "$server_location" == "y" ] || [ "$server_location" == "Y" ]; then
        wget https://gitee.com/zhuchunshu/SForum/raw/master/docker-compose.yml
    else
        wget https://raw.githubusercontent.com/zhuchunshu/SForum/master/docker-compose.yml
    fi
    # 修改docker-compose.yml文件，将端口映射替换为新生成的随机端口号
    sed -i "s/- \"9501:9501/- \"${random_port}:9501/g" docker-compose.yml

    # 执行docker-compose up -d 来启动容器
    docker-compose up -d

    echo "请为您的 SForum 实例配置反向代理，目标地址：http://127.0.0.1:${random_port}"
    # 打印启动后的日志
    echo "等待几秒钟，容器正在启动..."

    sleep 15  # 等待几秒钟以确保容器完全启动

    echo "mysql容器名为：sforum_${i}-db-1"
    echo "redis容器名为：sforum_${i}-redis-1"
    echo "SForum容器名为：sforum_${i}-web-1"
    echo "SForum 安装完成！"

else
    echo "安装已取消"
    exit 1
fi

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

dir="/www/wwwroot"
counter=0

if [ -d "$dir" ]; then
    for f in "$dir"/SForum_*; do
        if [ -d "${f}" ] && [ -e "${f}/docker-compose.yml" ]; then
        #如果是第一次循环
        if [ $counter -eq 0 ]; then
            echo -e "${GREEN}以下可能是存放docker-compose.yml文件的目录列表${NC}"
        fi
            counter=$((counter+1))
            echo -e ${f}
        fi
    done
fi

echo -e "${GREEN}您可能启动了: ${counter}个SForum服务，以上可能是存放docker-compose.yml文件的目录列表${NC}"


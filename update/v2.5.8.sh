#!/bin/bash

#上更新锁
php CodeFec CodeFec:U

# 设置要保留的文件夹名单
KEEP_FOLDERS=("Core" "User" "Topic" "Comment")

# 检查是否为目录并且不在保留名单中，然后删除
for folder in /data/www/app/Plugins/*; do
    if [ -d "$folder" ] && [[ ! " ${KEEP_FOLDERS[*]} " =~ " $(basename "$folder") " ]]; then
        rm -rf "$folder"
        echo "已删除文件夹: $folder"
    fi
done

rm -rf /data/www/app/Plugins/Core/src/Controller/WebSocket

# 开始更新
php CodeFec CodeFec:U

echo -e "\033[31m 不要退出，请无视上面信息，进程还在继续 \033[0m"
echo -e "\033[31m 不要退出，请无视上面信息，进程还在继续 \033[0m"
echo -e "\033[31m 不要退出，请无视上面信息，进程还在继续 \033[0m"
echo -e "\033[31m 不要退出，请无视上面信息，进程还在继续 \033[0m"

# 更新完成
composer update && composer du -o && composer dumpautoload -o

## 输出更新完成请退出容器终端
echo -e "\033[32m 更新完成，请退出容器终端 \033[0m"


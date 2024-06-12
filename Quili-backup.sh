#!/bin/bash

function ssh(){
    # 生成 SSH 密钥对
    echo "正在生成SSH密钥对"
    ssh-keygen -t rsa -b 2048
    
    # 提示用户输入目标 VPS 的用户名和 IP 地址
    read -p "请输入存储 VPS 的用户名: " USERNAME
    read -p "请输入存储 VPS 的 IP 地址: " IP_ADDRESS
    
    # 复制公钥到目标主机
    ssh-copy-id -i ~/.ssh/id_rsa.pub $USERNAME@$IP_ADDRESS

    # 定义存储文件路径
    FILE="/root/存储VPS信息.txt"

    # 如果文件不存在，先创建文件
    if [ ! -f "$FILE" ]; then
        touch "$FILE"
    fi

    # 检查并添加或修改 USERNAME 参数
    if grep -q '^USERNAME=' "$FILE"; then
        sed -i 's/^USERNAME=.*/USERNAME='"$USERNAME"'/' "$FILE"
    else
        echo 'USERNAME='"$USERNAME" >> "$FILE"
    fi
    
    # 检查并添加或修改 USERNAME 参数
    if grep -q '^IP_ADDRESS=' "$FILE"; then
        sed -i 's/^IP_ADDRESS=.*/IP_ADDRESS='"$IP_ADDRESS"'/' "$FILE"
    else
        echo 'IP_ADDRESS='"$IP_ADDRESS" >> "$FILE"
    fi

    echo "ssh公钥配置成功"
}


function backup(){
  wget -O backup.sh https://raw.githubusercontent.com/garlzr/Quili-backup/main/backup.sh && chmod +x backup.sh && ./backup.sh
}

# 主菜单
function main_menu() {
    clear
    echo "请选择要执行的操作:"
    echo "1. 配置存储VPS的ssh公钥"
    echo "2. 定期备份store文件至存储VPS的root/backup路径 (6H一次)"
    read -p "请输入选项（1-2）: " OPTION

    case $OPTION in
    1) ssh ;;
    2) backup ;;
    *) 
        echo "无效选项。" 
        read -p "按任意键返回主菜单..."
        main_menu
        ;;
    esac
}

# 显示主菜单
main_menu

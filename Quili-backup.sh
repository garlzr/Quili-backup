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

    # 检查是否存在 USERNAME 参数，不存在则添加
    grep -qxF 'export USERNAME='"$USERNAME" /root/.bashrc || echo 'export USERNAME='"$USERNAME" >> /root/.bashrc
    
    # 检查是否存在 IP_ADDRESS 参数，不存在则添加
    grep -qxF 'export IP_ADDRESS='"$IP_ADDRESS" /root/.bashrc || echo 'export IP_ADDRESS='"$IP_ADDRESS" >> /root/.bashrc

    # 使 .bashrc 生效
    source /root/.bashrc
}


function backup(){
  wget -O backup.sh https://raw.githubusercontent.com/garlzr/Quili-backup/main/backup.sh && chmod +x backup.sh && ./backup.sh
}

# 主菜单
function main_menu() {
    clear
    echo "请选择要执行的操作:"
    echo "1. 配置存储VPS的ssh公钥"
    echo "2. 定期备份store文件至存储VPS的root/backup路径 (6h一次)"
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

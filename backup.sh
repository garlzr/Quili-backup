#!/bin/bash
TARGET_DIR="/tmp/$(hostname)----$(hostname -I | awk '{print $1}')"
SOURCE_DIR="/root/ceremonyclient/node/.config/store"

# 从 /root/存储VPS信息.txt 文件中读取变量
while IFS='=' read -r key value; do
  case "$key" in
    'USERNAME') USERNAME="$value" ;;
    'IP_ADDRESS') IP_ADDRESS="$value" ;;
  esac
done < /root/存储VPS信息.txt

# 检查是否成功加载变量
if [[ -z "$USERNAME" || -z "$IP_ADDRESS" ]]; then
  echo "未能从 /root/存储VPS信息.txt 文件中获取 USERNAME 或 IP_ADDRESS"
  exit 1
else
  echo "成功加载存储VPS信息"
  echo "USERNAME: $USERNAME"
  echo "IP_ADDRESS: $IP_ADDRESS"
fi

REMOTE_SERVER="$USERNAME@$IP_ADDRESS:/root/backup"

# Function to execute the backup commands
execute_commands() {
    mkdir -p $TARGET_DIR
    cp -r $SOURCE_DIR $TARGET_DIR
    cp /root/ceremonyclient/node/.config/config.yml $TARGET_DIR
    cp /root/ceremonyclient/node/.config/keys.yml $TARGET_DIR
    rsync -avz $TARGET_DIR $REMOTE_SERVER
    rm -rf $TARGET_DIR
}

# 最大重试次数
MAX_RETRIES=5
retry_count=0

# 循环直到命令成功执行或达到最大重试次数
while true; do
    # 执行命令
    if execute_commands; then
        # 检查命令执行后的错误信息
        ERROR_INFO=$(execute_commands 2>&1 >/dev/null)
        if [ -n "$ERROR_INFO" ]; then
            BACKUP_STATUS="$(hostname)----$(hostname -I | awk '{print $1}')备份失败"
            echo "Commands executed successfully but with error message: $ERROR_INFO"
        else
            BACKUP_STATUS="$(hostname)----$(hostname -I | awk '{print $1}')备份成功"
            echo "Commands executed successfully."
        fi
        break
    else
        echo "An error occurred. Retrying..."
        retry_count=$((retry_count + 1))
        if [ $retry_count -ge $MAX_RETRIES ]; then
            echo "Failed after $MAX_RETRIES attempts. Exiting."
            BACKUP_STATUS="$(hostname)----$(hostname -I | awk '{print $1}')备份失败"
            break
        fi
        sleep 10  # 可选：等待 10 秒后重试
    fi
done


(crontab -l | grep -v 'backup.sh' ; echo "* * * * * /root/backup.sh") | crontab -

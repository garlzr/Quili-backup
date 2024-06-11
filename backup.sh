#!/bin/bash
wget  -O push_message.js https://raw.githubusercontent.com/garlzr/Quilibrium_backup/main/push_message.js
TARGET_DIR="/tmp/$(hostname)----$(hostname -I | awk '{print $1}')"
SOURCE_DIR="/root/ceremonyclient/node/.config/store"
REMOTE_SERVER="xxx@xxx:/root/backup" #示例 填写你的vps信息
NODE_INFO=$(cd $HOME/ceremonyclient/node && ./node-1.4.19-linux-amd64 --node-info | grep "Unclaimed balance:" | awk '{print $3 " " $4}')

JS_SCRIPT_PATH="/root/push_message.js"  # 替换为你的script.js的实际路径

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
# Call the JavaScript script with the backup status and node info as arguments

if ! command -v node &> /dev/null
then
    echo "Node.js is not installed. Installing..."
    # Install Node.js
    curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt-get install -y nodejs
    npm install axios
    # Verify installation
    if ! command -v node &> /dev/null
    then
        echo "Node.js installation failed. Exiting..."
    fi
fi

# Check if axios is installed
if ! npm list axios &> /dev/null
then
    echo "axios is not installed. Installing..."
    npm install axios
fi

node $JS_SCRIPT_PATH "$BACKUP_STATUS" "$NODE_INFO"

crontab -l | grep -q '/root/backup.sh' || (crontab -l ; echo "0 */8 * * * /root/backup.sh") | crontab -

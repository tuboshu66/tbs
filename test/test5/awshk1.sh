#!/bin/bash

# 定义日志文件
LOG_FILE="/var/log/setup_script.log"

# Telegram 通知函数
function TG_BOT() {
    export TGSEND_TOKEN="5688173096:AAFyqcmKdfa1TaaBMnXNRgs7DGCZYQz5iS8"
    export TGSEND_CHATID="1088857444"
    curl -s -k "https://thingproxy.freeboard.io/fetch/https://api.telegram.org/bot$TGSEND_TOKEN/sendMessage" \
        --data-urlencode "chat_id=$TGSEND_CHATID" \
        --data-urlencode "text=$TG_MESSAGE" \
        > /dev/null &
}

# 函数：记录日志并发送 Telegram 通知
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
    TG_MESSAGE="$1"
    TG_BOT
}

# 更新包管理器并安装 unzip
log "Updating package manager and installing unzip..."
if sudo apt-get update && sudo apt-get install unzip -y; then
    log "Successfully updated package manager and installed unzip."
else
    log "Failed to update package manager or install unzip." && exit 1
fi

# 删除旧的 node_install 文件并下载新的
log "Removing old node_install file and downloading a new one..."
if rm -rf /root/node_install && wget -O /root/node_install https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test5/node_install; then
    chmod +x /root/node_install
    log "Successfully downloaded and set permissions for node_install."
else
    log "Failed to download node_install." && exit 1
fi

# 执行 node_install 脚本并自动输入选项
log "Executing node_install script..."
if echo "2" | /root/node_install cn; then
    log "Successfully executed node_install script."
else
    log "Failed to execute node_install script." && exit 1
fi

# 下载并运行 tcp.sh 脚本，自动输入选项
log "Downloading and running tcp.sh script..."
if wget -N "https://ghproxy.cyou/https://raw.githubusercontent.com/xiaoyiya/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh; then
    echo "4" | ./tcp.sh
    log "Successfully executed tcp.sh script."
else
    log "Failed to download or execute tcp.sh script." && exit 1
fi

# 下载并配置 Nginx 所需文件
log "Downloading and configuring Nginx files..."
if sudo wget -O /usr/local/nginx/tbsazdl.conf https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/tbsazdl.conf &&
   sudo wget -O /usr/local/nginx/tbs.conf https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/tbs.conf &&
   sudo mkdir -p /usr/local/nginx/cert &&
   sudo wget -O /usr/local/nginx/cert/tbstls.pem https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/cert/tbstls.pem &&
   sudo wget -O /usr/local/nginx/cert/tbstls.key https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/cert/tbstls.key &&
   sudo wget -O /usr/local/nginx/ws https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test5/download/ws_hk; then
    sudo systemctl reload nginx
    log "Successfully configured Nginx and reloaded service."
else
    log "Failed to download or configure Nginx files." && exit 1
fi

# 下载并运行 nezha 安装脚本
log "Downloading and running Nezha installation script..."
if curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/install.sh -o nezha.sh && chmod +x nezha.sh; then
    ./nezha.sh install_agent vps.tbstbs168.com 5555 074648d3cc2fece2db
    log "Successfully installed Nezha agent."
else
    log "Failed to download or install Nezha agent." && exit 1
fi

# 更新 DDNS 并设置定时任务
log "Downloading and running DDNS script..."
if wget -N https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/DDNSawshk1.sh && chmod +x DDNSawshk1.sh; then
    ./DDNSawshk1.sh
    log "Successfully executed DDNS script."

    # 添加到 crontab
    if (crontab -l; echo "*/5 * * * * /path/to/DDNSawshk1.sh >> /var/log/ddns.log 2>&1") | crontab -; then
        log "Successfully added DDNS script to crontab."
    else
        log "Failed to add DDNS script to crontab." && exit 1
    fi
else
    log "Failed to download or execute DDNS script." && exit 1
fi

log "All tasks completed successfully."

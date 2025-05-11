#!/bin/bash

# 设置日志文件
LOG_FILE="/var/log/setup_script.log"
ERRORS=()

# Telegram 通知函数
function TG_BOT() {
    export TGSEND_TOKEN="5688173096:AAFyqcmKdfa1TaaBMnXNRgs7DGCZYQz5iS8"
    export TGSEND_CHATID="1088857444"
    curl -s -k "https://thingproxy.freeboard.io/fetch/https://api.telegram.org/bot$TGSEND_TOKEN/sendMessage" \
        --data-urlencode "chat_id=$TGSEND_CHATID" \
        --data-urlencode "text=$TG_MESSAGE" \
        > /dev/null &
}

# 记录日志并发送 Telegram
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
    TG_MESSAGE="$1"
    TG_BOT
}

# 执行命令并处理错误
run_step() {
    STEP_DESC="$1"
    shift
    if "$@"; then
        log "✅ $STEP_DESC 成功"
    else
        log "❌ $STEP_DESC 失败"
        ERRORS+=("$STEP_DESC")
    fi
}

mkdir -p /root/scripts

# 步骤 1：更新 apt 并安装 unzip
run_step "更新包管理器并安装 unzip" bash -c '
    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        sleep 2
    done
    sudo apt-get update && sudo apt-get install unzip -y
'

# 步骤 2：下载并设置 node_install
run_step "下载 node_install 文件" bash -c '
    rm -rf /root/scripts/node_install
    wget -O /root/scripts/node_install https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test5/node_install
    chmod +x /root/scripts/node_install
'

# 步骤 3：执行 node_install 脚本
run_step "执行 node_install 脚本" bash -c 'echo "2" | /root/scripts/node_install cn'

# 步骤 4：下载并执行 BBR 脚本
run_step "下载并执行 BBR 脚本" bash -c '
    wget -N -O /root/scripts/tcp.sh "https://ghproxy.cyou/https://raw.githubusercontent.com/xiaoyiya/Linux-NetSpeed/master/tcp.sh"
    chmod +x /root/scripts/tcp.sh
    echo "4" | /root/scripts/tcp.sh
'

# 步骤 5：下载并配置 Nginx 所需文件
run_step "配置 Nginx" bash -c '
    sudo wget -O /usr/local/nginx/tbsazdl.conf https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/tbsazdl.conf &&
    sudo mkdir -p /usr/local/nginx/cert &&
    sudo wget -O /usr/local/nginx/cert/tbstls.pem https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/cert/tbstls.pem &&
    sudo wget -O /usr/local/nginx/cert/tbstls.key https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/cert/tbstls.key &&
    sudo wget -O /usr/local/nginx/ws https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test5/download/ws_hk &&
    sudo systemctl reload nginx
'

# 步骤 6：添加自动同步
run_step "添加自动同步" bash -c '
    echo "AWS HK 3" | sudo tee /root/.status_name &&
    wget -O /usr/bin/hksync https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test5/hksync &&
    chmod +x /usr/bin/hksync &&
    /usr/bin/hksync addcron &&
    sudo mkdir -p /usr/local/nginx/cert &&
    sudo wget -O /usr/local/nginx/cert/tbstls.pem https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/cert/tbstls.pem &&
    sudo wget -O /usr/local/nginx/cert/tbstls.key https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/cert/tbstls.key
'

# 步骤 7：安装 Nezha Agent
run_step "安装 Nezha 监控代理" bash -c '
    curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/install.sh -o /root/scripts/nezha.sh &&
    chmod +x /root/scripts/nezha.sh &&
    /root/scripts/nezha.sh install_agent vps.tbstbs168.com 5555 85b9720cfd13a9b8fa
'

# 步骤 8：运行 DDNS 脚本
run_step "执行 DDNS 脚本" bash -c '
    wget -N -O /root/scripts/DDNSawshk3.sh https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/DDNSawshk3.sh &&
    chmod +x /root/scripts/DDNSawshk3.sh &&
    /root/scripts/DDNSawshk3.sh &&
    (crontab -l; echo "*/5 * * * * /root/scripts/DDNSawshk3.sh >> /var/log/ddns.log 2>&1") | crontab -
'

# 步骤 9：获取并报告 IP
run_step "获取并上报公网 IP" bash -c '
    IP_ADDRESS=$(curl -s https://api.ipify.org)
    if [ -n "$IP_ADDRESS" ]; then
        log "当前的最新 DDNS IP 地址是：$IP_ADDRESS"
    else
        log "无法获取公共 IP 地址"
        return 1
    fi
'

# 总结结果
if [ ${#ERRORS[@]} -ne 0 ]; then
    log "⚠️ 脚本执行完成，但有以下步骤失败："
    for err in "${ERRORS[@]}"; do
        log "🔸 $err"
    done
else
    log "🎉 所有任务全部成功完成。"
fi

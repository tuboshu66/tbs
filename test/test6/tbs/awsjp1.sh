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

# 创建目录（如果不存在）
mkdir -p /root/scripts

# 更新包管理器并安装 unzip
log "更新包管理器并安装 unzip..."
MAX_RETRIES=5
RETRY_DELAY=10
ATTEMPT=1

# 检查并等待锁释放
while [ $ATTEMPT -le $MAX_RETRIES ]; do
    if sudo apt-get update && sudo apt-get install unzip -y; then
        log "成功更新包管理器并安装 unzip。"
        break
    else
        if [ -f /var/lib/dpkg/lock-frontend ]; then
            log "检测到 dpkg 锁被占用 (尝试 $ATTEMPT/$MAX_RETRIES)，等待 $RETRY_DELAY 秒后重试..."
            sleep $RETRY_DELAY
            ATTEMPT=$((ATTEMPT + 1))
        else
            log "更新包管理器或安装 unzip 失败，且未检测到锁文件。"
            exit 1
        fi
    fi
done

# 如果重试次数耗尽仍未成功
if [ $ATTEMPT -gt $MAX_RETRIES ]; then
    log "多次尝试后仍无法获取 dpkg 锁，可能是另一个进程占用。请检查并释放锁后重试。"
    exit 1
fi

# 删除旧的 node_install 文件并下载新的到指定目录
log "删除旧的 node_install 文件并下载新的..."
if rm -rf /root/scripts/node_install && wget -O /root/scripts/node_install https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test5/node_install; then
    chmod +x /root/scripts/node_install
    log "成功下载并设置 node_install 文件权限。"
else
    log "下载 node_install 失败。" && exit 1
fi

# 执行 node_install 脚本并自动输入选项
log "执行 node_install 脚本..."
if echo "2" | /root/scripts/node_install cn; then
    log "成功执行 node_install 脚本。"
else
    log "执行 node_install 脚本失败。" && exit 1
fi

# 下载并运行 tcp.sh 脚本，自动输入选项
log "下载并运行 tcp.sh 脚本..."
if wget -N -O /root/scripts/tcp.sh "https://ghproxy.net/https://raw.githubusercontent.com/xiaoyiya/Linux-NetSpeed/master/tcp.sh" && chmod +x /root/scripts/tcp.sh; then
    echo "4" | /root/scripts/tcp.sh
    log "成功执行 tcp.sh 脚本。"
else
    log "下载或执行 tcp.sh 脚本失败。" && exit 1
fi

# 下载并配置 Nginx 所需文件到指定目录
log "下载并配置 Nginx 文件..."
if sudo wget -O /usr/local/nginx/tbsazdl.conf https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/tbsazdl.conf &&
   sudo wget -O /usr/local/nginx/tbs.conf https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/tbs.conf &&
   sudo mkdir -p /usr/local/nginx/cert &&
   sudo wget -O /usr/local/nginx/cert/tbstls.pem https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/cert/tbstls.pem &&
   sudo wget -O /usr/local/nginx/cert/tbstls.key https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/cert/tbstls.key &&
   sudo wget -O /usr/local/nginx/ws https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test5/download/ws_hk; then
    sudo systemctl reload nginx
    log "成功配置 Nginx 并重新加载服务。"
else
    log "下载或配置 Nginx 文件失败。" && exit 1
fi

# 下载并运行 Nezha 安装脚本到指定目录
log "下载并运行 Nezha 安装脚本..."
if curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/install.sh -o /root/scripts/nezha.sh && chmod +x /root/scripts/nezha.sh; then
    # 第一次运行 Nezha 安装脚本
    /root/scripts/nezha.sh install_agent vps.tbstbs168.com 5555 2f3e5bc69ccb9RSS12
    log "第一次运行 Nezha 安装脚本完成。"

    # 第二次运行 Nezha 安装脚本（如果有必要）
    #/root/scripts/nezha.sh install_agent vps.tbstbs168.com 5555 206891f4dabaca3c96
    #log "第二次运行 Nezha 安装脚本完成。"

    log "成功安装 Nezha 监控。"
else
    log "下载或安装 Nezha 代理失败。" && exit 1
fi

# 获取当前公共 IP 地址并发送到 Telegram
get_ip_and_notify() {
    # 获取当前的公共 IP 地址
    IP_ADDRESS=$(curl -s https://api.ipify.org)

    # 检查 IP 地址是否为空
    if [ -z "$IP_ADDRESS" ]; then
        log "无法获取公共 IP 地址，IP 地址为空。"
        return
    fi

    # 使用 log 函数记录并发送通知
    log "当前的最新 DDNS IP 地址是：$IP_ADDRESS"
}

# 下载并运行 DDNS 更新脚本到指定目录
log "下载并运行 DDNS 脚本..."
if wget -N -O /root/scripts/DDNSawsjp1.sh https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/DDNSawsjp1.sh && chmod +x /root/scripts/DDNSawsjp1.sh; then
    /root/scripts/DDNSawsjp1.sh
    log "成功执行 DDNS 脚本。"

    # 获取并通知最新的 IP 地址
    get_ip_and_notify

    # 添加到 crontab
    if (crontab -l; echo "*/5 * * * * /root/scripts/DDNSawsjp1.sh >> /var/log/ddns.log 2>&1") | crontab -; then
        log "成功将 DDNS 脚本添加到定时任务。"
    else
        log "添加 DDNS 脚本到定时任务失败。" && exit 1
    fi
else
    log "下载或执行 DDNS 脚本失败。" && exit 1
fi

log "所有任务完成成功。"
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

# 检查并安装 lsof（用于检测占用锁的进程）
log "检查并安装 lsof..."
if ! command -v lsof >/dev/null 2>&1; then
    if sudo apt-get update && sudo apt-get install -y lsof; then
        log "成功安装 lsof。"
    else
        log "无法安装 lsof，将尝试继续执行，但可能无法正确检测占用锁的进程。"
    fi
fi

# 更新包管理器并安装 unzip
log "更新包管理器并安装 unzip..."
# 设置非交互式前端，避免 debconf 弹出交互式提示
export DEBIAN_FRONTEND=noninteractive

if sudo apt-get update && sudo apt-get install -y unzip; then
    log "成功更新包管理器并安装 unzip。"
else
    # 检查并处理所有可能的锁文件
    LOCK_FILES=("/var/lib/dpkg/lock-frontend" "/var/lib/dpkg/lock" "/var/cache/apt/archives/lock" "/var/cache/debconf/config.dat")
    for LOCK_FILE in "${LOCK_FILES[@]}"; do
        if [ -f "$LOCK_FILE" ]; then
            # 检测占用锁的进程 ID
            if command -v lsof >/dev/null 2>&1; then
                LOCK_PID=$(sudo lsof "$LOCK_FILE" | awk '/apt|dpkg|debconf/{print $2}' | grep -v PID | sort -u)
            else
                LOCK_PID=$(ps aux | grep -E '[a]pt|[d]pkg|[d]ebconf' | awk '{print $2}' | sort -u)
            fi

            if [ -n "$LOCK_PID" ]; then
                log "检测到 $LOCK_FILE 被进程 $LOCK_PID 占用，正在强制终止这些进程..."
                for PID in $LOCK_PID; do
                    sudo kill -9 "$PID"
                done
                sleep 2  # 等待进程完全终止
            else
                log "未找到占用 $LOCK_FILE 的进程，但锁文件存在。"
            fi

            # 删除锁文件
            log "删除锁文件 $LOCK_FILE..."
            sudo rm -f "$LOCK_FILE"
        fi
    done

    # 预设 debconf 配置，保持本地修改的配置文件
    echo "openssh-server openssh-server/config-file-policy select keep" | sudo debconf-set-selections

    # 修复可能的中断状态并重试
    log "修复 dpkg 和 apt 状态并重试安装..."
    sudo dpkg --configure -a
    sudo apt-get install -f -y  # 修复依赖问题
    if sudo apt-get update && sudo apt-get install -y unzip; then
        log "成功更新包管理器并安装 unzip。"
    else
        log "强制删除锁后仍无法更新或安装 unzip，请手动检查系统状态（可能仍有未清理的进程或依赖问题）。"
        exit 1
    fi
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
   #sudo wget -O /usr/local/nginx/tbs.conf https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/tbs.conf &&
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
    /root/scripts/nezha.sh install_agent vps.tbstbs168.com 5555 JxkrFWm8CmwXOaXk6n
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
if wget -N -O /root/scripts/DDNSlinode3.sh https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/DDNSlinode3.sh && chmod +x /root/scripts/DDNSlinode3.sh; then
    /root/scripts/DDNSlinode3.sh
    log "成功执行 DDNS 脚本。"

    # 获取并通知最新的 IP 地址
    get_ip_and_notify

    # 添加到 crontab
    if (crontab -l; echo "*/5 * * * * /root/scripts/DDNSlinode3.sh >> /var/log/ddns.log 2>&1") | crontab -; then
        log "成功将 DDNS 脚本添加到定时任务。"
    else
        log "添加 DDNS 脚本到定时任务失败。" && exit 1
    fi
else
    log "下载或执行 DDNS 脚本失败。" && exit 1
fi

log "所有任务完成成功。"
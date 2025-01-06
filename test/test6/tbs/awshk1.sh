# 创建目录（如果不存在）
mkdir -p /root/scripts

# 更新包管理器并安装 unzip
log "Updating package manager and installing unzip..."
if sudo apt-get update && sudo apt-get install unzip -y; then
    log "Successfully updated package manager and installed unzip."
else
    log "Failed to update package manager or install unzip." && exit 1
fi

# 删除旧的 node_install 文件并下载新的到指定目录
log "Removing old node_install file and downloading a new one..."
if rm -rf /root/scripts/node_install && wget -O /root/scripts/node_install https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test5/node_install; then
    chmod +x /root/scripts/node_install
    log "Successfully downloaded and set permissions for node_install."
else
    log "Failed to download node_install." && exit 1
fi

# 执行 node_install 脚本并自动输入选项
log "Executing node_install script..."
if echo "2" | /root/scripts/node_install cn; then
    log "Successfully executed node_install script."
else
    log "Failed to execute node_install script." && exit 1
fi

# 下载并运行 tcp.sh 脚本，自动输入选项
log "Downloading and running tcp.sh script..."
if wget -N -O /root/scripts/tcp.sh "https://ghproxy.net/https://raw.githubusercontent.com/xiaoyiya/Linux-NetSpeed/master/tcp.sh" && chmod +x /root/scripts/tcp.sh; then
    echo "4" | /root/scripts/tcp.sh
    log "Successfully executed tcp.sh script."
else
    log "Failed to download or execute tcp.sh script." && exit 1
fi

# 下载并配置 Nginx 所需文件到指定目录
log "Downloading and configuring Nginx files..."
if sudo wget -O /root/scripts/tbsazdl.conf https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/tbsazdl.conf &&
   sudo wget -O /root/scripts/tbs.conf https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/tbs.conf &&
   sudo mkdir -p /root/scripts/cert &&
   sudo wget -O /root/scripts/cert/tbstls.pem https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/cert/tbstls.pem &&
   sudo wget -O /root/scripts/cert/tbstls.key https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/cert/tbstls.key &&
   sudo wget -O /root/scripts/ws https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test5/download/ws_hk; then
    sudo systemctl reload nginx
    log "Successfully configured Nginx and reloaded service."
else
    log "Failed to download or configure Nginx files." && exit 1
fi

# 下载并运行 Nezha 安装脚本到指定目录
log "Downloading and running Nezha installation script..."
if curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/install.sh -o /root/scripts/nezha.sh && chmod +x /root/scripts/nezha.sh; then
    /root/scripts/nezha.sh install_agent vps.tbstbs168.com 5555 074648d3cc2fece2db
    log "Successfully installed Nezha agent."
else
    log "Failed to download or install Nezha agent." && exit 1
fi

# 下载并运行 DDNS 更新脚本到指定目录
log "Downloading and running DDNS script..."
if wget -N -O /root/scripts/DDNSawshk1.sh https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/DDNSawshk1.sh && chmod +x /root/scripts/DDNSawshk1.sh; then
    /root/scripts/DDNSawshk1.sh
    log "Successfully executed DDNS script."

    # 添加到 crontab
    if (crontab -l; echo "*/5 * * * * /root/scripts/DDNSawshk1.sh >> /var/log/ddns.log 2>&1") | crontab -; then
        log "Successfully added DDNS script to crontab."
    else
        log "Failed to add DDNS script to crontab." && exit 1
    fi
else
    log "Failed to download or execute DDNS script." && exit 1
fi

log "All tasks completed successfully."

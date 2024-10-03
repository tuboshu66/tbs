#!/bin/bash

# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装 Squid
sudo apt install squid -y

# 备份默认配置文件
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

# 获取本地网络 IP 段
local_ip=$(hostname -I | awk '{print $1}')
network_prefix=$(echo $local_ip | awk -F '.' '{print $1"."$2"."$3".0/24"}')

# 随机选择一个端口
port=$((RANDOM % 65536))
while [ $port -lt 1024 ]; do
    port=$((RANDOM % 65536))
done

# 配置 Squid
cat <<EOL | sudo tee /etc/squid/squid.conf
http_port $port

# 允许本地网段
acl localnet src $network_prefix
http_access allow localnet
http_access allow localhost
http_access deny all

# 日志设置（可选）
access_log /var/log/squid/access.log
cache_log /var/log/squid/cache.log

# 其他配置
visible_hostname localhost
EOL

# 启动和启用 Squid 服务
sudo systemctl start squid
sudo systemctl enable squid

# 配置防火墙（如果使用 ufw）
sudo ufw allow $port/tcp

echo "Squid HTTP 代理安装完成，监听端口为 $port"
echo "本地网络段为: $network_prefix"

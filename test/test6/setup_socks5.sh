#!/bin/bash

# 更新系统
apt update && apt upgrade -y

# 安装 Python 和 pip
apt install -y python3 python3-pip

# 安装 Shadowsocks
pip3 install shadowsocks

# 创建配置文件
cat <<EOL > config.json
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "password": "your_password",  # 修改为你自己的密码
    "timeout": 300,
    "method": "aes-256-cfb"
}
EOL

# 启动 Shadowsocks
sslocal -c config.json

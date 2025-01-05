#!/bin/bash

# 更新包管理器并安装 unzip
sudo apt-get update && sudo apt-get install unzip -y

# 删除旧的 node_install 文件并下载新的
rm -rf /root/node_install
wget --no-check-certificate https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test5/node_install -O /root/node_install
chmod +x /root/node_install

# 执行 node_install 脚本并自动输入选项
echo "2" | /root/node_install cn

# 下载并运行 tcp.sh 脚本，自动输入选项
wget -N --no-check-certificate "https://ghproxy.net/https://raw.githubusercontent.com/xiaoyiya/Linux-NetSpeed/master/tcp.sh"
chmod +x tcp.sh
echo "4" | ./tcp.sh

# 下载并配置 Nginx 所需文件
sudo wget -O /usr/local/nginx/tbsazdl.conf https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/tbsazdl.conf
sudo wget -O /usr/local/nginx/tbs.conf https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/tbs/tbs.conf
sudo mkdir -p /usr/local/nginx/cert
sudo wget -O /usr/local/nginx/cert/tbstls.pem https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/cert/tbstls.pem
sudo wget -O /usr/local/nginx/cert/tbstls.key https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test6/cert/tbstls.key
sudo wget -O /usr/local/nginx/ws https://raw.githubusercontent.com/tuboshu66/tbs/master/test/test5/download/ws_hk

# 重载 Nginx 服务
sudo systemctl reload nginx

# 下载并运行 nezha 安装脚本
curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/install.sh -o nezha.sh
chmod +x nezha.sh
./nezha.sh install_agent vps.tbstbs168.com 5555 074648d3cc2fece2db

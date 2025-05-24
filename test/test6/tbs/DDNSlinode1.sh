#!/bin/bash

# 检查 jq 是否已安装
function check_and_install_jq() {
  if ! command -v jq &> /dev/null; then
    echo "jq 未安装，正在安装..."
    # 根据不同的操作系统选择安装命令
    if [ -f /etc/debian_version ]; then
      sudo apt-get update
      sudo apt-get install -y jq
    elif [ -f /etc/redhat-release ]; then
      sudo yum install -y jq
    else
      echo "不支持的操作系统，请手动安装 jq。"
      exit 1
    fi
  else
    echo "jq 已安装，继续执行脚本。"
  fi
}

# Telegram 通知函数
function TG_BOT() {
  local TG_MESSAGE=$1
  export TGSEND_TOKEN="5688173096:AAFyqcmKdfa1TaaBMnXNRgs7DGCZYQz5iS8"
  export TGSEND_CHATID="1088857444"
  curl -s -k "https://thingproxy.freeboard.io/fetch/https://api.telegram.org/bot$TGSEND_TOKEN/sendMessage" \
      --data-urlencode "chat_id=$TGSEND_CHATID" \
      --data-urlencode "text=$TG_MESSAGE" \
      > /dev/null &
}

# Cloudflare API 信息
CF_API="https://api.cloudflare.com/client/v4/zones"
ZONE_ID="eea63961734d3988f1365492d0d0f2ad"  # 你的 Cloudflare 域名 Zone ID
RECORD_ID="9477f1b1483e121f726513510878ef93"  # 你要更新的 DNS 记录的 ID
AUTH_KEY="Ip9gxc9QqfPx-pgvn8uHXi_KjVGEUeYjXJITKhrM"  # 你的 API Token
DOMAIN="linode1.tfvou.com"  # 你想更新的域名或子域名

# 运行 jq 检查和安装
check_and_install_jq

# 获取当前公网 IP
CURRENT_IP=$(curl -s checkip.amazonaws.com)

# 获取当前 DNS 记录中的 IP
DNS_IP=$(curl -s -X GET "$CF_API/$ZONE_ID/dns_records/$RECORD_ID" \
         -H "Authorization: Bearer $AUTH_KEY" \
         -H "Content-Type: application/json" | jq -r '.result.content')

# 检查 IP 是否有变化
if [ "$CURRENT_IP" == "$DNS_IP" ]; then
  MESSAGE="linode1 IP 无变化，当前 IP 为 $CURRENT_IP。无需更新。"
  echo $MESSAGE
  TG_BOT "$MESSAGE"
else
  TTL=60  # 设置TTL为60秒
  
  # 更新 DNS 记录
  RESPONSE=$(curl -s -X PUT "$CF_API/$ZONE_ID/dns_records/$RECORD_ID" \
       -H "Authorization: Bearer $AUTH_KEY" \
       -H "Content-Type: application/json" \
       --data "{\"type\":\"A\",\"name\":\"$DOMAIN\",\"content\":\"$CURRENT_IP\",\"ttl\":$TTL,\"proxied\":false}")

  # 打印完整的响应，帮助排查错误
  echo "API 响应: $RESPONSE"

  # 检查是否成功更新
  if [[ $RESPONSE == *"\"success\":true"* ]]; then
      MESSAGE="linode1 DNS 记录已成功更新为 $CURRENT_IP，TTL 为 $TTL 秒。"
      echo $MESSAGE
      TG_BOT "$MESSAGE"
  else
      MESSAGE="linode1 DNS 记录更新失败。响应: $RESPONSE"
      echo $MESSAGE
      TG_BOT "$MESSAGE"
  fi
fi

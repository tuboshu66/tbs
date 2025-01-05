#!/bin/bash

# Cloudflare API 信息
CF_API="https://api.cloudflare.com/client/v4/zones"
ZONE_ID="eea63961734d3988f1365492d0d0f2ad"  # 你的 Cloudflare 域名 Zone ID 区域ID
RECORD_ID="addcd9a66bb10d13b6661c39502079ee"  # 你要更新的 DNS 记录的 ID
AUTH_KEY="Ip9gxc9QqfPx-pgvn8uHXi_KjVGEUeYjXJITKhrM"  # 你的  API Token
DOMAIN="awshk1.tfvou.com"  # 你想更新的域名或子域名
IP=$(curl -s checkip.amazonaws.com)  # 获取当前公网 IP
TTL=60  # 设置TTL为60秒

# 更新 DNS 记录
RESPONSE=$(curl -s -X PUT "$CF_API/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "Authorization: Bearer $AUTH_KEY" \
     -H "Content-Type: application/json" \
     --data "{\"type\":\"A\",\"name\":\"$DOMAIN\",\"content\":\"$IP\",\"ttl\":$TTL,\"proxied\":false}")

# 打印完整的响应，帮助排查错误
echo "API 响应: $RESPONSE"

# 检查是否成功更新
if [[ $RESPONSE == *"\"success\":true"* ]]; then
    echo "DNS 记录已成功更新为 $IP，TTL为 $TTL 秒"
else
    echo "DNS 记录更新失败"
fi

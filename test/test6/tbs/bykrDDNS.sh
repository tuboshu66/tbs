#!/bin/bash

# Cloudflare API 信息
CF_API="https://api.cloudflare.com/client/v4/zones"
ZONE_ID="eea63961734d3988f1365492d0d0f2ad"  # 你的 Cloudflare 域名 Zone ID 区域ID
RECORD_ID="cd02c7bee64112df052a19932817a0cd"  # 你要更新的 DNS 记录的 ID
AUTH_EMAIL="qc3277734@gmail.com"  # 你的 Cloudflare 账户邮箱
AUTH_KEY="3773452a14b1f9f0073ed467fa3c6efc79d9d"  # 你的 Cloudflare API Token
DOMAIN="bykr.tfvou.com"  # 你想更新的域名或子域名
IP=$(curl -s ifconfig.me)  # 获取当前公网 IP

# 更新 DNS 记录
RESPONSE=$(curl -s -X PUT "$CF_API/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "Authorization: Bearer $AUTH_KEY" \
     -H "Content-Type: application/json" \
     --data "{\"type\":\"A\",\"name\":\"$DOMAIN\",\"content\":\"$IP\",\"ttl\":120,\"proxied\":false}")

# 检查是否成功更新
if [[ $RESPONSE == *"\"success\":true"* ]]; then
    echo "DNS 记录已成功更新为 $IP"
else
    echo "DNS 记录更新失败"
fi

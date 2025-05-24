#!/bin/bash

# Telegram 通知函数
function TG_BOT() {
  export TGSEND_TOKEN="5688173096:AAFyqcmKdfa1TaaBMnXNRgs7DGCZYQz5iS8"
  export TGSEND_CHATID="1088857444"
  curl -s -k "https://thingproxy.freeboard.io/fetch/https://api.telegram.org/bot$TGSEND_TOKEN/sendMessage" \
      --data-urlencode "chat_id=$TGSEND_CHATID" \
      --data-urlencode "text=$TG_MESSAGE" \
      > /dev/null &
}

# 获取当前域名的IP
new_ip=$(nslookup linode1.tfvou.com | grep 'Address:' | tail -n 1 | awk '{print $2}')

# 确保获取到的 IP 地址不是空值
if [ -z "$new_ip" ]; then
  TG_MESSAGE="未获取到新的IP地址，请检查域名解析是否正确。"
  TG_BOT
  echo "$TG_MESSAGE"
  exit 1
fi

# 从 linode1.txt 中读取原有 IP
if [ -f /root/tbs/test/test6/tbs/linode1.txt ]; then
  old_ip=$(cat /root/tbs/test/test6/tbs/linode1.txt)
else
  TG_MESSAGE="linode1.txt 文件不存在，请检查路径。"
  TG_BOT
  echo "$TG_MESSAGE"
  exit 1
fi

# 确保原有 IP 地址不是空值
if [ -z "$old_ip" ]; then
  TG_MESSAGE="原有 IP 地址为空，请检查 linode1.txt 文件内容。"
  TG_BOT
  echo "$TG_MESSAGE"
  exit 1
fi

# 调试输出 IP 地址
echo "Old IP: $old_ip"
echo "New IP: $new_ip"

# 如果新 IP 与原 IP 不同，则执行替换
if [ "$new_ip" != "$old_ip" ]; then
  # 更新 tbs.conf 中所有的 IP
  if sed -i "s/$old_ip/$new_ip/g" /root/tbs/test/test6/tbs/tbs.conf; then
    echo "tbs.conf 文件中的 linode1 IP 更新成功。 $old_ip -> $new_ip"
  else
    TG_MESSAGE="更新 tbs.conf 文件中的 linode1 IP 失败。"
    TG_BOT
    echo "$TG_MESSAGE"
    exit 1
  fi

  # 更新 linode1.txt 中的 IP
  if echo "$new_ip" > /root/tbs/test/test6/tbs/linode1.txt; then
    TG_MESSAGE="linode1 IP 更新成功: $old_ip -> $new_ip linode1.txt"
    TG_BOT
    echo "$TG_MESSAGE"
  else
    TG_MESSAGE="更新 linode1.txt 文件中的 IP 失败。"
    TG_BOT
    echo "$TG_MESSAGE"
    exit 1
  fi
else
  TG_MESSAGE="linode1 IP 无变化 $new_ip"
  TG_BOT
  echo "$TG_MESSAGE"
fi

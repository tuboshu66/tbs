#!/bin/bash

# 获取当前域名的IP
new_ip=$(nslookup awshk1.tfvou.com | grep 'Address:' | tail -n 1 | awk '{print $2}')

# 确保获取到的 IP 地址不是空值
if [ -z "$new_ip" ]; then
  echo "未获取到新的IP地址，请检查域名解析是否正确。"
  exit 1
fi

# 从hkip1.txt中读取原有IP
old_ip=$(cat /root/tbs/test/test6/tbs/hkip1.txt)

# 确保原有 IP 地址不是空值
if [ -z "$old_ip" ]; then
  echo "原有IP地址为空，请检查hkip1.txt文件内容。"
  exit 1
fi

# 调试输出 IP 地址
echo "Old IP: $old_ip"
echo "New IP: $new_ip"

# 如果新IP与原IP不同，则执行替换
if [ "$new_ip" != "$old_ip" ]; then
  # 更新tbs.conf中所有的IP
  if sed -i "s/$old_ip/$new_ip/g" /root/tbs/test/test6/tbs/tbs.conf; then
    echo "tbs.conf 文件中的IP更新成功。"
  else
    echo "更新 tbs.conf 文件中的IP失败。" && exit 1
  fi

  # 更新hkip1.txt中的IP
  echo "$new_ip" > /root/tbs/test/test6/tbs/hkip1.txt
  echo "IP 更新成功: $old_ip -> $new_ip"
else
  echo "IP 无变化"
fi

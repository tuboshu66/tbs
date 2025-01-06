#!/bin/bash

# 获取当前域名的IP
new_ip=$(nslookup awshk1.tfvou.com | grep 'Address:' | tail -n 1 | awk '{print $2}')

# 确保获取到的 IP 地址不是空值
if [ -z "$new_ip" ]; then
  echo "未获取到新的IP地址，请检查域名解析是否正确。"
  exit 1
fi

# 从 hkip1.txt 中读取原有 IP
if [ -f /root/tbs/test/test6/tbs/hkip1.txt ]; then
  old_ip=$(cat /root/tbs/test/test6/tbs/hkip1.txt)
else
  echo "hkip1.txt 文件不存在，请检查路径。"
  exit 1
fi

# 确保原有 IP 地址不是空值
if [ -z "$old_ip" ]; then
  echo "原有 IP 地址为空，请检查 hkip1.txt 文件内容。"
  exit 1
fi

# 调试输出 IP 地址
echo "Old IP: $old_ip"
echo "New IP: $new_ip"

# 如果新 IP 与原 IP 不同，则执行替换
if [ "$new_ip" != "$old_ip" ]; then
  # 更新 tbs.conf 中所有的 IP
  if sed -i "s/$old_ip/$new_ip/g" /root/tbs/test/test6/tbs/tbs.conf; then
    echo "tbs.conf 文件中的 IP 更新成功。"
  else
    echo "更新 tbs.conf 文件中的 IP 失败。" && exit 1
  fi

  # 更新 hkip1.txt 中的 IP
  if echo "$new_ip" > /root/tbs/test/test6/tbs/hkip1.txt; then
    echo "hkip1.txt 文件中的 IP 更新成功。"
  else
    echo "更新 hkip1.txt 文件中的 IP 失败。" && exit 1
  fi

  echo "IP 更新成功: $old_ip -> $new_ip"
else
  echo "IP 无变化"
fi

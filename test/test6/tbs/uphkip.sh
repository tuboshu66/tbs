#!/bin/bash

# 获取当前域名的IP
new_ip=$(nslookup awshk1.tfvou.com | grep 'Address:' | tail -n 1 | awk '{print $2}')

# 从hkip.txt中读取原有IP
old_ip=$(cat /root/tbs/test/test6/tbs/hkip.txt)

# 如果新IP与原IP不同，则执行替换
if [ "$new_ip" != "$old_ip" ]; then
  # 更新tbs.conf中所有的IP
  sed -i "s/$old_ip/$new_ip/g" /root/tbs/test/test6/tbs/tbs.conf

  # 更新hkip.txt中的IP
  echo "$new_ip" > /root/tbs/test/test6/tbs/hkip.txt

  echo "IP 更新成功: $old_ip -> $new_ip"
else
  echo "IP 无变化"
fi

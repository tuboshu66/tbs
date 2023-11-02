#!/bin/bash
#远端文件储存地址
#升级内容开始
function update() {
#更新cnsync
rm -rf /usr/bin/cnsync ; wget https://ghproxy.net/https://raw.githubusercontent.com/gao1354184430/Gggd/master/test/test5/cnsync -O /usr/bin/cnsync ; chmod +x /usr/bin/cnsync
#更新nginx
mkdir /usr/local/nginx/tcp
cndownload="https://ghproxy.net/https://raw.githubusercontent.com/gao1354184430/Gggd/master/test/test5"
rm -rf /usr/local/nginx/conf/nginx.conf
wget -N -P /usr/local/nginx/conf/ $cndownload/download/nginx.conf
systemctl reload nginx
systemctl status nginx
echo "请检查状态确保无异常"
}
function menu_server() {
  echo && echo -e "  临时用升级脚本
 ————————————
 1.增加nginx对四层(TCP/UDP)转发的支持
 2.更新cnsync：增加对ngin-tcp同步的支持
————————————
" &&echo 
  echo
  read -erp " 请回车确认升级:" Num
  if [[ $Num == "" ]] ; then 
echo "开始升级"
update
echo "升级完成"
else
echo "终止程序，取消升级"
fi
}
menu_server
#!/bin/bash
#远端文件储存地址
Github="https://ghproxy.com/https://raw.githubusercontent.com/gao1354184430/Gggd/master/test/test6"
Down="https://www.isyunyi.com/download/linux"
haproxy_cfg="/usr/local/haproxy/haproxy.cfg"
#是否开启监控
rm -rf /root/.crontab.txt
curl -s $Github/crontab > /root/.crontab.txt
github_cron=`sed -n '1p' /root/.crontab.txt`
#测试与GitHub连通性
rm -rf /root/.test.txt
curl -s $Github/test > /root/.test.txt
github_test=`sed -n '1p' /root/.test.txt`
rm -rf /root/.test.txt /root/.crontab.txt
#安装haproxy
function install_haproxy(){
	yum update -y
	yum -y install gcc pcre pcre-devel zlib zlib-devel openssl openssl-devel
	cd /root
	wget $Down/haproxy-2.3.4.tar.gz
	tar -zxvf haproxy-*
	mv haproxy-2.3.4 haproxy
	#获取系统内核版本
	TarGet=`uname -r`
	TarGet=`echo $TarGet | sed -r 's/(.{4}).*/\1/'`
	TarGet=`echo $TarGet | sed 's/\.//g'`
	#编译安装，TARGET：系统内核版本， ARCH：系统架构，PREFIX：安装目录
	make TARGET=linux$TarGet ARCH=x86_64 PREFIX=/usr/local/haproxy
	make install PREFIX=/usr/local/haproxy
	echo "[Unit]
Description=HAProxy Load Balancer
After=syslog.target network.target
 
[Service]
ExecStart=/usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/haproxy.cfg
ExecReload=/bin/kill -USR2 
 
[Install]
WantedBy=multi-user.target" >/usr/lib/systemd/system/haproxy.service
	rm -rf $haproxy_cfg
	wget $Github/haproxy.cfg -O $haproxy_cfg
	rm -rf haproxy-2.3.4.tar.gz haproxy
	systemctl daemon-reload
	systemctl restart haproxy
	systemctl enable haproxy
	systemctl status haproxy
}
#从远端同步配置
function Restart_haproxy(){
	rm -rf $haproxy_cfg
	wget $Github/haproxy.cfg -O $haproxy_cfg
	systemctl restart haproxy
	echo -e "\033[32m haproxy文件已更新 \033[0m"
}
function haproxy_cron(){
if [[ $github_test == "success" ]] && [[ $github_cron == "true" ]]; then
	#监控
	rm -rf $haproxy_cfg.new 
	wget $Github/haproxy.cfg -O $haproxy_cfg.new
	haproxy_md5=`md5sum $haproxy_cfg  | cut -d ' ' -f1`
	haproxy_md5_n=`md5sum $haproxy_cfg.new  | cut -d ' ' -f1`
	#检查与远端是否相符
	if [[ $haproxy_md5 != $haproxy_md5_n ]]; then
		echo "brook与远端文件不符，正在同步"
		rm -rf $haproxy_cfg
		mv $haproxy_cfg.new $haproxy_cfg
		systemctl restart haproxy
		echo -e "\033[32m haproxy文件已更新，同步完成 \033[0m"
	else
		echo "所有文件与远端相符，无需同步"
	fi
else
	echo "通信中断或已关闭同步，请手动操作"
fi
}
menu_server() {
  echo && echo -e "  HAProxy2.3 一键安装/同步脚本 

 ————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 同步并重启服务
 ${Green_font_prefix} 2.${Font_color_suffix} 检查配置文件更新
————————————
 ${Green_font_prefix} 3.${Font_color_suffix} 安装脚本" &&echo 
 	echo -e "通信：\033[32m $github_test \033[0m"
	echo -e "同步：\033[32m $github_cron \033[0m"
	echo -e "快捷命令\033[32m /root/haproxy.sh install|sync|cron\033[0m 来执行同步操作" 
  echo
  read -erp " 请输入数字 [1-3]:" num
  case "$num" in
  1)
    Restart_haproxy
    ;;
  2)
    haproxy_cron
    ;;
  3)
    install_haproxy
    ;;
  *)
    echo "请输入正确数字 [1-3]"
    ;;
  esac
}
action=$1
if [[ -n $action ]]; then
#增加一个通信检测，如果与GitHub通信失败则停止脚本
if [[ $github_test == "success" ]]; then
if [[ $action == "sync" ]]; then
    Restart_haproxy
	echo -e "\033[32m haproxy文件已更新 \033[0m"
  elif [[ $action == "cron" ]]; then
    haproxy_cron
    echo -e "\033[32m haproxy文件已更新 \033[0m"
  elif [[ $action == "install" ]]; then
    install_haproxy
    echo -e "\033[32m haproxy文件已更新 \033[0m"
  fi
else
	echo -e "\033[31m 远端通信失败，程序中止 \033[0m"
fi
else
	menu_server
fi

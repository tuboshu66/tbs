#!/bin/bash
#定义函数
SERVER_NAME=""  #请在这里填写机器名称，方便通知时分辨
NGX=`netstat -anput | grep nginx | wc -l`
GOST=`netstat -anput | grep gost | wc -l`
VNETC=`netstat -anput | grep client | wc -l`
DA=`date "+%Y-%m-%d %H:%M:%S"`   #标准的时间输出
#TG通知部分，定义TG_MESSAGE后调用
function TG_BOT() {
export TGSEND_TOKEN="1918956809:AAG2pWiCrESamvFjHsE3_gyt8uVDCHJ69pk"
export TGSEND_CHATID="-1001523347747"
curl -s -k "https://thingproxy.freeboard.io/fetch/https://api.telegram.org/bot$TGSEND_TOKEN/sendMessage" \
    --data-urlencode "chat_id=$TGSEND_CHATID" \
    --data-urlencode "text=$TG_MESSAGE" \
    > /dev/null &
}
function nginx_status() {
if [ "$NGX" -ne 0 ]		#$NGX这个变量的运行结果不等于0 非0代表正在运行
   then	#那么
     echo -en " Nginx is running！"	#就输出Nginx is running 信息；
   else		#否则启动NGINX
     echo "正在重启nginx"
     systemctl restart nginx
	 NGX_RESTART=`netstat -anput | grep nginx | wc -l`	 
	if [ "$NGX_RESTART" -ne 0 ] ;then
	TG_MESSAGE="检测到$SERVER_NAME Nginx 停止运行，已于 $DA 重启成功"
	TG_BOT
	elif [ "$NGX_RESTART" = 0 ] ;then
	TG_MESSAGE="检测到$SERVER_NAME Nginx 停止运行，于 $DA 尝试重启但未成功，请进行人工检查"
	TG_BOT
	else
	TG_MESSAGE="检测到Nginx停止运行，于 $DA 尝试重启时出现未知错误，请进行人工检查"
	TG_BOT	
	fi	 
fi
}
function gost_status() {
if [ "$GOST" -ne 0 ]		#$GOST 这个变量的运行结果不等于0 非0代表正在运行
   then	#那么
     echo -en " GOST is running！"	#输出 GOST is running 信息；
   else		#否则启动gost
     echo "正在重启 gost"
     systemctl restart gost
	 GOST_RESTART=`netstat -anput | grep gost | wc -l`	 
	if [ "$GOST_RESTART" != 0 ] ;then
	TG_MESSAGE="检测到$SERVER_NAME GOST 停止运行，已于 $DA 重启成功"
	TG_BOT
	elif [ "$GOST_RESTART" = 0 ] ;then
	TG_MESSAGE="检测到$SERVER_NAME GOST 停止运行，于 $DA 尝试重启但未成功，请进行人工检查"
	TG_BOT
	else
	TG_MESSAGE="GOST，于 $DA 尝试重启时出现未知错误，请进行人工检查"
	TG_BOT	
	fi	 
fi
}
function vnetc_status() {
if [ "$VNETC" -ne 0 ]		#$VNETC 这个变量的运行结果不等于0 非0代表正在运行
   then	#那么
     echo -en " VNETC is running！"	#输出 VNETC is running 信息；
   else		#否则启动 VNETC
     echo "正在重启 VNETC"
     systemctl restart vnetc
	 VNETC_RESTART=`netstat -anput | grep client | wc -l`	 
	if [ "$VNETC_RESTART" != 0 ] ;then
	TG_MESSAGE="检测到$SERVER_NAME vnetc 停止运行，已于 $DA 重启成功"
	TG_BOT
	elif [ "$GOST_RESTART" = 0 ] ;then
	TG_MESSAGE="检测到$SERVER_NAME vnetc 停止运行，于 $DA 尝试重启但未成功，请进行人工检查"
	TG_BOT
	else
	TG_MESSAGE="vnetc，于 $DA 尝试重启时出现未知错误，请进行人工检查"
	TG_BOT	
	fi	 
fi
}
nginx_status
gost_status
vnetc_status
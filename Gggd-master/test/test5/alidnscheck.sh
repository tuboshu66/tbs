#检测方式：curl 国内机器出口地址，如果返回 Bad Request 则正常
#因azhk检测方式特殊，ct备用暂时直接切cu
#定义探针函数
DA=`date "+%Y-%m-%d %H:%M:%S"`   #标准的时间输出
check_logs_file="/root/alidns_check"
#定义
cu_zhuzhou="116.163.10.131"  #填入株洲检测IP
cu_zhuzhou_id="21365271413065728"  #填入该解析的ID
cu_changzhou="112.82.144.173"  #填入常州检测IP
cu_changzhou_id="703642261516879872"  #填入该解析的ID
cu_backup_id="" #cu备选线路
ct_shbgp=`ping sh3589.518999.xyz -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'`  #动态域名获取IP
ct_shbgp_id="703954779439251456"
ct_azure=""
ct_azure_id=""
ct_backup_id="712684558951352320" #ct备选线路
function check_zhuzhou(){
#定义函数，修改这里即可
cn_host=$cu_zhuzhou
cn_host_id=$cu_zhuzhou_id
cn_host_name="株洲"
cn_host_local="$check_logs_file/zhuzhou_status"
#判断是否正常
check_status
}
function check_changzhou(){
#定义函数，修改这里即可
cn_host=$cu_changzhou
cn_host_id=$cu_changzhou_id
cn_host_name="常州"
cn_host_local="$check_logs_file/changzhou_status"
#判断是否正常
check_status
}
function check_shbgp(){
#定义函数，修改这里即可
cn_host=$ct_shbgp
cn_host_id=$ct_shbgp_id
cn_host_name="上海BGP"
cn_host_local="$check_logs_file/shbgp_status"
#判断是否正常
check_status
}
#检测地址和判断节点状态-该项目被引用
function check_status() {
#检测地址
cn_host1=`curl --connect-timeout 2 -m 4 $cn_host:16617`
cn_host2=`curl --connect-timeout 2 -m 4 $cn_host:16618`
cn_host3=`curl --connect-timeout 2 -m 4 $cn_host:23315`
cn_host4=`curl --connect-timeout 2 -m 4 $cn_host:22286`
#判断是否正常
if [[ $cn_host1 == "Bad Request" ]] || [[ $cn_host2 == "Bad Request" ]] || [[ $cn_host3 == "Bad Request" ]] || [[ $cn_host4 == "Bad Request" ]]; then 
echo "节点正常"
cn_host_status="enable"
else
echo "节点异常"
cn_host_status="disable"
fi
#根据检测结果启用/暂停解析，并留有本地记录
cn_host_status_local=`sed -n '1p' $cn_host_local`
if [[ $cn_host_status == "enable" ]] && [[ $cn_host_status_local != "enable" ]] ; then
    echo "启动$cn_host_name解析"
    aldns enable $cn_host_id
    TG_MESSAGE=" $cn_host_name检测正常，已于 $DA 启用解析"
    TG_BOT	
    echo $cn_host_status> $cn_host_local
elif [[ $cn_host_status == "disable" ]] && [[ $cn_host_status_local != "disable" ]] ; then
    echo "停用$cn_host_name解析"
    aldns disable $cn_host_id
    TG_MESSAGE="[ ! ] $cn_host_name检测异常，已于 $DA 停用解析"
    TG_BOT	
    echo $cn_host_status> $cn_host_local
#这里是本地与远端文件相同的情况，则不做操作
elif [[ $cn_host_status == $cn_host_status_local ]] ; then
    echo "节点状态无变化，解析未作改动"
else
    echo "$cn_host_name解析出现未知错误"
    TG_MESSAGE="$cn_host_name解析出现未知错误,请尽快检查"
    TG_BOT
fi
}
#TG通知部分，定义TG_MESSAGE后调用
function TG_BOT() {
export TGSEND_TOKEN=""
export TGSEND_CHATID=""
curl -s -k "https://thingproxy.freeboard.io/fetch/https://api.telegram.org/bot$TGSEND_TOKEN/sendMessage" \
    --data-urlencode "chat_id=$TGSEND_CHATID" \
    --data-urlencode "text=$TG_MESSAGE" \
    > /dev/null &
}
function install(){
	if [[ ! -d "$check_logs_file" ]];then
		mkdir $check_logs_file
	elif [[ ! -f "/usr/bin/aldns" ]];then
		wget https://ghproxy.net/https://raw.githubusercontent.com/iscoconut/alidns-bash/master/aldns.sh -O /usr/bin/aldns
		chmod +x /usr/bin/aldns
		
	fi
}
install
check_zhuzhou
check_changzhou
cn_zhuzhou_status=`sed -n '1p' $check_logs_file/zhuzhou_status`
cn_changzhou_status=`sed -n '1p' $check_logs_file/changzhou_status`
if [[ $cn_zhuzhou_status != "enable" ]] && [[ $cn_changzhou_status != "enable" ]] ;then
    echo "常州线路与株洲线路均异常，无备选路线，魔戒CU可能已瘫痪，请立即处理"
    TG_MESSAGE="[ ! ] 常州线路与株洲线路均异常，无备选路线，魔戒CU可能已瘫痪，请立即处理"
    TG_BOT	
fi
#CT线路，上海BGP-备用1azhk-备用2cu
check_shbgp
cn_shbgp_status=`sed -n '1p' $check_logs_file/shbgp_status`
ct_backup_status=`sed -n '1p' $check_logs_file/ct_backup_status`
ct_backup_local="$check_logs_file/ct_backup_status"
if [[ $cn_shbgp_status != "enable" ]] && [[ $ct_backup_status != "enable" ]] ;then
    aldns enable $ct_backup_id
    echo "enable"> $ct_backup_local
    echo "$cn_host_name于 $DA 异常，已切换至备选CU"
    TG_MESSAGE="[ ! ] $cn_host_name于 $DA 异常，已切换至备选CU"
    TG_BOT
elif [[ $cn_shbgp_status == "enable" ]] && [[ $ct_backup_status == "enable" ]] ;then	
    aldns disable $ct_backup_id
    echo "disable"> $ct_backup_local
    echo "$cn_host_name于 $DA 恢复可用，已切换回主线路"
    TG_MESSAGE="[ ! ] $cn_host_name于 $DA 恢复可用，已切换回主线路"
    TG_BOT
elif [[ $cn_shbgp_status != $ct_backup_status ]] ;then	
    echo "$cn_host_name 当前状态未发生变化"
fi
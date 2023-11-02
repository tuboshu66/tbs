#!/bin/bash
#颜色文字
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
#开放防火墙
function install_iptables(){
systemctl stop firewalld
systemctl mask firewalld
yum install -y iptables
yum install iptables-services -y
iptables -F
iptables -P INPUT ACCEPT
iptables -X
service iptables save
}
#安装XrayR-企鹅配置
function install_xrayr_dns() {
#预设DNS解锁地址
	if [[ $dns_nf == "jp" ]]; then
		dns_nf="34.97.174.245"			
	elif [[ $dns_nf == "sg" ]]; then
		dns_nf="149.129.56.249"	
	elif [[ $dns_nf == "us" ]]; then
		dns_nf="49.51.178.84"
	elif [[ $dns_nf == "uk" ]]; then
		dns_nf="161.35.161.202"
	elif [[ $dns_nf == "fr" ]]; then
		dns_nf="109.238.14.142"
	elif [[ $dns_nf == "kr" ]]; then
		dns_nf="61.111.129.138"
	elif [[ $dns_nf == "hk" ]]; then
		dns_nf="47.240.40.111"
	elif [[ $dns_nf == "tw" ]]; then
		dns_nf="34.81.172.137"
	elif [[ $dns_nf == "" ]]; then
		dns_nf="down"
    fi
#判断主程序是否开启dns解锁
if [[ $dns_nf == "down" ]]; then
node_dns_path="# ./dns.json"
else
node_dns_path="/etc/XrayR/dns.json"
echo "{
    \"servers\": [
      \"localhost\", 
      {
        \"address\": \"$dns_nf\", 
        \"port\": 53,
        \"domains\": [
          \"geosite:netflix\" 
        ]
      }
    ]
  }" >/etc/XrayR/dns.json
fi
echo "Log:
  Level: none # Log level: none, error, warning, info, debug
  AccessPath: # ./access.Log
  ErrorPath: # ./error.log
DnsConfigPath: $node_dns_path
ConnetionConfig:
  Handshake: 4 # Handshake time limit, Second
  ConnIdle: 30 # Connection idle time limit, Second
  UplinkOnly: 2 # Time limit when the connection downstream is closed, Second
  DownlinkOnly: 4 # Time limit when the connection is closed after the uplink is closed, Second
  BufferSize: 64 # The internal cache size of each connection, kB
Nodes:" >/etc/XrayR/config.yml
}
function install_xrayr() {
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
install_xrayr_dns
}
function install_nameserver() {
#设置dns为谷歌和cf
echo "nameserver 8.8.8.8
nameserver 1.1.1.1">/etc/resolv.conf
}
function install_xrayr_node() {
    echo && echo -e "  节点快速对接--XrayR
  节点快速对接，支持设置DNS解锁
  DNS解锁支持预设BGP.SH地址输入：sg/jp/kr/us/uk/fr/tw/hk
  可以同时对接多个网站
  重置配置在节点对接时候输入rm
 ————————————" 
    read -erp " 回车开始运行:" Confirm
	if [[ $Confirm == "" ]]; then
    echo "判断是否已经安装XrayR"
	fi
	#此处读取root目录下的 .xrayr_node文件=1判断是否安装
	Install_status=`sed -n '1p' /root/.xrayr_node`
if [[ $Install_status != "1" ]]; then
	read -erp " 当前系统未识别的XrayR主程序，是否安装（Y/n）:" Install_status_Yn
	  if [[ $Install_status_Yn == "Y" ]] || [[ $Install_status_Yn == "y" ]]; then
	  read -erp " 如果主程序启用DNS解锁，请输入DNS解锁地址(回车跳过则主程序无DNS解锁):" dns_nf
	  read -erp " 是否修改系统DNS为8.8.8.8,如果是Linode等IPv6机器请务必修改（默认Y）:" Install_DNS_NAME
	    if [[ $Install_status_Yn == "Y" ]] || [[ $Install_status_Yn == "y" ]] || [[ $Install_status_Yn == "" ]]; then
		    echo "设置DNS为8.8.8.8/1.1.1.1"
			install_nameserver
	    else 
		echo "DNS不做修改，如果对接出错请手动修改"
		fi
	  install_iptables
	  install_xrayr
	  echo "1">/root/.xrayr_node
	  elif  [[ $Install_status_Yn == "N" ]] || [[ $Install_status_Yn == "n" ]]; then
	  echo "当前取消安装，写入已安装方便下次识别"
	  echo "1">/root/.xrayr_node
	  fi
elif [[ $Install_status == "1" ]]; then
echo "当前已安装主程序，请直接对接节点"
fi
	read -erp " 现在开始对接节点(pg|dog|cv|fq|tbs|hx|rm|dns):" node_web
	if [[ $node_web == "pg" ]]; then
    node_web="pengui.xyz"
	node_type="V2ray"
	node_panel="V2board"
	node_key="www_pengui_ml123"
    elif [[ $node_web == "dog" ]]; then
	node_web="www.freedog.pw"
	node_type="V2ray"
	node_panel="SSpanel"
	node_key="qingchengss"
    elif [[ $node_web == "cv" ]]; then
	node_web="cv2.xyz"
	node_type="V2ray"
	node_panel="SSpanel"
	node_key="mycheapv2ray"
    elif [[ $node_web == "fq" ]]; then
	node_web="fanqie.cyou"
	node_type="V2ray"
	node_panel="SSpanel"
	node_key="kjyzwj806674037"
    elif [[ $node_web == "tbs" ]]; then
	node_web="tuboshu.live"
	node_type="V2ray"
	node_panel="SSpanel"
	node_key="TuboTuboShu"
    elif [[ $node_web == "hx" ]]; then
	node_web="huixing.online"
	node_type="V2ray"
	node_panel="SSpanel"
	node_key="comethuixing"
	elif [[ $node_web == "rm" ]]; then
	echo "[!!!] 危险警告，这是一个重要操作"
	read -erp "这将删除全部节点对接信息，请确认（Y/n 默认N）" node_rm
        if [[ $node_rm == "Y" ]] || [[ $node_rm == "y" ]] ; then
		read -erp " 您已决定重置配置信息，请输入DNS解锁地址(回车跳过):" dns_nf
		install_xrayr_dns
		else 
		echo "您已取消操作"
		fi
		exit 0;
	elif [[ $node_web == "dns" ]]; then
	echo "您将修改系统DNS，可以解决因DNS发送IPv6导致对接失败，尤其是Linode"
	read -erp "需要您确认执行该操作（Y/n 默认Y）" node_DNS
        if [[ $node_DNS == "Y" ]] || [[ $node_DNS == "y" ]] || [[ $node_DNS == "" ]] ; then
		echo "设置成功，将自动重启节点"
		xrayr restart
		else 
		echo "您已取消操作"
		fi
		exit 0;
    else
    echo "您输入的信息不正确，脚本将重新执行"
	install_xrayr_node
    fi
    read -erp " 请输入节点ID:" node_id
    read -erp " 该节点是否启用DNS解锁，请确保主程序已启用解锁（Y/n 默认N）:" node_dns_nf
#判断是否开启节点dns解锁
if [[ $node_dns_nf == "Y" ]] || [[ $node_dns_nf == "y" ]]; then
node_dns_type="AsIs"
node_dns_enable="false"
else
node_dns_type="UseIP"
node_dns_enable="true"
fi

#开始编写配置文件
    echo "  -
    PanelType: \"$node_panel\" # Panel type: SSpanel, V2board, PMpanel, , Proxypanel
    ApiConfig:
      ApiHost: \"https://$node_web/\"
      ApiKey: \"$node_key\"
      NodeID: $node_id  #这是节点ID
      NodeType: $node_type # Node type: V2ray, Shadowsocks, Trojan, Shadowsocks-Plugin
      Timeout: 30 # Timeout for the api request
      EnableVless: false # Enable Vless for V2ray Type
      EnableXTLS: false # Enable XTLS for V2ray and Trojan
      SpeedLimit: 0 # Mbps, Local settings will replace remote settings, 0 means disable
      DeviceLimit: 0 # Local settings will replace remote settings, 0 means disable
      RuleListPath: # ./rulelist Path to local rulelist file
    ControllerConfig:
      ListenIP: 0.0.0.0 # IP address you want to listen
      SendIP: 0.0.0.0 # IP address you want to send pacakage
      UpdatePeriodic: 60 # Time to update the nodeinfo, how many sec.
      EnableDNS: $node_dns_enable # Use custom DNS config, Please ensure that you set the dns.json well
      DNSType: $node_dns_type # AsIs, UseIP, UseIPv4, UseIPv6, DNS strategy
      EnableProxyProtocol: false # Only works for WebSocket and TCP
      EnableFallback: false # Only support for Trojan and Vless
      FallBackConfigs:  # Support multiple fallbacks
        -
          SNI: # TLS SNI(Server Name Indication), Empty for any
          Path: # HTTP PATH, Empty for any
          Dest: 80 # Required, Destination of fallback, check https://xtls.github.io/config/fallback/ for details.
          ProxyProtocolVer: 0 # Send PROXY protocol version, 0 for dsable
      CertConfig:
        CertMode: dns # Option about how to get certificate: none, file, http, dns. Choose \"none\" will forcedly disable the tls config.
        CertDomain: \"node1.test.com\" # Domain to cert
        CertFile: ./cert/node1.test.com.cert # Provided if the CertMode is file
        KeyFile: ./cert/node1.test.com.key
        Provider: alidns # DNS cert provider, Get the full support list here: https://go-acme.github.io/lego/dns/
        Email: test@me.com
        DNSEnv: # DNS ENV option used by DNS provider
          ALICLOUD_ACCESS_KEY: aaa
          ALICLOUD_SECRET_KEY: bbb" >>/etc/XrayR/config.yml
xrayr restart
echo "对接完成"
}
install_xrayr_node
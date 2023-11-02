## cnsync功能说明

经过多次更新，cnsync不再是一个简单的同步程序

功能列表：

1.手动同步 cnsync vnet|brook|gost|nginx|all

2.自动同步 cnsync cron|cn80|gkd

3.守护程序(探针)<sup id="a1">[[1]](#f1)</sup> cnsync status   

4.通过TG机器人发送消息

5.自动升级<sup id="a2">[[2]](#f2)</sup> cnsync update

6.一键添加监控任务 cnsync addcron

<br>

<span id="f1">注释1: [^](#a1)</span>使用探针时，发送消息可定义机器名称 

    echo "机器名称">/root/.status_name


## 快速部署-在国内机器和月抛机器上进行快速部署

**安装cnsync（一键同步Brook/VNET/GOST）**

    rm -rf /usr/bin/cnsync ; wget --no-check-certificate https://ghproxy.net/https://raw.githubusercontent.com/gao1354184430/Gggd/master/test/test5/cnsync -O /usr/bin/cnsync ; chmod +x /usr/bin/cnsync ; cnsync addcron

同步使用

    cnsync cron

**安装haproxy（电信10000-40000端口转发）**

    rm -rf /root/haproxy.sh  ; wget --no-check-certificate https://ghproxy.net/https://raw.githubusercontent.com/gao1354184430/Gggd/master/test/test5/haproxy.sh -O /root/haproxy.sh ; chmod +x /root/haproxy.sh ; /root/haproxy.sh
	
	同步使用 

    /root/haproxy.sh sync

**国外/月抛安装（一键安装Docker/VNET/GOST）**

    yum -y install wget ; rm -rf /root/node_install ; wget --no-check-certificate https://raw.githubusercontent.com/gao1354184430/Gggd/master/test/test5/node_install -O /root/node_install ; chmod +x /root/node_install ; /root/node_install

**国内机器安装（一键安装Nginx/VNET/GOST/Brook）**

    yum -y install wget ; rm -rf /root/node_install ; wget --no-check-certificate https://ghproxy.net/https://raw.githubusercontent.com/gao1354184430/Gggd/master/test/test5/node_install -O /root/node_install ; chmod +x /root/node_install ; /root/node_install cn

**补丁脚本（清理日志，关闭80/443，修复vnet搭配nginx故障）**

    rm -rf /root/patch.sh ; wget --no-check-certificate https://ghproxy.net/https://raw.githubusercontent.com/gao1354184430/Gggd/master/test/test5/patch.sh -O /root/patch.sh ; chmod +x /root/patch.sh ; /root/patch.sh

**部分网站实现一键对接（基于XrayR）**

    yum -y install wget ; rm -rf /root/node_install ; wget --no-check-certificate https://ghproxy.net/https://raw.githubusercontent.com/gao1354184430/Gggd/master/test/test5/node_install -O /root/node_install ; chmod +x /root/node_install ; /root/node_install pengui

**升级脚本** <span id="f2">注释2: [^](#a2)</span>改动cnsync之外的文件时，我们需要手动升级

    rm -rf /root/update.sh ; wget --no-check-certificate https://ghproxy.net/https://raw.githubusercontent.com/gao1354184430/Gggd/master/test/test5/update.sh -O /root/update.sh ; chmod +x /root/update.sh ; /root/update.sh


## 测试NETFLIX播放

	rm -rf /root/netflix.sh ; wget https://raw.githubusercontent.com/gao1354184430/Gggd/master/test/test5/netflix.sh -O /root/netflix.sh ; chmod +x /root/netflix.sh ; /root/netflix.sh


监控开关在crontab开启/关闭

    */2 * * * * cnsync cron
	0 4 * * * cnsync update
    */2 * * * * /root/haproxy.sh cron

## 配置文件对应表

**Brook**配置文件 `brook.conf`

**VNET**配置文件 `client.conf`

**GOST**配置文件 `config.json`

**HaProxy**配置文件 `haproxy.cfg`

Brook因动态IP特殊性，需手动同步

|  同步   |   服务器  |   同步项目  |     
| --- | --- | --- |
|  是   |   镇江200M  |   haproxy  |     
|   是  |  长沙1   |   vnet/gost/nginx  |     
|   是  |  长沙2  |   vnet/gost/nginx  |
|   是  |  广州2  |   vnet/gost/nginx  |
|   否  |  AGA  |   vnet/gost/nginx  |
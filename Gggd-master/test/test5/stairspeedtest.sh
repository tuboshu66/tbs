#!/bin/bash
ghproxy=https://ghproxy.net
cd /root
wget $ghproxy/https://github.com/tindy2013/stairspeedtest-reborn/releases/download/v0.7.1/stairspeedtest_reborn_linux64.tar.gz
tar zxvf stairspeedtest_reborn_linux64.tar.gz 
mv stairspeedtest /usr/local/
echo '
[Unit]
Description=StairSpeedtest.Service
After=syslog.target network.target remote-fs.target nss-lookup.target
[Service]
Type=simple
ExecStart=/usr/local/stairspeedtest/webgui.sh
Restart=always
[Install]
WantedBy=multi-user.target' >/lib/systemd/system/stairspeedtest.service
sed -i 's/export_color_style=original/export_color_style=rainbow/g' /usr/local/stairspeedtest/pref.ini
sed -i 's/export_with_maxspeed=false/export_with_maxspeed=true/g' /usr/local/stairspeedtest/pref.ini
systemctl start stairspeedtest
systemctl enable stairspeedtest
systemctl status stairspeedtest

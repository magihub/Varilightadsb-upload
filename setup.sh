#!/bin/bash

clear
echo 
echo "安装飞常准 ADS-B 客户端..."
echo "请确保您的设备中有可以正常工作的 ADS-B 程序."
echo "例如已预构建 ADS-B 映像或脚本安装的 ADS-B 程序 ."
echo "否则安装程序将设置失败!"
echo "此设置脚本依靠 Dump1090 Dump1090-fa Readsb 等解码器即可运行."
echo 
sleep 3
echo "-----------------------------------"
echo "正在检查您的设备中是否安装 ADS-B 程序"
echo "-----------------------------------"
sleep 3
if [[ -f /run/dump1090-fa/aircraft.json ]] ; then
echo "-----------------------------------"
echo "dump1090-fa正在运行，安装程序将继续运行"
echo "-----------------------------------"
elif [[ -f /run/readsb/aircraft.json ]]; then
echo "-----------------------------------"
echo "readsb正在运行，安装程序将继续运行"
echo "-----------------------------------"
elif [[ -f /run/adsbexchange-feed/aircraft.json ]]; then
echo "-----------------------------------"
echo "adsbexchange-feed正在运行，安装程序将继续运行"
echo "-----------------------------------"
elif [[ -f /run/dump1090/aircraft.json ]]; then
echo "-----------------------------------"
echo "dump1090正在运行，安装程序将继续运行"
echo "-----------------------------------"
elif [[ -f /run/dump1090-mutability/aircraft.json ]]; then
echo "-----------------------------------"
echo "dump1090-mulaility正在运行，安装程序将继续运行"
echo "-----------------------------------"
elif [[ -f /run/skyaware978/aircraft.json ]]; then
echo "-----------------------------------"
echo "skyaware978正在运行，安装程序将继续运行"
echo "-----------------------------------"
else
echo "-----------------------------------"
echo "[错误]: 在您的设备上无法找到aircraft.json！"
echo "您可能需要先安装解码器，推荐使用readsb"
echo "readsb相关信息：https://www.mengorg.cn/archives/readsb"
echo "如果您刚完成解码器的安装，建议重启设备后再次尝试！"
echo "安装时请确保SDR设备已经正确连接在设备上！"
echo "-----------------------------------"
exit 1
fi

#移除旧仓库文件
if [[ -d /root/variflight ]]; then
echo "正在清理旧仓库文件"
echo "-----------------------------------"
    rm -r /root/variflight
    rm -r /etc/profile.d/uuid.sh
    crontab -l | grep -v "/root/variflight/send_message.sh >/dev/null 2>&1" | crontab -
    if grep -q "UUID" /usr/local/share/tar1090/html/index.html; then
    sed -i -e '/你的UUID是/s/.*/<a hidden>你的UUID是：<\/a>/' /usr/local/share/tar1090/html/index.html
    fi
echo "旧仓库文件清理完成，安装继续"
echo "-----------------------------------"
fi

#克隆仓库文件
echo "正在克隆仓库文件"
echo "-----------------------------------"
git clone https://github.com/HLLF-FAN/Varilightadsb-upload.git /root/variflight
echo "-----------------------------------"
echo "仓库文件克隆完成"
echo "-----------------------------------"

#进入工作目录
cd /root/variflight

#生成UUID
echo "正在生成UUID"
echo "-----------------------------------"
sleep 3
python3 create_uuid.py
if [[ -f /root/variflight/UUID ]] ; then
echo "UUID生成完成"
echo "UUID为:"$(cat /root/variflight/UUID)
echo "-----------------------------------"
else
echo "UUID生成错误"
echo "-----------------------------------"
exit 1
fi

#正在创建定时任务
echo "正在创建定时任务"
echo "-----------------------------------"
crontab -l > mycron
echo "* * * * * /root/variflight/send_message.sh >/dev/null 2>&1" >> mycron
crontab mycron
rm mycron
sleep 3
echo "定时任务创建完成"
echo "-----------------------------------"


#创建UUID终端显示脚本
echo "正在创建UUID终端显示脚本"
echo "-----------------------------------"
mv uuid.sh /etc/profile.d/uuid.sh 
chmod +x /etc/profile.d/uuid.sh
sleep 3
echo "UUID终端显示脚本创建完成"
echo "-----------------------------------"

#更新tar1090页面UUID内容
sleep 3
echo "正在检查是否安装tar1090并添加UUID"
echo "-----------------------------------"
if grep -q "UUID" /usr/local/share/tar1090/html/index.html; then
sed -i -e "/你的UUID是/s/.*/<a>你的UUID是：$(cat \/root\/variflight\/UUID)<\/a>/" /usr/local/share/tar1090/html/index.html
sleep 3
echo "已添加UUID至tar1090web页面"
echo "-----------------------------------"  
else
sleep 3
echo "你的设备未安装tar1090跳过更新"
fi

sleep 3
echo "------------------------------------- "
echo "------------------------------------- "
echo "设备将在10s后重新启动并开始进行数据上传"
echo "UUID将会在每次连接到ssh服务时打印在终端上"
echo "请前往以下网址添加设备UUID并设置设备位置"
echo "https://flightadsb.variflight.com/share-data/script"
echo "------------------------------------- "
echo "------------------------------------- "
echo "10秒后重启设备，请勿关闭此ssh连接"
sleep 10
reboot

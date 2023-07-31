#!/bin/bash
#get the host ip and set the wsl http proxy, pip proxy
port=51837

# Path to pip.conf
pip_conf=/home/$USER/.pip/pip.conf
# Backup existing file
if [ -f "${pip_conf}.bak"  ]; then
      rm ${pip_conf}.bak
fi
cp $pip_conf ${pip_conf}.bak

# get the host ip
host_ip=$(cat /etc/resolv.conf |grep "nameserver" |cut -f 2 -d " ")
echo $host_ip

# Modify the proxy line in /home/andy/pip/pip.conf
sed -i "s|proxy=.*|proxy=http://${host_ip}:${port}|" $pip_conf
export http_proxy="socks5://${hostip}:${port}"
export https_proxy="socks5://${hostip}:${port}"
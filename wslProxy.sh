#!/bin/bash
#get the host ip and set the wsl http proxy, pip proxy
# ref: [package-manager-proxy-settings](https://github.com/comwrg/package-manager-proxy-settings)
# script url: https://github.com/Andy963/scripts/blob/master/wslProxy.sh

# your host proxy port, for example:
# if you clash, the default port is 7890
port=51837
# get the host ip
host_ip=$(cat /etc/resolv.conf | grep "nameserver" | cut -f 2 -d " ")
echo "get the host ip is :${host_ip}"

# Path to pip.conf
pip_conf=/home/$USER/.pip/pip.conf
# Backup existing file
if [ -f "${pip_conf}.bak" ]; then
  rm ${pip_conf}.bak
fi
cp $pip_conf ${pip_conf}.bak

# Modify the proxy line in /home/andy/pip/pip.conf
sed -i "s|proxy=.*|proxy=http://${host_ip}:${port}|" $pip_conf
export http_proxy="socks5://${hostip}:${port}"
export https_proxy="socks5://${hostip}:${port}"
echo "modify pip proxy success"

# apt conf
apt_conf=/etc/apt/apt.conf.d/proxy.conf
# Backup existing file
if [ -f "${apt_conf}.bak" ]; then
  rm ${apt_conf}.bak
fi
cp $apt_conf ${apt_conf}.bak
#Acquire::http::Proxy "http://127.0.0.1:8080/";
# Acquire::https::Proxy "http://127.0.0.1:8080/";
# Update the /etc/apt/apt.conf.d/proxy.conf file
echo "Acquire::http::Proxy \"http://${host_ip}:${port}\";" | sudo tee $apt_conf >/dev/null
echo "Acquire::https::Proxy \"http://${host_ip}:${port}\";" | sudo tee -a $apt_conf >/dev/null
echo "modify apt proxy success"

# wget
weget_conf=~/.wgetrc
if [ -f "${weget_conf}" ]; then
  rm ${weget_conf}.bak
fi
cp ${weget_conf} ${weget_conf}.bak
echo "use_proxy=yes" | sudo tee $weget_conf >/dev/null
echo "http_proxy=\"http://${host_ip}:${port}\";" | sudo tee -a $weget_conf >/dev/null
echo "https_proxy=\"http://${host_ip}:${port}\";" | sudo tee -a $weget_conf >/dev/null
echo "modify wget proxy success"

# curl
curl_conf=~/.curlrc
if [ -f "${curl_conf}" ]; then
  rm ${curl_conf}.bak
fi
cp ${curl_conf} ${curl_conf}.bak
echo "socks5=\"${host_ip}:${port}\"" | sudo tee $curl_conf >/dev/null
echo "modify curl proxy success"

# git
git_conf=~/.ssh/config
if [ -f "${git_conf}" ]; then
  rm ${git_conf}.bak
fi
cp ${git_conf} ${git_conf}.bak
echo "ProxyCommand nc --proxy-type socks5 --proxy ${host}:${port} %h %p" | sudo tee -a $git_conf >/dev/null
echo "modify git proxy success"

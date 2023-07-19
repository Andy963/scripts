#!/bin/bash
logPath="/var/log/auth.log"
tmpPath="/tmp/black"
cat $logPath | awk '/Invalid/{print $(NF-2)}' | sort | uniq -c | awk '{print $2"="$1}' >>$tmpPath
cat $logPath | awk '/Failed/{print $(NF-3)}' | sort | uniq -c | awk '{print $2"="$1;}' >>$tmpPath
cat $logPath | awk '/Connection closed/{print $( NF-3)}' | sort | uniq -c | awk '{print $2"="$1;
}' >>$tmpPath

list=$(cat /tmp/black)
#cat /tmp/black >> /opt/scripts/banIp.log

# fill you own ip here, it can be a list of ips
allowedips=()

for i in $list; do
  if ! [[ "$i" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
    continue
  fi
  ip=$(echo "$i" | awk -F= '{print $1}')
  num=$(echo "$i" | awk -F= '{print $2}')
  # 失败超过3次，加入黑名单
  if [[ $num -gt 3 ]]; then
    found=false
    for j in "${allowedips[@]}"; do
      if [[ $ip == $j ]]; then
        found=true
        break
      fi
    done
    # not in the allowed list
    if [ "$found" = false ]; then
      # check if the ip is already in the blacklist
      grep "$ip" /etc/hosts.deny &>/dev/null
      if [[ $? -gt 0 ]]; then
        echo "ALL:$ip" >>/etc/hosts.deny
      fi
      # 将每个ip尝试次数保存在banIp.log中
      grep "$ip" /opt/scripts/banIp.log &>/dev/null
      if [[ $? -gt 0 ]]; then
        echo "$ip=$num" >>/opt/scripts/banIp.log
      else
        sed -n 's/$ip=\d+/$ip=$num/' /opt/scripts/banIp.log
      fi
      # not in the allowed list and failed more than 3 times, add to the iptables
      # check if the ip is already in the iptables
      iptables -C INPUT -s "$ip/32" -j DROP &>/dev/null

      if [[ $? -ne 0 ]]; then
        iptables -I INPUT -s "$ip/32" -j DROP
      fi
    fi
  fi
done

cp /dev/null /tmp/black

exit

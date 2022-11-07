#!/bin/bash
cat /var/log/auth.log | awk '/Invalid/{print $(NF-2)}' | sort | uniq -c | awk '{print $2"="$1}' > /tmp/black 
list=`cat /tmp/black`
#cat /tmp/black >> /opt/scripts/banIp.log

for i in $list; do
	ip=`echo $i | awk -F= '{print $1}'`
	num=`echo $i | awk -F= '{print $2}'`
	# 失败超过3次，加入黑名单
	if [[ $num -gt 3 ]]; then
		grep $ip /etc/hosts.deny &> /dev/null
		if [[ $? -gt 0 ]]; then
			echo "sshd:$ip" >> /etc/hosts.deny
		fi
		# 将每个ip尝试次数保存在banIp.log中
		grep $ip /opt/scripts/banIp.log &> /dev/null
		if [[ $? -gt 0 ]]; then
			echo "$ip=$num" >> /opt/scripts/banIp.log 
		else
			sed -n 's/$ip=\d+/$ip=$num/' /opt/scripts/banIp.log
		fi
	fi
done

cp /dev/null /tmp/black

exit

cat /var/log/auth.log | awk '/Invalid/{print $(NF-2)}' | sort | uniq -c | awk '{print $2"="$1}' > /tmp/black
list=`cat /tmp/black`

for i in $list; do
	ip=`echo $i | awk -F= '{print $1}'`
	num=`echo $i | awk -F= '{print $2}'`
	if [[ $num -gt 5 ]]; then
		grep $ip /etc/hosts.deny &> /dev/null
		if [[ $? -gt 0 ]]; then
			echo "sshd:$ip" >> /etc/hosts.deny
		fi
	fi
done

cp /dev/null /tmp/black

exit
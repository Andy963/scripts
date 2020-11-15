#!/bin/sh  
time=$(date "+%Y-%m-%d %H:%M:%S")
echo "---------------------------------------------------------------------------"
echo "----- start clean docker containers logs on ${time} ----"  
  
logs=$(find /var/lib/docker/containers -name '*-json.log' )  
for log in $logs  
        do  
                du -h  $log
                cat /dev/null > $log  
        done  

echo "--- end clean docker containers logs on ${time}   -----"

#0 2 * * * /usr/bin/sh /opt/scripts/dockerClean.sh >> /opt/scripts/dockerClean.log
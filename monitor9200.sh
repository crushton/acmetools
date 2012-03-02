#!/usr/bin/env bash

ip=<ip address>
community=<community string>
sleeptime=5

NUM=1

echo -e "\t\t\tDate\tUptime\t\tCPU\tMEM\tSess\tCPS"

while (true)
do
date=$(date)
cpu=$(snmpwalk -OqUv -v2c -c $community $ip 1.3.6.1.4.1.9148.3.3.1.7.2.1.3 | sort -n -r -k2 | head -1)
mem=$(snmpwalk -OqUv -v2c -c $community $ip 1.3.6.1.4.1.9148.3.3.1.7.2.1.6 | sort -n -r -k2 | head -1)
sess=$(snmpget -OqUv -v2c -c $community $ip 1.3.6.1.4.1.9148.3.2.1.1.5.0)
cps=$(snmpget -OqUv -v2c -c $community $ip 1.3.6.1.4.1.9148.3.2.1.1.6.0)
uptime=$(snmpget -OqUv -v2c -c $community $ip 1.3.6.1.2.1.1.3.0)

echo -e "$date\t$uptime\t$cpu%\t$mem%\t$sess\t$cps"
sleep $sleeptime
if [ $NUM -lt 60 ];
then
  let NUM=$NUM+1
else
  NUM=1
  echo -e "\t\t\tDate\tUptime\t\tCPU\tMEM\tSess\tCPS"
fi
done

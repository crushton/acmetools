#!/usr/bin/env bash
###
# Copyright (c) 2012, Chris Rushton
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
##

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

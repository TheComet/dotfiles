#!/bin/sh

for netif in $(cat /proc/net/dev | sed -ne 's/:.*//p')
do
	echo New MAC for ${netif}
	ifconfig ${netif} down && macchanger -br ${netif} 2>&1 > /dev/null || echo FAILD
	ifconfig ${netif} down && macchanger -br ${netif} 2>&1 > /dev/null || echo FAILD
	ifconfig ${netif} down && macchanger -br ${netif} 2>&1 > /dev/null || echo FAILD
	ifconfig ${netif} up
done

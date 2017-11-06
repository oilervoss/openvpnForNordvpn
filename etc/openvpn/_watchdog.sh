#!/bin/sh
# /etc/openvpn/reconnect.sh

sleep 60
logger "Watchdog started"
TESTE=0 
while true; do
	
	if [ -e /etc/openvpn/_openvpn.lock ] && ( ! route|grep tun0); then
		logger "Watchdog: tun0 is down. Restarting openvpn process"
		/etc/init.d/openvpn restart
		sleep 7
		/etc/openvpn/_firewall.sh
		let TESTE+=10
	fi

        p=$(ping -c 10 8.8.8.8 | sed -n 's/.*transmitted, \+\([0-9]\+\).*/\1/p')

	if [ "$p" -eq 0 ] || [ "$p" = "" ]; then
		/etc/init.d/firewall restart
		let TESTE+=10
	        p=$(ping -c 10 8.8.8.8 | sed -n 's/.*transmitted, \+\([0-9]\+\).*/\1/p')
		logger "Watchdog: 8.8.8.8 could'nt be pingged. Firewall process was restarted. New ping had $p0% of sucess"
	fi
	
	if [ "$p" -eq 0 ] || [ "$p" = ""]; then
		/etc/init.d/network restart
		let TESTE+=10
		logger "Watchdog: Restarting network process"
	else
		TESTE=0
	fi

	sleep 60
	sleep $TESTE

	if [ "$TESTE" -ge 120 ]; then
		TESTE=0
		logger "Watchdog: all conections failed four times. Sleeping 10 minutes"
		sleep 600
	fi

done


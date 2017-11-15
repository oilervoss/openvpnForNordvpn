#!/bin/sh
# /etc/openvpn/watchdog.sh

sleep 60
logger "Watchdog started"
CYCLE=0 

PPING(){
	local PP=$(ping -c 10 8.8.8.8 | sed -n 's/.*transmitted, \+\([0-9]\+\).*/\1/p')
	if [ "$PP" -eq 0 ] || [ "$PP" = "" ]; then
		PP=0
	fi
	echo $PP
}

RESTART(){
	
	if [ $1 -ge 3 ]; then
		/etc/init.d/network restart
		sleep 15
	fi
	
	if [ $1 -ge 2 ] && [ -e /etc/openvpn/openvpn.lock ]; then
		/etc/init.d/openvpn restart
		sleep 5
	fi
	
	if [ $1 -ge 1 ]; then
		/etc/init.d/firewall restart
	fi
	
	let CYCLE+=20
}


while true; do
	
    P=$(PPING)

	if [ $P -eq 0 ]; then
		logger "Watchdog: 8.8.8.8 couldn't be pinged. Restarting network process." 
		RESTART 3
	    P=$(PPING)
		logger "Watchdog: New ping had ${P}0% of sucess"
	fi

	if [ -e /etc/openvpn/openvpn.lock ]; then
		if ( ! route|grep tun0) || ( ! ip a s tun0 up ); then
			logger "Watchdog: tun0 is down. Restarting openvpn process"
			RESTART 2
		else
			CYCLE=0
		fi
	else
		if [ $P -ne 0 ]; then
			CYCLE=0
		fi
	fi
	
	sleep 120
	sleep $CYCLE

	if [ "$CYCLE" -ge 120 ]; then
		CYCLE=0
		logger "Watchdog: Connections failed six times. Sleeping 10 minutes"
		sleep 600
	fi

done

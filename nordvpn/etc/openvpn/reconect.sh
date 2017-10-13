#!/bin/sh
# /etc/openvpn/reconnect.sh

while sleep 50; do
        t=$(ping -c 10 8.8.8.8 | sed -n 's/.*transmitted, \+\([0-9]\+\).*/\1/p')
	
	if [ "$t" -ne 0 ] && ( ip a s tun0 up ); then
		exit 0
	fi

        if [ "$t" -eq 0 ] && ( ! ip a s tun0 up ); then
                /etc/init.d/openvpn restart
	fi

done

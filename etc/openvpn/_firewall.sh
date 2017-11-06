#!/bin/sh
#

if (route|grep tun0); then
	touch /etc/openvpn/_openvpn.lock
	if (iptables -C forwarding_rule -j REJECT); then
		iptables -D forwarding_rule -j REJECT
	fi
fi

if [ -e /etc/openvpn/_openvpn.lock ] && (! route|grep tun0) && (! iptables -C forwarding_rule -j REJECT); then
        iptables -I forwarding_rule -j REJECT
fi

exit 0

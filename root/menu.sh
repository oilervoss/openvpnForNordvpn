#!/bin/sh
#

ckser() {
	if ( pgrep $1 1>/dev/null 2>&1 ); then
		echo true;
	else
		echo false;
	fi
}

while true; do
	ARIA=$( ckser aria2c )
	TRANSMISSION=$( ckser transmission-daemon )
	OPENVPN=$( ckser openvpn )
	CHOICE=""	
	clear
	if $ARIA; then 
		echo -ne "[*]=<A>ria stop\n"; 
	else 
		echo -ne "[ ]=<A>ria start\n"; 
	fi

	if $TRANSMISSION; then 
		echo -ne "[*]=<T>ransmission stop\n"; 
	else 
		echo -ne "[ ]=<T>ransmission start\n"; 
	fi

	if $OPENVPN; then 
		echo -ne "[*]=<O>penVPN Restart\n"; 
	else 
		echo -ne "[ ]=<O>penVPN Start\n"; 
	fi
		
		echo -ne "    <C>hange Nordvpn: [";

	ls -l /etc/openvpn/nordvpn.ovpn | sed -r 's:^.+-> .*nordvpn/(.+).ovpn$:\1]:'
	if $OPENVPN; then
		echo -ne "    <K>ill Openvpn\n";
	fi
	echo -ne "    <Q>uit to shell\n"

	read -t 3 -n 1 CHOICE

	case $CHOICE in
		A|a )
			if $ARIA; then
				/etc/init.d/aria2 stop
			else
				/etc/init.d/aria2 start
			fi
			;;
		T|t )
			if $TRANSMISSION; then
				/etc/init.d/transmission stop 
			else
				/etc/init.d/transmission start
			fi
			;;
		O|o )
			if $OPENVPN; then
				/etc/init.d/openvpn stop
				sleep 1
			fi
			/etc/init.d/openvpn start
			;;
		K|k )
			rm -f /etc/openvpn/openvpn.lock
			/etc/init.d/openvpn stop
			;;
		C|c )
			/root/nordvpn.sh
			;;
		Q|q )
			clear
			exit 0
			;;
	esac
done
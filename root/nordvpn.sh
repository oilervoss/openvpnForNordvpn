#!/bin/sh
#
# This script provides a interface to choose a nordvpn server

FILES=$(ls -1 /etc/openvpn/*.ovpn|sed -n 's/^\/etc\/openvpn\/\(.*\)\.ovpn$/\1/p')

while true; do
	echo
	echo "Select the country (2 small letters) or:"
	echo "dd = Double tunnel"
	echo "tt = Tor tunnel"
	echo "oo = Onion tunnel"
	read -n 2 -p "Choose: " COUNTRY
	echo
	case $COUNTRY in
		dd)
			$COUNTRY=Double
			;;
		tt)
			$COUNTRY=Tor 
			;;
		oo)		
			$COUNTRY=Onion 
			;;
	esac
	
	CFILES=$(echo "$FILES"|sed -n "/$COUNTRY/p")
	
	if [ ! -z "$CFILES" ]; then
		echo I found it
		break
	fi

	echo I didnt find it

done
	echo 
	echo "$CFILES"|sed "s/$COUNTRY\(.*\)_\(tcp|udp\)/\1/"|tr '\n' '\t'
	read -p "Choose a server: " SERVER
	echo
	read -n 1 -p "Choose tcp or udp: " PROTOCOL
	echo	
	if [ "$PROTOCOL" = "t" ] || [ "$PROTOCOL" = "T" ]; then
		PROTOCOL=tcp
	else
		PROTOCOL=udp
	fi
	SFILES=$(echo "$CFILES"|sed -n "/$COUNTRY$SERVER\_$PROTOCOL/p")
	if [ -z "$SFILES" ]; then
		echo I didnt find any server
		exit 1
	fi

	T=$(echo $SFILES|sed '1d')

	if [ ! -z "$T" ]; then
		echo I found more than one server
		exit 1
	fi
	echo
	echo Connecting to tunnel: $SFILES
	ln -sf /etc/openvpn/$SFILES.ovpn /etc/openvpn/_nordvpn.ovpn
	ls -l /etc/openvpn/_n*

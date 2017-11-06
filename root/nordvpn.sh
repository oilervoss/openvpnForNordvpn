#!/bin/sh
#
# This script provides a interface to choose a nordvpn server

echo -ne "\e[36mThat is the current setting:  \e[1m"
ls -l /etc/openvpn/_nordvpn.ovpn|sed 's/.*\/etc\/openvpn\/\(.*\)\.ovpn$/\1/'
echo -e "\e[0m"

FILES=$(ls -1 /etc/openvpn/*.ovpn|sed -n 's/^\/etc\/openvpn\/\(.*\)\.ovpn$/\1/p')

while true; do
	echo
	echo "Select a country (2 small letters) or:"
	echo "xd = Double tunnel"
	echo "xt = Tor tunnel"
	echo "xo = Onion tunnel"
	echo " = Start vpn with current setting"
	
	ls /etc/openvpn/ | sed -n 's/\(^..\).*/\1/;/^_.*/!p;/^x.*/!p'|uniq|sort|tr '\n' ' '
#sed -n '/^[a-zA-Z]\{2\}[0-9]\{1,3\}.*/p;/^x.*/p'

	echo
	read -n 2 -p "Choose: " COUNTRY
	echo
	
	if [ "$COUNTRY" = "" ]; then 
		break
	fi
	
	case $COUNTRY in
		xd)
			$COUNTRY=xDouble
			;;
		xt)
			$COUNTRY=xTor 
			;;
		xo)		
			$COUNTRY=xOnion 
			;;
	esac
	
	CFILES=$(echo "$FILES"|sed -n "/$COUNTRY/p")
	
	if [ ! -z "$CFILES" ]; then
		echo -e "\e[32mI found it.\e[0m"
		break
	fi

	echo -e "\e[1m\e[31mI didn't find it.\e[0m"

done

if [ "$COUNTRY" != "zz" ]; then
 
	echo 
	echo "$CFILES"|sed "s/$COUNTRY\(.*\)_\(tcp|udp\)/\1/"|tr '\n' '\t'
	echo
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
		echo -e "\e[1m\e[31mI didn't find any server.\e[0m"
		exit 1
	fi
	T=$(echo $SFILES|sed '1d')
	if [ ! -z "$T" ]; then
		echo -e "\e[1m\e[31mI found more than one server.\e[0m"
		exit 1
	fi
	echo
	echo -e "\e[1m\e[32mSetting to tunnel:\e[34m\e[5m $SFILES\e[0m"
	echo
	ln -sf /etc/openvpn/$SFILES.ovpn /etc/openvpn/_nordvpn.ovpn
	ls -l /etc/openvpn/_nordvpn.ovpn|sed 's/.*\(_nordvpn.*$\)/\1/'
fi

if ( pgrep openvpn 1>/dev/null 2>&1 ); then
	echo -e "\e[94mStopping old vpn.\e[0m"
	/etc/init.d/openvpn stop
fi
echo -e "\e[34m\e[5mStarting new vpn.\e[0m"
sleep 1
/etc/init.d/openvpn start



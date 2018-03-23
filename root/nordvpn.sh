#!/bin/sh
#
# This script provides a interface to choose a nordvpn server
# https://github.com/oilervoss/openvpnForNordvpn/blob/master/root/nordvpn.sh

CHOSENFILE=""

CURRENT=$( ls -l /etc/openvpn/nordvpn.ovpn  2>/dev/null | sed -nr 's:.+-> .*nordvpn/(.+)\.ovpn$:\1:p' )

if [ -z $CURRENT ]; then
        ln -sf /etc/openvpn/nordvpn.ovpn /etc/openvpn/nordvpn/us1.tcp.ovpn
        [ $? != 0 ] && exit $?
fi

echo -e "\n\e[36mThis is the current setting: \e[1m${CURRENT}\e[0m"

NORDFILES=$( find /etc/openvpn/nordvpn/*.ovpn -type f | sed -nr 's:/etc/openvpn/nordvpn/(.+)\.ovpn:\1:p' )

while [ -z "$CHOSENFILE" ]; do
        echo
        echo "Select a country (2 small letters) or:"
        echo "xd = Double tunnel"
        echo "xt = Tor tunnel"
        echo "= Start vpn with current setting"
        echo
        echo "$NORDFILES" | sed -nr -e 's:^(..).+:\1:' -e '/^x.+/ !p' | sort -u | tr '\n' ' '
        echo
        read -n 2 -p "Choose: " COUNTRY
        echo

        [ -z "$COUNTRY" ] && break

        case $COUNTRY in
                xd )
                        COUNTRY=xDouble
                        ;;
                xt )
                        COUNTRY=xTor
                        ;;
        esac

        COUNTRYFILES=$( echo "$NORDFILES" | sed -n "/^$COUNTRY/p" )

        if [ -z "$COUNTRYFILES" ]; then
                echo -e "\e[1m\e[31mI didn't find it.\e[0m"
                continue
        fi

        echo -e "\e[32mI found it.\e[0m"

        while [ -z "$CHOSENFILE" ]; do
                echo
                if [ "$COUNTRY" != "xDouble" ] && [ "$COUNTRY" != "xTor" ]; then
                        echo "$COUNTRYFILES" | sed -nr "s:^$COUNTRY(.*).(tcp|udp):\1:p" | sort -nu | tr '\n' ' '
                else
                        echo "$COUNTRYFILES" | sed -nr "s:^$COUNTRY(.*).(tcp|udp):\1:p" | sort -u
                fi
                echo
                read -p "Choose a server: " SERVER
                echo
                [ "$COUNTRY" != "xOnion" ] && read -n 1 -p "Choose tcp or udp: " PROTOCOL
                echo

                if [ "$PROTOCOL" = "t" ] || [ "$PROTOCOL" = "T" ] || [ "$COUNTRY" = "xOnion" ]; then
                        PROTOCOL=tcp
                else
                        PROTOCOL=udp
                fi

                CHOSENFILE=$(echo "$COUNTRYFILES" | sed -n "/${COUNTRY}${SERVER}.${PROTOCOL}/p")

                if [ -z "$CHOSENFILE" ]; then
                        echo -e "\e[1m\e[31mI didn't find any server.\e[0m"
                        break
                fi

                if [ ! -z $(echo $CHOSENFILE|sed '1d') ]; then
                        echo -e "\e[1m\e[31mI found more than one server.\e[0m"
                        CHOSENFILE=""
                        break
                fi

                echo
                echo -e "\e[1m\e[32mSetting to tunnel: \e[5m$CHOSENFILE\e[0m"
                echo
                ln -sf /etc/openvpn/nordvpn/$COUNTRY$SERVER.$PROTOCOL.ovpn /etc/openvpn/nordvpn.ovpn
                if [ $? -ne 0 ]; then
                        echo "Error"
                        exit $?
                fi
                ls -l /etc/openvpn/nordvpn.ovpn | sed -nr 's:.+(/etc/.+->.+):\1:p'
                break
        done

done

if ( pgrep openvpn 1>/dev/null 2>&1 ); then
        echo -e "\e[94mStopping old vpn.\e[0m"
        /etc/init.d/openvpn stop
        sleep 1
fi

echo -e "\e[34m\e[5mStarting new vpn.\e[0m"
/etc/init.d/openvpn start

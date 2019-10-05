#!/bin/sh
#

ckser() {
        if ( pgrep $1 1>/dev/null 2>&1 ); then
                echo true;
        else
                echo false;
        fi
}

thurricane() {
        ifstatus hurricane|sed -nr '/"up"/p'|sed -nr 's/.*(true|false).*/\1/p'
}

topenvpn() {
        ckser openvpn
}

while true; do

        if [ ! -z $( uci get dhcp.@dnsmasq[0].server|sed -nr 's:.*(127\.0\.0\.53).*:\1:p' ) ]; then
                DNSC=127
        else
                if [ ! -z $( uci get dhcp.@dnsmasq[0].server|sed -nr 's:.*(103\.86\.9.\.100).*:\1:p' ) ]; then
                        DNSC=86
                else
                        if [ ! -z $( uci get dhcp.@dnsmasq[0].server|sed -nr 's:.*(10\.255\.255.\.1).*:\1:p' ) ]; then
                                DNSC=84
                        else
                                DNSC=0
                        fi
                fi
        fi

        ARIA=$( ckser aria2c )
        TRANSMISSION=$( ckser transmission-daemon )
        OPENVPN=$( ckser openvpn )
        HURRICANE=$( ifstatus hurricane|sed -nr '/"up"/p'|sed -nr 's/.*(true|false).*/\1/p' )
        ZERO=$( ckser zerotier-one )
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

        if $( topenvpn ); then
                echo -ne "[*]=<O>penVPN Restart\n";
        else
                echo -ne "[ ]=<O>penVPN Start\n";
        fi

        echo -ne "    <C>hange Nordvpn: [";

        ls -l /etc/openvpn/openvpn.ovpn | sed -r 's:^.+-> .+*/(.+).ovpn$:\1]:'

        if $( topenvpn ); then
                echo -ne "    <K>ill Openvpn\n";
        fi

        echo -ne "\n"

        if [ $DNSC -eq 127 ]; then
                echo -ne "[*]=DNScrypt\n"
        else
                echo -ne "[ ]=<D>NScrypt\n"
        fi
        if [ $DNSC -eq 86 ]; then
                echo -ne "[*]=Nordvpn DNS\n"
        else
                echo -ne "[ ]=<N>ordvpn DNS\n"
        fi
        if [ $DNSC -eq 84 ]; then
                echo -ne "[*]=Windscribe DNS\n"
        else
                echo -ne "[ ]=<W>indscribe DNS\n"
        fi
        if [ $DNSC -eq 0 ]; then
                echo -ne "[*]=Regular DNS\n"
        else
                echo -ne "[ ]=<R>egular DNS\n"
        fi

        if $( thurricane ); then
                echo -ne "\n[*]=<H>urricane IPV6 stop\n"
        else
                if $( topenvpn ); then
                        echo -ne "\n[ ]=Hurricane IPV6"
                else
                        echo -ne "\n[ ]=<H>urricane IPV6 start"
                fi
        fi

        if $ZERO; then
                echo -ne "\n[*]=<Z>erotier stop\n"
        else
                echo -ne "\n[ ]=<Z>erotier start\n"
        fi

        echo -ne "\n    <Q>uit to shell\n";

        read -t 4 -n 1 CHOICE

        case $CHOICE in
                H|h ) #Hurricane interface
                        if $( thurricane ); then
                                ifdown hurricane
                        else
                                ! $( topenvpn ) && ifup hurricane
                        fi
                ;;
                R|r ) #Regular DNS
                        if [ $DNSC -ne 0 ]; then
                                uci set dhcp.@dnsmasq[0].noresolv='0'
                                uci set dhcp.@dnsmasq[0].resolvfile='/tmp/resolv.conf.auto'
                                uci delete dhcp.@dnsmasq[0].localuse
                                uci delete dhcp.@dnsmasq[0].server
                                uci add_list dhcp.@dnsmasq[0].server='1.0.0.1'
                                uci add_list dhcp.@dnsmasq[0].server='8.8.4.4'
                                uci add_list dhcp.@dnsmasq[0].server='208.67.222.222'
                                uci add_list dhcp.@dnsmasq[0].server='200.221.11.100'
                                uci add_list dhcp.@dnsmasq[0].server='2001:4860:4860::8844'
                                uci add_list dhcp.@dnsmasq[0].server='2620:119:35::35'
                                uci add_list dhcp.@dnsmasq[0].server='2606:4700:4700::1111'
                                uci commit dhcp
                                /etc/init.d/dnsmasq restart
                        fi
                ;;
                D|d ) #Dnscrypt and Kill Openvpn
                        if [ $DNSC -ne 127 ]; then
                                uci set dhcp.@dnsmasq[0].noresolv='1'
                                uci set dhcp.@dnsmasq[0].localuse='1'
                                uci delete dhcp.@dnsmasq[0].resolvfile
                                uci delete dhcp.@dnsmasq[0].server
                                uci add_list dhcp.@dnsmasq[0].server='127.0.0.53'
                                uci add_list dhcp.@dnsmasq[0].server='/checkip.amazonaws.com/1.0.0.1'
                                uci add_list dhcp.@dnsmasq[0].server='/alves.pro.br/1.0.0.1'
                                uci add_list dhcp.@dnsmasq[0].server='/tunnelbroker.net/1.0.0.1'
                                uci add_list dhcp.@dnsmasq[0].server='/he.net/1.0.0.1'
                                uci add_list dhcp.@dnsmasq[0].server='/api.cloudflare.com/1.0.0.1'
                                uci commit dhcp
                                /etc/init.d/dnsmasq restart
                        fi
                ;;
                N|n ) #Nordvpn DNS
                        if [ $DNSC -ne 86 ]; then
                                uci set dhcp.@dnsmasq[0].noresolv='0'
                                uci set dhcp.@dnsmasq[0].resolvfile='/tmp/resolv.conf.auto'
                                uci delete dhcp.@dnsmasq[0].localuse
                                uci delete dhcp.@dnsmasq[0].server
                                uci add_list dhcp.@dnsmasq[0].server='103.86.96.100'
                                uci add_list dhcp.@dnsmasq[0].server='103.86.99.100'
                                uci commit dhcp
                                /etc/init.d/dnsmasq restart
                        fi
                ;;
                W|w ) #Windscribe DNS
                        if [ $DNSC -ne 84 ]; then
                                uci set dhcp.@dnsmasq[0].noresolv='0'
                                uci set dhcp.@dnsmasq[0].resolvfile='/tmp/resolv.conf.auto'
                                uci delete dhcp.@dnsmasq[0].localuse
                                uci delete dhcp.@dnsmasq[0].server
                                uci add_list dhcp.@dnsmasq[0].server='10.255.255.1'
                                uci commit dhcp
                                /etc/init.d/dnsmasq restart
                        fi
                ;;
                O|o ) #Openvpn start
                        if $( topenvpn ); then
                                /etc/init.d/openvpn stop
                                sleep 1
                        else
                                ifdown hurricane
                                uci set dhcp.@dnsmasq[0].noresolv='0'
                                uci set dhcp.@dnsmasq[0].resolvfile='/tmp/resolv.conf.auto'
                                uci delete dhcp.@dnsmasq[0].localuse
                                uci delete dhcp.@dnsmasq[0].server
                                uci add_list dhcp.@dnsmasq[0].server='103.86.96.100'
                                uci add_list dhcp.@dnsmasq[0].server='103.86.99.100'
                                uci commit dhcp
                                /etc/init.d/dnsmasq restart
                        fi
                        /etc/init.d/openvpn start
                ;;
                K|k ) #Kill Openvpn
                        ifup hurricane
                        rm -f /etc/openvpn/openvpn.lock
                        /etc/init.d/openvpn stop
                        if [ $DNSC -ne 127 ]; then
                                uci set dhcp.@dnsmasq[0].noresolv='1'
                                uci set dhcp.@dnsmasq[0].localuse='1'
                                uci delete dhcp.@dnsmasq[0].resolvfile
                                uci delete dhcp.@dnsmasq[0].server
                                uci add_list dhcp.@dnsmasq[0].server='127.0.0.53'
                                uci add_list dhcp.@dnsmasq[0].server='/checkip.amazonaws.com/1.0.0.1'
                                uci add_list dhcp.@dnsmasq[0].server='/alves.pro.br/1.0.0.1'
                                uci add_list dhcp.@dnsmasq[0].server='/tunnelbroker.net/1.0.0.1'
                                uci add_list dhcp.@dnsmasq[0].server='/he.net/1.0.0.1'
                                uci add_list dhcp.@dnsmasq[0].server='/api.cloudflare.com/1.0.0.1'
                                uci commit dhcp
                                /etc/init.d/dnsmasq restart
                        fi
                ;;
                C|c ) #Change Openvpn and start
                        /root/nordvpn.sh

                        if $( topenvpn ); then
                                ifdown hurricane
                                uci set dhcp.@dnsmasq[0].noresolv='0'
                                uci set dhcp.@dnsmasq[0].resolvfile='/tmp/resolv.conf.auto'
                                uci delete dhcp.@dnsmasq[0].localuse
                                uci delete dhcp.@dnsmasq[0].server
                                uci add_list dhcp.@dnsmasq[0].server='103.86.96.100'
                                uci add_list dhcp.@dnsmasq[0].server='103.86.99.100'
                                uci commit dhcp
                                /etc/init.d/dnsmasq restart
                        fi


                ;;
                A|a ) #Aria
                        if $ARIA; then
                                /etc/init.d/aria2 stop
                        else
                                /etc/init.d/aria2 start
                        fi
                ;;
                T|t ) #Transmission
                        if $TRANSMISSION; then
                                /etc/init.d/transmission stop
                        else
                                /etc/init.d/transmission start
                        fi
                ;;
                Z|z ) #Zerotier
                        if $ZERO; then
                                /etc/init.d/zerotier stop
                        else
                                /etc/init.d/zerotier start
                        fi
                ;;
                Q|q ) #Quit
                        clear
                        exit 0
                ;;
        esac
done

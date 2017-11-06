#! /bin/sh
#

# This script download Nordvpn config files for Openvpn and edit them
# for being used in OpenWRT ou LEDE

REMOVE=""

ckinstall {
  echo "Checking $1"
  local t=$(opkg list-installed | cut -d ' ' -f 1 | grep "$1")
  if [ "$t" = "" ]; then
    echo "I didn't find $1. Installing."
    if [ $# -eq 2 ]; then
      REMOVE="$REMOVE $1"
    fi
    opkg install $1    
  fi
}

ckfile {
# file text
  if [ ! -e "$1" ]; then 
    touch "$1"
  fi
###?????????  

}

##### START
echo "Updating opkg"
opkg update
ckinstall unzip temp
ckinstall openvpn-openssl
ckinstall ip-full
if [ -e /etc/init.d/uhttpd ]; then
  ckinstall luci-app-openvpn
fi

# Download Nordvpn Config files
echo "If you have a slow connection, be patient."
echo "Downloading official nordvpn files."
wget -P /root "http://downloads.nordcdn.com/configs/archives/servers/ovpn.zip"
unzip -j -o /root/ovpn.zip -d /etc/openvpn/nordvpn/
rm /root/ovpn.zip


# Simplify name and content
for f in /etc/openvpn/nordvpn/*.ovpn ; do
	local nf=$(echo $f | sed -n 's/\.nordvpn\.com\././;s/\.\(tcp\|udp\)\./_\1\./;s/^\(Tor\|Onion\|Double\)\(.*\)/x\1\2/p')
	if [ "$nf" = "" -o "$nf" = "$f" ]; then continue; fi
	mv -f $f $nf
	sed -i $'/^$/d;/^#/d;/explicit-exit-notify/d;/auth-user-pass/d;/ping-restart 0/aping-exit 60\\nauth-nocache\\nauth-user-pass \/etc\/openvpn\/nordvpn-auth' $nf
done

read -p 'What is your Nordvpn username (email)? ' uservar
read -sp 'What is your Nordvpn password? ' passvar
echo "I will write them to /etc/openvpn/nordvpn-auth"
echo "Edit it if you need"

echo $uservar > /etc/openvpn/nordvpn-auth
echo $passvar >> /etc/openvpn/nordvpn-auth
chmod u=rw,go= /etc/openvpn/nordvpn-auth

wget -P /root "https://github.com/oilervoss/openwrt/raw/nordvpn/root/nordvpn.sh"
chmod u=rwx,go=r /root/nordvpn.sh
wget -P /etc/openvpn "https://github.com/oilervoss/openwrt/raw/nordvpn/etc/openvpn/watchdog.sh"
chmod ug=rwx,o=r /etc/openvpn/watchdog.sh
wget -P /etc/openvpn "https://github.com/oilervoss/openwrt/raw/nordvpn/etc/openvpn/preventleak.sh"
chmod ug=rwx,o=r /etc/openvpn/preventleak.sh
wget -P /etc/hotplug.d/iface/ "https://github.com/oilervoss/openwrt/raw/nordvpn/etc/hotplug.d/iface/99-preventleak"

ckfile /etc/rc.local "rm -f /etc/openvpn/_openvpn.lock &"
ckfile /etc/rc.local "/etc/openvpn/_watchdog &"
ckfile /etc/firewall.user "/etc/openvpn/preventleak.sh &"

## search /etc/config/firewall for option network 'ovpn'
uci set firewall.openvpn =			zone
uci set firewall.openvpn.forward =	'REJECT'
uci set firewall.openvpn.network =	'ovpn'
uci set firewall.openvpn.output =	'ACCEPT'
uci set firewall.openvpn.name =		'ovpnfw'
uci set firewall.openvpn.masq =		'1'
uci set firewall.openvpn.mtu_fix =	'1'
uci set firewall.openvpn.input =	'REJECT'

## search /etc/config/firewall for the name of lan
LAN=`uci get firewall.@forwarding[-1].src`
uci add firewall forwarding
uci set firewall.@forwarding[-1].src =	$LAN
uci set firewall.@forwarding[-1].dest =	ovpnfw

## search /etc/config/network for the name of interface
uci set network.ovpn =			interface
uci set network.ovpn.proto =	none
uci set network.ovpn.ifname =	tun0

## search /etc/config/openvpn for nordvpn.ovpn
uci set openvpn.Nordvpn =			'openvpn'
uci set openvpn.Nordvpn.config =	'/etc/openvpn/nordvpn.ovpn'
uci set openvpn.Nordvpn.enabled	=	1

ln -sf /etc/openvpn/nordvpn/ddddddddd.ovpn /etc/openvpn/nordvpn.ovpn

if [ "$REMOVE" != "" ]; then
  opkg --autoremove remove $REMOVE
fi


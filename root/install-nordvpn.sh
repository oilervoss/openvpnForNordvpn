#! /bin/sh
#

# This script download Nordvpn config files for Openvpn and edit them
# to be used in OpenWRT ou LEDE

REMOVEOPKGTEMP=""  #list of opkg file names to be removed at the end f=' ' 
REMOVEOPKGFAIL=""  #list of opkg file names to be removed in case of fail f=' ' 
REMOVEFILES="" #list of file names to be removed in case of fail f='\n'
REMOVEBAK=""   #list of file names to be restored from backup in case of fail f='\n'

# It'll check if a opkg is installed already.
Ninstall { #opkgfilename #[temp] 
  echo "Checking $1"
  local t=$(opkg list-installed | cut -d ' ' -f 1 | grep "$1")
  if [ "$t" = "" ]; then
    echo "I didn't find $1. Installing."
    if [ "$2" = "temp" ]; then
      REMOVETEMP="$REMOVEOPKGTEMP $1"
	else
	  REMOVE="$REMOVEOPKGFAIL $1"
    fi
    opkg install $1
  fi
}

# It'll remove a list of opkg f=' '
Nremoveopkg { #listOfOpkg
  if [ ! -z "$1" ]; then
    opkg --autoremove remove $1
  fi
}

# It'll remove a list of files f='\n'
Nremovefiles { #listOfFiles #[bak]
  if [ ! -z "$1" ]; then
    for $RF in $1; do
      if [ "$2" = "bak" ]; then
	    mv $RF.backup $RF
	  else
	    rm $RF
	  fi
    done
  fi
}

Nfile {
# file text
  if [ ! -e "$1" ]; then
    touch "$1"
  fi
###?????????

}

# It'll check if it'd ocurred a error, abort and clean installation
Nfail {
  local F=$1
  if [ ! $F ]; then
    echo -e "Something went wrong. It'll abort.\nCleaning files."
	Nremoveopkg $REMOVETEMP
	Nremoveopkg $REMOVEFAIL
	Nremovefiles $REMOVEBAK bak
	Nremovefiles $REMOVEFILES
	echo -e "Removing Nordvpn OVPN files. It'll take some time. Be patient"
	rm -rf /etc/openvpn/nordvpn
	exit $F
  fi
}

# It'll download source files and add to remove list
Ndownload { #path #url-nofile #filename
  if [ -e $1/$3 ]
    mv $1/$3 $1/$3.backup
	REMOVEBAK="$REMOVEBAK\n$1/$3"
  else
    REMOVEFILES="$REMOVEFILES\n$1/$3"
  fi
  cd $1
  curl -O --url "$2$3"
  chmod u+x "$1/$3"
}

##### START
echo "Updating opkg"
opkg update
Nfail $?
Ninstall unzip temp
Ninstall curl temp
Ninstall openvpn-openssl
Ninstall ip-full
if [ -e /etc/init.d/uhttpd ]; then
  Ninstall luci-app-openvpn
fi

# Download Nordvpn Config files
echo "If you have a slow connection, be patient."
echo "Downloading official nordvpn files."
cd /root ; curl -O --url "http://downloads.nordcdn.com/configs/archives/servers/ovpn.zip"
ckfail $?
unzip -j -o /root/ovpn.zip -d /etc/openvpn/nordvpn/
ckfail $?
rm /root/ovpn.zip


# Simplify name and content
for F in /etc/openvpn/nordvpn/*.ovpn ; do

	#ls -1 /etc/openvpn/nordvpn/*.ovpn | sed -r 's:/etc/openvpn/nordvpn/(.*)\.nordvpn\.com\.(tcp|udp)\.ovpn:\1.\2:' -e 's:(.*)-tor([0-9])\.(tcp|udp):xTor\2-\1.\3:' -e 's:([a-z]{2}-[a-z]{2})([0-9])\.(tcp|udp):xDouble\2-\1.\3:' -e 's:_:-:g'

  NF=$( echo $F | sed -r \
	-e 's:/etc/openvpn/nordvpn/(.+)\.nordvpn\.com\.(tcp|udp)\.ovpn:\1.\2:' \
	-e 's:_:-:g' \
	-e 's:(.+)-tor([0-9])\.(tcp|udp):xTor\2_\1.\3:' \
	-e 's:([a-z]{2}-[a-z]{2})([0-9])\.(tcp|udp):xDouble\2_\1.\3:' )

  if [ -z "$NF" ]; then 
    continue; 
  fi
  echo "Editing $NF"
  if [ "$NF" != "$F" ]; then
    mv -f $F /etc/openvpn/nordvpn/$NF.ovpn
  fi
  sed -i \
	-e '/^$/d' \
	-e '/^#/d' \
	-e '/explicit-exit-notify/d' \
	-e '/auth-user-pass/d' \
	-e $'/ping-restart 0/aping-exit 60\\\nauth-nocache\\\nauth-user-pass \/etc\/openvpn\/nordvpn-auth' \
	"/etc/openvpn/nordvpn/$NF.ovpn"
done

read -p 'What is your Nordvpn username (email)? ' uservar
read -sp 'What is your Nordvpn password? ' passvar
echo "I will write them to /etc/openvpn/nordvpn-auth"
echo "Edit it if you need"

echo $uservar > /etc/openvpn/nordvpn-auth
echo $passvar >> /etc/openvpn/nordvpn-auth
chmod u=rw,go= /etc/openvpn/nordvpn-auth


cd /etc/openvpn
Ndownload "/etc/openvpn" "https://github.com/oilervoss/openwrt/raw/nordvpn/etc/openvpn/" watchdog.sh
Ndownload "/etc/openvpn" "https://github.com/oilervoss/openwrt/raw/nordvpn/etc/openvpn/" preventleak.sh
Ndownload "/etc/hotplug.d/iface" "https://github.com/oilervoss/openwrt/raw/nordvpn/etc/hotplug.d/iface/" 99-preventleak
Ndownload "/root" "https://github.com/oilervoss/openwrt/raw/nordvpn/root/" nordvpn.sh

ckfile /etc/rc.local "rm -f /etc/openvpn/openvpn.lock &"
ckfile /etc/rc.local "/etc/openvpn/watchdog &"
ckfile /etc/firewall.user "/etc/openvpn/preventleak.sh &"

## search /etc/config/firewall for option network 'ovpn'
uci set firewall.openvpn 			= zone
uci set firewall.openvpn.forward 	= 'REJECT'
uci set firewall.openvpn.network 	= 'ovpn'
uci set firewall.openvpn.output 	= 'ACCEPT'
uci set firewall.openvpn.name 		= 'ovpnfw'
uci set firewall.openvpn.masq 		= '1'
uci set firewall.openvpn.mtu_fix 	= '1'
uci set firewall.openvpn.input 		= 'REJECT'

## search /etc/config/firewall for the name of lan
LAN=`uci get firewall.@forwarding[-1].src`
uci add firewall forwarding
uci set firewall.@forwarding[-1].src =	$LAN
uci set firewall.@forwarding[-1].dest =	ovpnfw

## search /etc/config/network for the name of interface
uci set network.ovpn 		= interface
uci set network.ovpn.proto 	= none
uci set network.ovpn.ifname	= tun0

## search /etc/config/openvpn for nordvpn.ovpn
uci set openvpn.Nordvpn 		= 'openvpn'
uci set openvpn.Nordvpn.config 	= '/etc/openvpn/nordvpn.ovpn'
uci set openvpn.Nordvpn.enabled	= 1

ln -sf /etc/openvpn/nordvpn/us111.tcp.ovpn /etc/openvpn/nordvpn.ovpn

Nremoveopkg $REMOVETEMP
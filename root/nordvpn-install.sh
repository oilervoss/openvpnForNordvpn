#! /bin/sh
#

# This script download Nordvpn config files for Openvpn and edit them
# for being used in OpenWRT ou LEDE

ckinstall {
  local t=$(opkg list-installed | grep "$1 ")
  if [ "$t" -eq "" ]; then
    if [ ! -e /var/opkg-lists/ ] && [ ! -e /etc/opkg-lists/ ]; then
      opkg update
    fi
    opkg install $1
  fi
}

# Check and install packages
ckinstall unzip
ckinstall openvpn-openssl
ckinstall ip-full
if [ -e /etc/init.d/uhttpd ]; then
  ckinstall luci-app-openvpn
fi

# Download Nordvpn Config files
echo "If you have a slow connection, be patient."
wget -P /root "http://downloads.nordcdn.com/configs/archives/servers/ovpn.zip"
unzip -j -o /root/ovpn.zip -d /etc/openvpn/nordvpn
rm /root/ovpn.zip

# Simplify name and content
for f in /etc/openvpn/*.ovpn ; do
  local nf=`echo $f | sed -n 's/\.nordvpn\.com\././;s/\.\(tcp\|udp\)\./_\1\./p'`
  mv $f $nf
  sed -i $'/^$/d;/^#/d;/explicit-exit-notify/d;/auth-user-pass/d;/ping-restart 0/aping-exit 60\\nauth-nocache\\nauth-user-pass \/etc\/openvpn\/_auth-nordvpn' $nf
done

read -p 'What is your Nordvpn username (email)? ' uservar
read -sp 'What is your Nordvpn password? ' passvar
echo "I will write them to /etc/openvpn/_auth-nordvpn"
echo "Edit it if you need"

echo $uservar > /etc/openvpn/_auth-nordvpn
echo $passvar >> /etc/openvpn/_auth-nordvpn

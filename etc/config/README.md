Append the file contents and restart services
```
/etc/init.d/network restart
/etc/init.d/firewall restart
```

or use UCI to configure. Pay attention to change **'lanfw'** to the name of your _LAN Firewall Zone_

```
uci set network.ovpn=interface
uci set network.ovpn.proto='none'
uci set network.ovpn.ifname='tun0'
uci commit network

uci add firewall zone
uci set firewall.@zone[-1].name='ovpnfw'
uci set firewall.@zone[-1].input='REJECT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'
uci set firewall.@zone[-1].masq='1'
uci set firewall.@zone[-1].mtu_fix='1'
uci add_list firewall.@zone[-1].network='ovpn'
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='lanfw'
uci set firewall.@forwarding[-1].dest='ovpnfw'
uci commit firewall

```

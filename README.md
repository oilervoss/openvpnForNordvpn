## Custom scripts for Nordvpn at OpenWRT

[NordVPN](https://ref.nordvpn.com/?id=69780735): High-level VPN service 

[OpenWRT](http://www.openwrt.org): OpenWrt is a highly extensible GNU/Linux distribution for embedded devices (typically wireless routers). Unlike many other distributions for these routers, OpenWrt is built from the ground up to be a full-featured, easily modifiable operating system for your router. In practice, this means that you can have all the features you need with none of the bloat, powered by a Linux kernel that's more recent than most other distributions.

Based on: https://nordvpn.com/tutorials/openwrt/openvpn/

You need to install OpenWRT packages only once
```
opkg update
opkg install openvpn-openssl
opkg install ip-full
opkg install luci-app-openvpn
```

*Since I'm currently using a very slow and unstable 3g internet provider, I don't keep the vpn on all the time, hence I made an optimized Watchdog that will check and restore the vpn only after its first use since last boot. I just keep the openvpn service disable so that it will be started only by demand.* I also doesn't keep aria2 or transmission services running all the time in hope to save some electricity.

***The script also works perfectly if you have the openvpn service enabled in order to keep you vpn lasting.***

### Description of included files

Files|Usage|Description
---|---|---
/root/install-nordvpn.sh|On command line|**Work in progress** Script planned to install NordVPN official files and my custom scripts
/root/nordvpn.sh|On command line|This script provide a User Interface to change between the thousands of NordVPN files.
/root/menu.sh|On command line|This script provide a User Interface to most common OpenWRT/LEDE operations as start/stop the services OpenVPN, Aria2, Transmission
/etc/openvpn/nordvpn-auth|Configuration|It contains two lines: email and password for authentication on NordVPN service.
/etc/openvpn/preventleak.sh|On demand|This script is called by the auxiliary scripts to check if the VPN has got down. If yes, it blocks the packet forwarding in the firewall.
/etc/openvpn/watchdog.sh|On demand|This script is called on boot by rc.local and will monitor the connection through ping every two minutes. If something goes wrong, it restarts firewall or network service. It also checks if the VPN tunnel is down, preventing leaking, and monitors it, restarting it. It will be kept running. You can check its actions on logread.
/etc/openvpn/nordvpn.ovpn|Symbolic link|It will be referred by /etc/config/openvpn. It points the current NordVPN's server configuration file in /etc/openvpn/nordvpn/
/etc/openvpn/nordvpn/\*|Folder|This folder contains all NordVPN's server configuration files.
/etc/openvpn/openvpn.lock|Lock file|It will indicate that a VPN connection was started after boot.
/etc/firewall.user|On demand|This script is called every time the firewall conditions changes. It will call the preventleak.sh script in order to check if the VPN still is up.
/etc/rc.local|On demand|This script is run on boot. It will clean any /etc/openvpn/openvpn.lock, any blocked firewall forwarding and it will run /etc/openvpn/watchdog.sh
/etc/config/openvpn|Configuration|Part of the full file where is the modifications needed to use openvpn
/etc/config/firewall|Configuration|Part of the full file where is the modifications needed to use openvpn
/etc/config/network|Configuration|Part of the full file where is the modifications needed to use openvpn
/etc/hotplug.d/iface/99-preventleak|On demand|This is script is called every time some network interface changes. It will call the preventleak.sh script in order to check if the VPN still is up. 

---
## NordVPN PROMO CODE
### High-quality VPN service with a huge discount
- No Logs Policy
- P2P Allowed
- Onion Over VPN
- Unlimited Bandwidth
- Double Encryption
---

Use my referral link (https://ref.nordvpn.com/?id=69780735) and one of the promo codes:
- [**2YSpecial2017**](https://ref.nordvpn.com/?id=69780735) for 2 year plan **$3.29** per month
- [**70off**](https://ref.nordvpn.com/?id=69780735) for 1 year plan **$4.00** per month
----

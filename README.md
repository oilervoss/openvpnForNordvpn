## Custom scripts for Nordvpn at OpenWRT

[NordVPN](https://ref.nordvpn.com/?id=69780735): High level VPN service 

[OpenWRT](http://www.openwrt.org): OpenWrt is a highly extensible GNU/Linux distribution for embedded devices (typically wireless routers). Unlike many other distributions for these routers, OpenWrt is built from the ground up to be a full-featured, easily modifiable operating system for your router. In practice, this means that you can have all the features you need with none of the bloat, powered by a Linux kernel that's more recent than most other distributions.

Based on: https://nordvpn.com/tutorials/openwrt/openvpn/

You need to install OpenWRT packages only once
```
opkg update
opkg install openvpn-openssl
opkg install ip-full
opkg install install luci-app-openvpn
```

*Since I'm currently using a very slow and instable 3g internet provider, I don't keep the vpn on all the time, hence I made a otimized Watchdog that will check and restore the vpn only after its first use since last boot. I just keep the openvpn service disable so that it will started only by demand.*

**The script work perfectly too if you have the openvpn service enabled in order to keep you vpn lasting.**



---
## NordVPN PROMO CODE
### High quality VPN service with a huge discount
- No Logs Policy
- P2P Allowed
- Onion Over VPN
- Unlimited Bandwidth
- Double Encryption
---

Use my referal link (https://ref.nordvpn.com/?id=69780735) and one of the promo codes:
- [**2YSpecial2017**](https://ref.nordvpn.com/?id=69780735) for 2 year plan **$3.29** per month
- [**70off**](https://ref.nordvpn.com/?id=69780735) for 1 year plan **$4.00** per month
----

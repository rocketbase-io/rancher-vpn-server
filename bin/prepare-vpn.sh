#!/bin/bash

[ "$DEBUG" == "1" ] && set -x

set -e

# Create OpenVPN server config
cat > $VPN_PATH/server.conf <<EOF
port 1194
proto udp
dev tun
keepalive 10 120
comp-lzo

user nobody
group nogroup

verb 1

persist-key
persist-tun

ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
tls-auth ta.key 0

server 10.8.0.0 255.255.255.0

push "route ${ROUTED_NETWORK_CIDR} ${ROUTED_NETWORK_MASK}"
push "dhcp-option DNS 10.8.0.1" 
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DOMAIN rancher.internal"
EOF

# Enable tcp forwarding and add iptables MASQUERADE rule
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -F
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE

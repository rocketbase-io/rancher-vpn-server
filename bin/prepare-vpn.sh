#!/bin/bash

[ "$DEBUG" == "1" ] && set -x

set -e


# Update openvpn route
#RANCHER_NETWORK_CIDR=`ip addr show dev eth0 | grep inet | grep 10.42 | awk '{print $2}' | xargs -i ipcalc -n {} | grep Network | awk '{print $2}' | awk -F/ '{print $1}'`
#RANCHER_NETWORK_MASK=`ip addr show dev eth0 | grep inet | grep 10.42 | awk '{print $2}' | xargs -i ipcalc -n {} | grep Netmask | awk '{print $2}'`

# Create OpenVPN server config
cat > $VPN_PATH/server.conf <<EOF
port 1194
proto tcp
dev tun
keepalive 10 120
comp-lzo

user nobody
group nogroup

log-append /var/log/openvpn.log
verb 3

persist-key
persist-tun

ca easy-rsa/keys/ca.crt
cert easy-rsa/keys/server.crt
key easy-rsa/keys/server.key
dh easy-rsa/keys/dh2048.pem
tls-auth easy-rsa/keys/ta.key 0

server 10.8.0.0 255.255.255.0
duplicate-cn

push "route ${ROUTED_NETWORK_CIDR} ${ROUTED_NETWORK_MASK}"
push "route 169.254.169.250 255.255.255.255"
push "dhcp-option DNS 169.254.169.250" 
EOF

# Enable tcp forwarding and add iptables MASQUERADE rule
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -F
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE

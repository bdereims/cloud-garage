#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#start  node w/ custos 

iptables -P INPUT   ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT  ACCEPT

iptables -F
iptables -X
iptables -Z

iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

sed -i -e 's/.*exit 142" \(.*$\)/\1/' /root/.ssh/authorized_keys

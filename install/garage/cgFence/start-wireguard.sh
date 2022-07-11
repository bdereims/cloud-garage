#!/bin/bash
#bdereims@gmail.com | cloud-garage project
# start wireguard

modprobe wireguard
ip link add wg0 type wireguard
ip link set mtu 1380 dev wg0
ip a add 10.255.255.2/24 dev wg0
wg setconf wg0 /etc/wireguard/wireguard.conf
ip link set up dev wg0

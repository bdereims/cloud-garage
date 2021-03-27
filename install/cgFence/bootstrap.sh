#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#configure cgFence after cloning grease-monkey template

sed -i 's/grease-monkey/cgFence/g' /etc/hosts
sed -i 's/grease-monkey/cgFence/g' /etc/hostname

apt update && apt -y upgrade
apt install -y curl jq dnsmasq bird ntp wireguard

systemctl disable bird6 ; systemctl stop bird6

./generate-motd.sh > /etc/motd

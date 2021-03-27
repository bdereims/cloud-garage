#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#configure cgFence after cloning grease-monkey template

apt update && apt -y upgrade
apt install -y curl jq dnsmasq bird ntp

systemctl disable bird6


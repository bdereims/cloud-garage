#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#configure as cgFenceHub a cfFence to run service discovery 

apt update && apt -y upgrade
apt install -y etcd-server etcd-client 

systemctl stop etcd
rm -fr /var/lib/etcd/default/*
./evaluate.sh etcd.service > /lib/systemd/system/etcd.service
systemctl daemon-reload
systemctl restart etcd

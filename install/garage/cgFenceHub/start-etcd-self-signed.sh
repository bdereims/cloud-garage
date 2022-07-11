#!/bin/bash
#bdereims@gmail.com | cloud-garage project
# start etcd with dns discovery

DOMAIN=$(domainname)
IP=$(ip a | grep inet | grep brd | cut -d' ' -f6 | cut -d'/' -f1)

etcd --name  ${HOSTNAME} \
  --auto-tls --peer-auto-tls \
  --initial-advertise-peer-urls=https://${IP}:2380 --listen-peer-urls=https://${IP}:2380 \
  --discovery https://discovery.etcd.io/b83ea32d1b384b226145a81ebbde7417

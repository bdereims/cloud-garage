#!/bin/bash
#bdereims@gmail.com | cloud-garage project
# start etcd with dns discovery

DOMAIN=$(domainname)

etcd --name ${HOSTNAME} \
--discovery-srv ${DOMAIN} \
--initial-advertise-peer-urls http://${HOSTNAME}.${DOMAIN}:2380 \
--initial-cluster-token cg-etcd-cluster \
--initial-cluster-state new \
--advertise-client-urls http://${HOSTNAME}.${DOMAIN}:2379 \
--listen-client-urls http://0.0.0.0:2379 \
--listen-peer-urls http://0.0.0.0:2380

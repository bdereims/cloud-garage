#!/bin/bash 
#bdereims@gmail.com | cloud-garage project
#install kubespray

CLUSTER_NAME=bcp

cd ~/kubespray

cp -rfp inventory/sample inventory/mycluster

NODES=$( cat /etc/hosts | sed -e "/node.*p$/d" | grep "node-" | sort -k2 | awk '{print $1" "}' |tr -d '\n' )
declare -a IPS=( ${NODES} )
CONFIG_FILE=inventory/${CLUSTER_NAME}/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

#edit hosts
#ansible-playbook -i inventory/${CLUSTER_NAME}/hosts.yml -u root -b -v --private-key=~/.ssh/id_rsa cluster.yml

#!/bin/bash 
#bdereims@gmail.com | cloud-garage project
#reboot all nodes

for NODE in $( cat /etc/hosts | sed -e "/node.*p$/d" | grep "node-" | sort -k2 | awk '{print $1" "}' ); do echo $NODE; ssh root@${NODE} reboot ; done

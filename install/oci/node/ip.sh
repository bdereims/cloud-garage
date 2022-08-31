#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#retrieve ip

NIC=$( ip -br -4 a sh | grep $( ip route  | grep default | awk '{print $9}' ) | awk '{print $1}' )
ip addr show ${NIC} | grep inet | head -n 1 | sed -e "s/\/.*$//" -e "s/^.*inet //"

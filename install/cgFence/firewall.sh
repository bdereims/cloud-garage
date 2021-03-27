#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#restore firewall rules

/sbin/iptables-restore < /etc/iptables.rules

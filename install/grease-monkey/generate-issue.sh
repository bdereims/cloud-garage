#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#generate /etc/issue from /etc/motd

cat /etc/motd | sed -e 's/\\/\\\\/g'

#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#extemd root fs in order to more room
#$1 : the new device, ex: /dev/sdb

pvcreate ${1}
vgextend grease-monkey-vg ${1}
lvextend -l +100%FREE /dev/grease-monkey-vg/root
resize2fs /dev/grease-monkey-vg/root

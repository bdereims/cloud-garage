#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#extemd root fs in order to more room
#$1 : the new device, ex: /dev/sdb

VG=$(vgs --noheadings | awk '{print $1}')
LV=$(lvdisplay -C -o "lv_path" --noheadings | sed "s/ //g")

pvcreate ${1}
vgextend ${VG} ${1}
lvextend -l +100%FREE ${LV}
resize2fs ${LV}

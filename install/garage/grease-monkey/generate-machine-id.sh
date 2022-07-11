#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#generate a new machine-id 

rm -f /etc/machine-id /var/lib/dbus/machine-id
dbus-uuidgen --ensure=/etc/machine-id
dbus-uuidgen --ensure

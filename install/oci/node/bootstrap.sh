#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#configure just after creation of node

#set -eux
#set -o pipefail

# copy startup script, always good to have this
cp ip.sh ~/.
cp startup.sh ~/.
cp startup.service /etc/systemd/system/.
systemctl daemon-reload
systemctl enable startup.service
systemctl start startup.service

exit 0

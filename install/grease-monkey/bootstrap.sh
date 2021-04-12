#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#configure after creation of grease-monkey template
#launch under root account

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt update && apt -y upgrade
apt install -y vim 

mkdir ~/.ssh
cp authorized_keys ~/.ssh/.
cp sshd_config /etc/ssh/.
systemctl restart sshd

cp bashrc ~/.bashrc
cp vimrc ~/.vimrc
cp blacklist.conf /etc/modprobe.d/.

cp extend-rootfs.sh generate-machine-id.sh ~/.

cp sysctl.conf /etc/.
sysctl -p

./generate-motd.sh > /etc/motd
cp /dev/null /etc/issue
cp /dev/null /etc/issue.net

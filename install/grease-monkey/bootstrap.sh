#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#configure just after creation of grease-monkey template, validated for debian stable
#launch under root account

echo "=== Bootstaping grease-nomkey jumpox"
echo ""

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt update && apt -y upgrade
apt install -y vim sudo open-vm-tools ntpd

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

usermod -a -G sudo grease-monkey
sed -i "s/%sudo\tALL=(ALL:ALL) ALL/%sudo\tALL=(ALL:ALL) NOPASSWD:ALL/" /etc/sudoers

cp startup.sh ~/.
cp startup.service /etc/systemctl/system/.
systemctl daemon-reload
systemctl enable startup.service

#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#configure just after creation of sixty9 template, validated for debian stable
#launch under root account

echo "=== Bootstaping sixty9 jumpox"
echo ""

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt update && apt -y upgrade
apt install -y vim sudo open-vm-tools ntp bash-completion sudo

mkdir ~/.ssh
cp authorized_keys ~/.ssh/.
cp sshd_config /etc/ssh/.
systemctl restart sshd

cp bashrc ~/.bashrc
cat vimrc >> /etc/vim/vimrc.local 
cp blacklist.conf /etc/modprobe.d/.

cp proxy.sh ~/.
cp docker.service-proxy ~/.

cp extend-rootfs.sh generate-machine-id.sh ~/.

cp sysctl.conf /etc/.
sysctl -p

./generate-motd.sh > /etc/motd
cp /dev/null /etc/issue
cp /dev/null /etc/issue.net

usermod -a -G sudo sixty9
sed -i "s/%sudo\tALL=(ALL:ALL) ALL/%sudo\tALL=(ALL:ALL) NOPASSWD:ALL/" /etc/sudoers

cp startup.sh ~/.
cp startup.service /etc/systemd/system/.
systemctl daemon-reload
systemctl enable startup.service

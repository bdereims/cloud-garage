#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#configure just after creation of sixty9 template, validated for ubuntu lts
#launch with root account

#set -eux
#set -o pipefail

ANSIBLE=${ANSIBLE:-"NO"}
DOCKER=${DOCKER:-"NO"} 

COMPOSE_VERSION=1.29.0
HELM_VERSION=3.5.3
KUBECTL_VERSION=1.20.0
SHIP_VERSION=0.40.0
STERN_VERSION=1.11.0
GOVC_VERSION=0.23.0
COMPLETIONS=/etc/bash_completion.d
VMUSER=sixty9

# needs root
echo "=== Bootstaping sixty9 jumpox"
echo ""

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# create user if does not exist
useradd -m -s /bin/bash ${VMUSER} 
usermod -a -G sudo ${VMUSER}
cp -R /home/ubuntu/.??* /home/${VMUSER}
chown -R ${VMUSER}:${VMUSER} /home/${VMUSER}

# only for ubuntu
lsb_release -d | grep Ubuntu || exit 1

# install some tools from repo
apt update && apt -y upgrade
apt install -y vim sudo ntp bash-completion sudo jq curl sshpass unzip bash-completion tmux iputils-ping wireguard dnsmasq

# optional if running withio vmware
#apt install -y open-vm-tools

# copy wiregaurd files
cp wireguard-start.sh ~/.
PRIVATE_KEY=$( wg genkey )
cat wireguard.conf | sed -e "s/###PRIVATE-KEY###/${PRIVATE_KEY}/" > /etc/wireguard.conf

# configure dnsmasq
cp dnsmasq.conf /etc/.
systemctl stop systemd-resolved
systemctl disable systemd-resolved
systemctl enable dnsmasq
systemctl start dnsmasq

# disable fancy login message 
chmod -x /etc/update-motd.d/*

# update ssh key and configure sshd with socks tunnel
mkdir ~/.ssh
echo "y" | ssh-keygen -q -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""
cp authorized_keys ~/.ssh/.
mkdir -p /home/${VMUSER}/.ssh
cp authorized_keys /home/${VMUSER}/.ssh/.
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chown -R ${VMUSER}:${VMUSER} /home/${VMUSER}/.ssh
cp sshd_config /etc/ssh/.
systemctl restart sshd

# bash and vim seetings
cp bashrc ~/.bashrc
cat vimrc >> /etc/vim/vimrc.local 

# block some modules
cp blacklist.conf /etc/modprobe.d/.

# copy some useful scripts in /root
cp proxy.sh ~/.
cp docker.service-proxy ~/.
cp extend-rootfs.sh generate-machine-id.sh ~/.

# optimize kernel
cp sysctl.conf /etc/.
sysctl -p

# generate message of the day and welcoming message with sixty9 banner
./generate-motd.sh > /etc/motd
cp /dev/null /etc/issue
cp /dev/null /etc/issue.net

# this user can become root
usermod -a -G sudo sixty9
sed -i "s/%sudo\tALL=(ALL:ALL) ALL/%sudo\tALL=(ALL:ALL) NOPASSWD:ALL/" /etc/sudoers

# copy startup script, always good to have this
cp startup.sh ~/.
cp startup.service /etc/systemd/system/.
systemctl daemon-reload
systemctl enable startup.service

# install kubecnetes tools
curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x /usr/local/bin/kubectl
install kubectl /usr/bin

curl -L -o /usr/local/bin/stern https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64 && chmod +x /usr/local/bin/stern

curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar zx -C /usr/local/bin --strip-components=1 linux-amd64/helm

curl -L https://github.com/replicatedhq/ship/releases/download/v${SHIP_VERSION}/ship_${SHIP_VERSION}_linux_amd64.tar.gz | tar zx -C /usr/local/bin ship

curl -L https://github.com/static-linux/static-binaries-i386/raw/4266c69990ae11315bad7b928f85b6c8e605ef14/httping-2.4.tar.gz | tar zx -C /usr/local/bin --strip-components=1 httping-2.4/httping


git clone https://github.com/ahmetb/kubectx \
&& cd kubectx \
&& mv kubectx /usr/local/bin/kctx \
&& mv kubens /usr/local/bin/kns \
&& mv completion/*.bash $COMPLETIONS \
&& cd .. \
&& rm -rf kubectx

git clone https://github.com/jonmosco/kube-ps1 \
&& cp kube-ps1/kube-ps1.sh /etc/profile.d/ \
&& rm -rf kube-ps1

# bash complettion
stern --completion bash > $COMPLETIONS/stern.bash
kubectl completion bash > $COMPLETIONS/kubectl.bash
helm completion bash > $COMPLETIONS/helm.bash

# install govc to imteropeate with vsphere
curl -L  https://github.com/vmware/govmomi/releases/download/v${GOVC_VERSION}/govc_linux_amd64.gz | gunzip > /usr/local/bin/govc
chmod +x /usr/local/bin/govc

# install docker
install-docker () {
	curl -L -o /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-Linux-x86_64 && chmod +x /usr/local/bin/docker-compose

	curl -fsSL https://get.docker.com -o get-docker.sh
	sh get-docker.sh
	rm get-docker.sh
	adduser ${VMUSER} docker
	cp daemon.json /etc/docker/.
	systemctl restart docker
}
[ ${DOCKER} == "YES" ] && install-docker

# install ansible
[ ${ANSIBLE} == "YES" ] && apt install -y ansible

# install pulumi
curl -fsSL https://get.pulumi.com | sh

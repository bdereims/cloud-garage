#!/bin/bash 
#bdereims@gmail.com | cloud-garage project
#install and first step config for kubespeay

. ./env

sudo apt update
sudo apt -y install ansible-core python3-pip

cd

python3 -m venv venv
source venv/bin/activate

git clone https://github.com/kubernetes-incubator/kubespray.git

cd kubespray
git checkout release-2.17
pip install -r requirements.txt

cp -rfp inventory/sample inventory/mycluster

IPS=$( cat ${KUBE_INFRA_LIST} | awk '{print $3}' )
IPS=(${IPS})

CONFIG_FILE=inventory/mycluster/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

echo "modify ${CONFIG_FILE} and execute: ansible-playbook -i inventory/mycluster/hosts.yml -u root -b -v --private-key=~/.ssh/id_rsa cluster.yml"


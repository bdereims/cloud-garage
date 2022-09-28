#!/bin/bash 
#bdereims@gmail.com | cloud-garage project
#install kubespray

sudo apt -y install python3-pip
sudo pip3 install --upgrade pip

cd ~
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
sudo pip install -r requirements.txt

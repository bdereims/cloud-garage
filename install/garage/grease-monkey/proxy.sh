#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#set proxy env variables, "no" as arg to unset vars

if [ "${1}" == "no" ]; then
	unset http_proxy
	unset https_proxy
	unset no_proxy
else
	### assuming that proxy is hosted by gateway
	GWIP=$( ip route | grep default | sed -e "s/^.*via //" -e "s/ dev.*$//" )
	export http_proxy=http://${GWIP}:3128
	export https_proxy=http://${GWIP}:3128
	#export no_proxy=172.17.20.7,172.17.20.121,172.17.20.3,cloud-garage.net,172.17.20.240
	export no_proxy=192.168.0.0/16,172.16.0.0/12,10.0.0.0/8,*.cloud-garage.net
fi

#!/bin/bash 
#bdereims@gmail.com | cloud-garage project
#create new bm instance 

. ./env

# $1: name
# $2: id

COMP_ID=$( oci iam compartment list --compartment-id-in-subtree true --all | jq '.["data"] | .[] | select(."name" == "'${COMP_NAME}'") | .id' | sed -e "s/\"//g" )
SBNT_PUBLIC_ID=$(oci network subnet list -c ${COMP_ID} --display-name public | jq '.[] | .[] | .id' | sed -e "s/\"//g" )
AVAIL_DOMAIN=$( oci iam availability-domain list --compartment-id ${COMP_ID} | jq '.data | .[0] | .name' | sed -e "s/\"//g" )

echo "Launching instance ${1}-${2}..."
INSTANCE_ID=$( oci compute instance launch \
--availability-domain "${AVAIL_DOMAIN}" \
--compartment-id ${COMP_ID} \
--display-name ${NODE_NAME}-${2}-${1} \
--image-id ${IMAGE_ID} \
--shape ${SHAPE_NAME_BM} \
--ssh-authorized-keys-file "/home/sixty9/.ssh/authorized_keys" \
--subnet-id ${SBNT_PUBLIC_ID} \
--wait-for-state "RUNNING" 2> /dev/null | jq '.data | .id' | sed -e "s/\"//g" )

PUBLIC_IP=$( oci compute instance list-vnics --instance-id ${INSTANCE_ID} | jq '.data | .[] | ."public-ip"' | sed -e "s/\"//g" )

# waiting until up&running
CNX=-1
while [ ${CNX} != "0" ]
do
	sleep 5
	CNX=$( ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10 ubuntu@${PUBLIC_IP} 'exit 0' ; echo $? )
	printf "."
done
sleep 20 

ssh -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} "sudo apt-get update && sudo apt-get install -y git && git clone https://github.com/bdereims/cloud-garage && cd cloud-garage/install/oci/node && sudo bash -x bootstrap.sh > install.log"

echo "New Instance Public IP: ${PUBLIC_IP}"

PRIVATE_IP=$( oci compute instance list-vnics --instance-id ${INSTANCE_ID} | jq '.data | .[] | ."private-ip"' |  sed -e "s/\"//g" )
printf "${NODE_NAME}-${2}-${1}\t${PUBLIC_IP}\t${PRIVATE_IP}\n" >> ${KUBE_INFRA_LIST}

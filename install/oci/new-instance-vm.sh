#!/bin/bash 
#bdereims@gmail.com | cloud-garage project
#create new vm instance 

. ./env

# $1: name
# $2: id

COMP_ID=$( oci iam compartment list --compartment-id-in-subtree true --all | jq -r '.["data"] | .[] | select(."name" == "'${COMP_NAME}'") | .id' )
SBNT_PUBLIC_ID=$(oci network subnet list -c ${COMP_ID} --display-name public | jq -r '.[] | .[] | .id' )
AVAIL_DOMAIN=$( oci iam availability-domain list --compartment-id ${COMP_ID} | jq -r '.data | .[0] | .name' )

echo "Launching instance ${1}-${2}..."
INSTANCE_ID=$( oci compute instance launch \
--availability-domain "${AVAIL_DOMAIN}" \
--compartment-id ${COMP_ID} \
--display-name ${NODE_NAME}-${2}-${1} \
--image-id ${IMAGE_ID} \
--shape ${SHAPE_NAME_VM} \
--ssh-authorized-keys-file "/home/sixty9/.ssh/authorized_keys" \
--subnet-id ${SBNT_PUBLIC_ID} \
--shape-config file://${1}-shape.json \
--wait-for-state "RUNNING" 2> /dev/null | jq -r '.data | .id' )

PUBLIC_IP=$( oci compute instance list-vnics --instance-id ${INSTANCE_ID} | jq -r '.data | .[] | ."public-ip"' )

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

PRIVATE_IP=$( oci compute instance list-vnics --instance-id ${INSTANCE_ID} | jq -r '.data | .[] | ."private-ip"' )
printf "${PRIVATE_IP}\t${NODE_NAME}-${2}-${1}\n${PUBLIC_IP}\t${NODE_NAME}-${2}-${1}-public\n" >> ${KUBE_INFRA_LIST}

echo "${NODE_NAME}-${2}-${1} is finished."


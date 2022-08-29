#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#launch instance sixty9

. ./env

COMP_ID=$( oci iam compartment list --compartment-id-in-subtree true --all | jq '.["data"] | .[] | select(."name" == "'${COMP_NAME}'") | .id' | sed -e "s/\"//g" )
#VCN_ID=$( oci network vcn list -c ${COMP_ID} | jq '.["data"] | .[] | select(."display-name" == "'${VCN_NAME}'") | .id' | sed -e "s/\"//g" ) 
SBNT_PUBLIC_ID=$(oci network subnet list -c ${COMP_ID} --display-name public | jq '.[] | .[] | .id' | sed -e "s/\"//g" )
AVAIL_DOMAIN=$( oci iam availability-domain list --compartment-id ${COMP_ID} | jq '.data | .[0] | .name' | sed -e "s/\"//g" )
#SHAPE_NAME=$( oci compute shape list --availability-domain "VXpT:US-ASHBURN-AD-1" --compartment-id ${COMP_ID} | jq '.data | [.[] | select(.shape | startswith("VM."))] | .[0] | .shape' )
SHAPE_NAME="VM.Standard.E4.Flex"
VM_NAME=sixty9

# Ubuntu 22.04 LTS minimal
IMAGE_ID=ocid1.image.oc1.iad.aaaaaaaa2uqsnlxswtgp7ebqfqxi6jvwulu6vzzznbyqc5ywx7fdbzqkz5ya

echo "Launching new instance..."
INSTANCE_ID=$( oci compute instance launch \
--availability-domain "${AVAIL_DOMAIN}" \
--compartment-id ${COMP_ID} \
--display-name ${VM_NAME} \
--image-id ${IMAGE_ID} \
--shape ${SHAPE_NAME} \
--ssh-authorized-keys-file "/home/sixty9/.ssh/id_rsa.pub" \
--subnet-id ${SBNT_PUBLIC_ID} \
--shape-config file://sixty9-shape.json \
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

# configure sixty9
ssh -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} "sudo apt-get update && sudo apt-get install -y git && git clone https://github.com/bdereims/cloud-garage && cd cloud-garage/install/sixty9 && sudo ./bootstrap.sh"

echo "Sixty9 Public IP: ${PUBLIC_IP}"
echo "Enjoy!"


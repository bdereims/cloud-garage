#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#launch instance sixty9

. ./env

COMP_ID=$( oci iam compartment list --compartment-id-in-subtree true --all | jq -r '.["data"] | .[] | select(."name" == "'${COMP_NAME}'") | .id' )
#VCN_ID=$( oci network vcn list -c ${COMP_ID} | jq -r '.["data"] | .[] | select(."display-name" == "'${VCN_NAME}'") | .id' ) 
SBNT_PUBLIC_ID=$(oci network subnet list -c ${COMP_ID} --display-name public | jq -r '.[] | .[] | .id' )
AVAIL_DOMAIN=$( oci iam availability-domain list --compartment-id ${COMP_ID} | jq -r '.data | .[0] | .name' )
#SHAPE_NAME=$( oci compute shape list --availability-domain "VXpT:US-ASHBURN-AD-1" --compartment-id ${COMP_ID} | jq '.data | [.[] | select(.shape | startswith("VM."))] | .[0] | .shape' )
SHAPE_NAME="VM.Standard.E3.Flex"
VM_NAME=sixty9

# Ubuntu 22.04 LTS 
IMAGE_ID=ocid1.image.oc1.iad.aaaaaaaas6qul34auoiybzgbd4dw2irxix73hgps622rk6d7oawzlrtpfiwa

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

# configure sixty9
ssh -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} "sudo apt-get update && sudo apt-get install -y git && git clone https://github.com/bdereims/cloud-garage && cd cloud-garage/install/sixty9 && sudo ./bootstrap.sh"

echo "Sixty9 Public IP: ${PUBLIC_IP}"
echo "Enjoy!"


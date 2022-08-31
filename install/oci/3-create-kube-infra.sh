#!/bin/bash -x
#bdereims@gmail.com | cloud-garage project
#create kube infra

. ./env

COMP_ID=$( oci iam compartment list --compartment-id-in-subtree true --all | jq '.["data"] | .[] | select(."name" == "'${COMP_NAME}'") | .id' | sed -e "s/\"//g" )
#VCN_ID=$( oci network vcn list -c ${COMP_ID} | jq '.["data"] | .[] | select(."display-name" == "'${VCN_NAME}'") | .id' | sed -e "s/\"//g" ) 
SBNT_PUBLIC_ID=$(oci network subnet list -c ${COMP_ID} --display-name public | jq '.[] | .[] | .id' | sed -e "s/\"//g" )
AVAIL_DOMAIN=$( oci iam availability-domain list --compartment-id ${COMP_ID} | jq '.data | .[0] | .name' | sed -e "s/\"//g" )
#SHAPE_NAME=$( oci compute shape list --availability-domain "VXpT:US-ASHBURN-AD-1" --compartment-id ${COMP_ID} | jq '.data | [.[] | select(.shape | startswith("VM."))] | .[0] | .shape' )
SHAPE_NAME="VM.Standard.E4.Flex"

# Ubuntu 20.04 LTS 
IMAGE_ID=ocid1.image.oc1.iad.aaaaaaaa2zjkrjfmn2qv6mkcupitlf6ittlm7pjap5oi3oppsmtfbgkmxscq


new_instance_vm() {
# $1: name
# $2: id

echo "Launching instance ${1}..."
INSTANCE_ID=$( oci compute instance launch \
--availability-domain "${AVAIL_DOMAIN}" \
--compartment-id ${COMP_ID} \
--display-name ${NODE_NAME}-${2}-${1} \
--image-id ${IMAGE_ID} \
--shape ${SHAPE_NAME} \
--ssh-authorized-keys-file "/home/sixty9/.ssh/id_rsa.pub" \
--subnet-id ${SBNT_PUBLIC_ID} \
--shape-config file://${1}-shape.json \
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

# configure sixty9
ssh -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} "sudo apt-get update && sudo apt-get install -y git && git clone https://github.com/bdereims/cloud-garage && cd cloud-garage/install/oci/node && sudo bash -x bootstrap.sh > install.log"

echo "New Instance Public IP: ${PUBLIC_IP}"

} 

# create vm node(s) 
for (( C=1; C<=${NUM_NODES_VM}; C++ ))
do
	if [ ${C} -le ${NUM_MASTER} ]; then
		new_instance_vm master ${C}
	else
		new_instance_vm worker ${C}
	fi
done

#!/bin/bash 
#bdereims@gmail.com | cloud-garage project
#create kube infra

. ./env

cp /dev/null ${KUBE_INFRA_LIST}

# create master node(s) 
for (( C=1; C<=${NUM_MASTER_VM}; C++ ))
do
	./new-instance-vm.sh master ${C} &
done

# create vm worker node(s)
VM=$( expr ${NUM_MASTER_VM} + 1 )
BM=$( expr ${VM} + ${NUM_WORKER_VM} )
for (( C=${VM}; C<${BM}; C++ ))
do
	./new-instance-vm.sh worker ${C} & 
done

# create bm worker node(s)
VM=$( expr ${NUM_MASTER_VM} + ${NUM_WORKER_VM} + 1 )
BM=$( expr ${VM} + ${NUM_WORKER_BM} )
for (( C=${VM}; C<${BM}; C++ ))
do
	./new-instance-bm.sh worker ${C} &
done


echo ; echo "---"
echo "Kube Infra List in ${KUBE_INFRA_LIST}:"
tail -f ${KUBE_INFRA_LIST}

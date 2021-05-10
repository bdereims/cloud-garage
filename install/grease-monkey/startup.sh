#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#start vm with ovf specs 
#$1: debug for log

DEBUG="${1}"
TYPE="Debian"
#TYPE="ESX"

debug() {
	[ "${DEBUG}" == "debug" ] && echo ">>> ${1}" >&2
}

retrieve() {
	#${1}: name of variable
	VAL=$( vmtoolsd --cmd 'info-get guestinfo.ovfEnv' | grep ${1} | sed -e "s/^.*value=\"//" -e "s/\".*$//" )
	debug "retrieve ${1}: ${VAL}"
	echo "${VAL}"
}

context() {
	IP1=$( retrieve en1 )
	IP2=$( retrieve en2 )
	IP3=$( retrieve en3 )
	ASN=$( retrieve asn )
	PASSWORD=$( retrieve password )
	FQDN=$( retrieve fqdn )
	AUTH_KEY=$( retrieve authorized_key )
}

set_hostname() {
	if [ ${TYPE} == "Linux" ]; then
		HOSTNAME=$( echo ${FQDN} | sed -e "s/\..*$//" )
		hostname ${HOSTNAME}
		echo ${HOSTNAME} > /etc/hostname
	fi
}

set_auth_key() {
	case ${TYPE} in 
		"Debian")
			mkdir -p ~/.ssh
			echo ${AUTH_KEY} > ~/.ssh/authorized_keys
			;;
	esac		
}	

set_vnic() {
	if [ "${1}" != "" ]; then
        	case ${TYPE} in
			"Debian")
				INTERFACE=$( echo ${1} | sed -e "s/:.*$//" )
				IP=$( echo ${1} | sed -e "s/^.*://" )

				ifdown ${INTERFACE}
				ip a add ${IP} dev ${INTERFACE}
				ip link set up ${INTERFACE}

				GW=$( echo "${IP}" | sed -e "s/\/.*$//" |  sed 's!^.*/!!' | sed 's/\.[0-9]*$//' )
				GW="${GW}.1"
				ip route add default via ${GW}
                        	;;
        	esac
	fi
}

set_dns() {
	 if [ "${1}" != "" ]; then
                case ${TYPE} in
                        "Debian")
                                INTERFACE=$( echo ${1} | sed -e "s/:.*$//" )
                                IP=$( echo ${1} | sed -e "s/^.*://" )

                                GW=$( echo "${IP}" | sed -e "s/\/.*$//" |  sed 's!^.*/!!' | sed 's/\.[0-9]*$//' )
                                GW="${GW}.1"
				DOMAIN=$( echo ${FQDN} |  cut -f2- -d. )

                                echo "nameserver ${GW}" > /etc/resolv.conf
				echo "search ${DOMAIN}" >> /etc/resolv.conf
                                ;;
                esac
        fi
}

set_ntp() {
         if [ "${1}" != "" ]; then
                case ${TYPE} in
                        "Debian")
                                INTERFACE=$( echo ${1} | sed -e "s/:.*$//" )
                                IP=$( echo ${1} | sed -e "s/^.*://" )

                                GW=$( echo "${IP}" | sed -e "s/\/.*$//" |  sed 's!^.*/!!' | sed 's/\.[0-9]*$//' )
                                GW="${GW}.1"

                                #echo "nameserver ${GW}" > /etc/resolv.comf
                                ;;
                esac
        fi
}

set_password() {
	case ${TYPE} in
		"Debian")
			printf "${PASSWORD}\n${PASSWORD}\n" | passwd root 2>&1 > /dev/null
			printf "${PASSWORD}\n${PASSWORD}\n" | passwd grease-monkey 2>&1 > /dev/null
                ;;
        esac
}

main() {
	context
	set_hostname
	set_auth_key
	set_vnic ens192:${IP1}
	set_dns ens192:${IP1}
	set_password
}

main

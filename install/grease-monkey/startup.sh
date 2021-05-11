#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#start vm with ovf specs 
#$1: debug for log

DEBUG="${1}"
TYPE="Debian"
#TYPE="ESX"
OVFENV=/tmp/$$

debug() {
	[ "${DEBUG}" == "debug" ] && echo ">>> ${1}" >&2
}

retrieve() {
	#${1}: name of variable
	VAL=$( cat ${OVFENV} | grep ${1} | sed -e "s/^.*value=\"//" -e "s/\".*$//" )
	debug "retrieve ${1}: ${VAL}"
	echo "${VAL}"
}

context() {
	EN1=$( retrieve EN1 )
	GW1=$( retrieve GW1 )
	EN2=$( retrieve EN2 )
	GW2=$( retrieve GW2 )
	EN3=$( retrieve EN3 )
	GW3=$( retrieve GW3 )
	ASN=$( retrieve ASN )
	PASSWORD=$( retrieve passwd )
	FQDN=$( retrieve FQDN )
	AUTH_KEY=$( retrieve authorized_key )
	DNS=$( retrieve DNS )
}

set_hostname() {
	if [ ${TYPE} == "Debian" ]; then
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
	INTERFACE=$( echo ${1} | cut -d: -f1 )
	IP=$( echo ${1} | cut -d: -f2 )
	GW=$( echo ${1} | cut -d: -f3 )

	if [ "${IP}" != "" ]; then
        	case ${TYPE} in
			"Debian")
				ifdown ${INTERFACE}
				ip a add ${IP} dev ${INTERFACE}
				ip link set up ${INTERFACE}

				#GW=$( echo "${IP}" | sed -e "s/\/.*$//" |  sed 's!^.*/!!' | sed 's/\.[0-9]*$//' )
				#GW="${GW}.1"
				ip route add default via ${GW}
            	;;
        	esac
	fi
}

set_dns() {
	if [ "${EN1}" != "" ]; then
		case ${TYPE} in
        	"Debian")
				DOMAIN=$( echo ${FQDN} |  cut -f2- -d. )
                echo "nameserver ${DNS}" > /etc/resolv.conf
				echo "search ${DOMAIN}" >> /etc/resolv.conf
                ;;
        esac
	fi
}

set_ntp() {
         if [ "${IP1}" != "" ]; then
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
	vmtoolsd --cmd 'info-get guestinfo.ovfEnv' > ${OVFENV} 

	context 
	set_hostname
	set_auth_key
	set_vnic ens192:${EN1}:${GW1}
	set_dns 
	set_password
	rm ${OVFENV} 
}

main

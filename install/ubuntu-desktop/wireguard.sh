#!/bin/bash
#bdereims@gmail.com

case ${1} in
	"start")
		modprobe wireguard
		ip link add wg0 type wireguard
		#ip link set mtu 1500 dev wg0
		ip a add 10.255.253.3/24 dev wg0
		wg setconf wg0 /etc/cloud-garage.wireguard
		ip link set up dev wg0
		
		# routes to rbx
		ip route add 172.22.5.0/24 via 10.255.253.1
		ip route add 172.22.10.0/24 via 10.255.253.1
		ip route add 172.23.0.0/16 via 10.255.253.1

		echo "Wireguard is started."
		;;


	"stop")
		ip link set down dev wg0
		ip link delete wg0

		echo "Wireguard is stopped."
		;;
	
	*)
		echo "Usage is '${0} start' or '${0} stop'."
		;;
esac

exit 0

#!/bin/bash
#!/bin/bash
#bdereims@gmail.com | cloud-garage project

### WireGuard
modprobe wireguard
ip link add wg0 type wireguard
ip link set mtu 1500 dev wg0
ip a add 10.255.255.1/24 dev wg0
wg setconf wg0 /etc/wireguard.conf
ip link set up dev wg0

### Firewall
INGRESS=ens3

iptables -P INPUT   DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  DROP

iptables -F
iptables -X
iptables -Z

iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

iptables -t nat -A POSTROUTING -o ${INGRESS} -s 0.0.0.0/0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o wg0 -s 0.0.0.0/0 -j MASQUERADE
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p udp -i ${INGRESS} --dport 8172 -j ACCEPT

iptables -A INPUT  -i lo -j ACCEPT
iptables -A INPUT  -i wg0 -j ACCEPT

iptables -A OUTPUT -j ACCEPT
iptables -A FORWARD -j ACCEPT

iptables -A INPUT -p tcp -i ${INGRESS} --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -i ${INGRESS} --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -i ${INGRESS} --dport 443 -j ACCEPT
iptables -A INPUT -p udp -i ${INGRESS} --dport 8172 -j ACCEPT

### ANTI BRUTE-FORCE ####
iptables -A INPUT -i ${INGRESS} -p tcp -m tcp --dport 22 -m state --state NEW -m recent --set --name SSH --rsource
iptables -A INPUT -i ${INGRESS} -p tcp -m tcp --dport 22 -m recent --rcheck --seconds 120 --hitcount 4 --rttl --name SSH --rsource -j REJECT --reject-with tcp-reset
iptables -A INPUT -i ${INGRESS} -p tcp -m tcp --dport 22 -m recent --rcheck --seconds 120 --hitcount 3 --rttl --name SSH --rsource -j LOG --log-prefix "SSH brute force "
iptables -A INPUT -i ${INGRESS} -p tcp -m tcp --dport 22 -m recent --update --seconds 120 --hitcount 3 --rttl --name SSH --rsource -j REJECT --reject-with tcp-reset
iptables -A INPUT -i ${INGRESS} -p tcp -m tcp --dport 22 -j ACCEPT

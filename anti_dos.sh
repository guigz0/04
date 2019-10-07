#!/bin/bash

# Drop invalid packets
sudo iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

# Drop all new packets without SYN TCP flag
sudo iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

# Drop all packet without right MSS
sudo iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP

# Drop bogus TCP flags
sudo iptables -t mangle -A PREROUTING -p tcp -m tcp --tcp-flags SYN,FIN SYN,FIN 	-j DROP
sudo iptables -t mangle -A PREROUTING -p tcp -m tcp --tcp-flags SYN,RST SYN,RST		-j DROP
sudo iptables -t mangle -A PREROUTING -p tcp -m tcp --tcp-flags FIN,RST FIN,RST 	-j DROP
sudo iptables -t mangle -A PREROUTING -p tcp -m tcp --tcp-flags FIN,ACK FIN		-j DROP
sudo iptables -t mangle -A PREROUTING -p tcp -m tcp --tcp-flags ACK,FIN FIN		-j DROP
sudo iptables -t mangle -A PREROUTING -p tcp -m tcp --tcp-flags ACK,URG URG		-j DROP
sudo iptables -t mangle -A PREROUTING -p tcp -m tcp --tcp-flags ACK,PSH PSH		-j DROP
sudo iptables -t mangle -A PREROUTING -p tcp -m tcp --tcp-flags ALL ALL			-j DROP
sudo iptables -t mangle -A PREROUTING -p tcp -m tcp --tcp-flags ALL NONE		-j DROP
sudo iptables -t mangle -A PREROUTING -p tcp -m tcp --tcp-flags ALL FIN,PSH,URG		-j DROP
sudo iptables -t mangle -A PREROUTING -p tcp -m tcp --tcp-flags ALL SYN,FIN,PSH,URG	-j DROP
sudo iptables -t mangle -A PREROUTING -p tcp -m tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG	-j DROP

# Reject connections from host with more than 50 established connections
sudo iptables -A INPUT -p tcp -m connlimit --connlimit-above 50 -j REJECT --reject-with tcp-reset

# Limit SYN floods
sudo iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 10/s --limit-burst 20 -j ACCEPT
sudo iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP

# Limit ping floods
sudo iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT

# Protect against Slow Loris
sudo iptables -I INPUT -p tcp --dport 80 -m connlimit --connlimit-above 10 --connlimit-mask 32 -j DROP

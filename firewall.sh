#!/bin/bash

# Reset rules
sudo iptables -F
sudo iptables -X

# Drop all packets by default
sudo iptables -P INPUT		DROP
sudo iptables -P FORWARD	DROP
sudo iptables -P OUTPUT		DROP

# Loopback
sudo iptables -A INPUT	-i lo -j ACCEPT
sudo iptables -A OUTPUT	-o lo -j ACCEPT

# Keep established connections
sudo iptables -A INPUT	-m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT	-m state --state RELATED,ESTABLISHED -j ACCEPT

# SSH
sudo iptables -A INPUT	-i enp0s3 -p tcp --dport 55555 -j ACCEPT
sudo iptables -A OUTPUT	-o enp0s3 -p tcp --dport 55555 -j ACCEPT
sudo iptables -A INPUT	-i enp0s3 -p tcp --dport 25 -j ACCEPT
sudo iptables -A OUTPUT	-o enp0s3 -p tcp --dport 25 -j ACCEPT

# PING
sudo iptables -A INPUT	-p icmp -j ACCEPT
sudo iptables -A OUTPUT	-p icmp -j ACCEPT

# HTTP/HTTPS
sudo iptables -A INPUT	-i enp0s3 -p tcp --dport 80:443 -j ACCEPT
sudo iptables -A OUTPUT	-o enp0s3 -p tcp --dport 80:443 -j ACCEPT

# DNS
sudo iptables -A INPUT	-i enp0s3 -p tcp --dport 53 -j ACCEPT
sudo iptables -A INPUT	-i enp0s3 -p udp --dport 53 -j ACCEPT
sudo iptables -A OUTPUT	-o enp0s3 -p tcp --dport 53 -j ACCEPT
sudo iptables -A OUTPUT	-o enp0s3 -p udp --dport 53 -j ACCEPT


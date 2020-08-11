#!/bin/bash


if [ ! -f "/etc/openvpn/easy-rsa/pki/ca.crt" ]; then
  cd /etc/openvpn/easy-rsa
  # Init PKI dirs and build CA certs
  ./easyrsa init-pki
  ./easyrsa build-ca nopass
  # Generate Diffie-Hellman parameters
  ./easyrsa gen-dh
  # Genrate server keypair
  ./easyrsa build-server-full server nopass

  # Generate shared-secret for TLS Authentication
  openvpn --genkey --secret pki/ta.key
  cp /etc/openvpn/easy-rsa/pki/{ca.crt,ta.key,issued/server.crt,private/server.key,dh.pem} "/etc/openvpn/"

  if [[ -z $server_port ]]; then
    server_port="443"
  fi

fi


primary_nic=`ip route | grep default | cut -d ' ' -f 5`

# Iptable rules
iptables -I FORWARD -i tun0 -j ACCEPT
iptables -I FORWARD -o tun0 -j ACCEPT
iptables -I OUTPUT -o tun0 -j ACCEPT

iptables -A FORWARD -i tun0 -o $primary_nic -j ACCEPT
iptables -t nat -A POSTROUTING -o $primary_nic -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $primary_nic -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.2/24 -o $primary_nic -j MASQUERADE



tail -f /dev/null
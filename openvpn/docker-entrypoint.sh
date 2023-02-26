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
  ./easyrsa build-client-full zfr2fa nopass
 

  # Generate shared-secret for TLS Authentication
  openvpn --genkey --secret pki/ta.key
  cp /etc/openvpn/easy-rsa/pki/{ca.crt,ta.key,issued/server.crt,private/server.key,dh.pem} "/etc/openvpn/"

  if [[ -z $server_port ]]; then
    server_port="443"
  fi

fi

# Configure MySQL in openvpn scripts
sed -i "s/USER=''/USER='$OPENVPN_ADMIN_USER'/" "/etc/openvpn/scripts/config.sh"
sed -i "s/PASS=''/PASS='$OPENVPN_ADMIN_PASSWORD'/" "/etc/openvpn/scripts/config.sh"
sed -i "s/HOST='localhost'/HOST='db'/" "/etc/openvpn/scripts/config.sh"

mkdir /dev/net
if [ ! -f /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
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

# ensure that we are using the port specifiedby HOST_SSL_PORT
sed -i "s/port 443/port $HOST_SSL_PORT/" /etc/openvpn/server.conf;

# Need to feed key password
/usr/sbin/openvpn --cd /etc/openvpn/ --config /etc/openvpn/server.conf

tail -f /var/log/openvpn.log
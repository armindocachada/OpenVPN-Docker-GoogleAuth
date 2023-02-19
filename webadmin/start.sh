#!/usr/bin/env bash

# wait until certificates are generated
while [ ! -f "/etc/openvpn/ca.crt" ]
do
     sleep 1;
     echo "Waiting for OpenVPN certificates to be generated";
done

cd /var/www/html
# Copy ta.key inside the client-conf directory
for directory in "./client-conf/gnu-linux/" "./client-conf/osx-viscosity/" "./client-conf/windows/"; do
  if [ ! -f "$directory/ca.crt" ];then
    echo "Copying certificates";
    cp "/etc/openvpn/"{ca.crt,ta.key,server.crt,server.key,zfr2fa.crt,zfr2fa.key} $directory;
    chown -R www-data:www-data $directory
    # Replace in the client configurations with the ip of the server and openvpn protocol
    file="$directory/client.ovpn";
    sed -i "s/remote xxx\.xxx\.xxx\.xxx 443/remote $HOST_ADDR $HOST_SSL_PORT/" $file;
    echo "<ca>" >> $file;
    cat "/etc/openvpn/ca.crt" >> $file;
    echo "</ca>" >> $file;
    echo "<tls-auth>" >> $file;
    cat "/etc/openvpn/ta.key" >> $file;
    echo "</tls-auth>" >> $file;
  fi
done

apache2-foreground
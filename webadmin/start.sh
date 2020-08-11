#!/usr/bin/env bash

cd /var/www/html
# Copy ta.key inside the client-conf directory
for directory in "./client-conf/gnu-linux/" "./client-conf/osx-viscosity/" "./client-conf/windows/"; do
  if [ ! -f "$directory/ca.crt" ];then
    echo "Copying certificates";
    cp "/etc/openvpn/"{ca.crt,ta.key} $directory;
    chown -R www-data:www-data $directory
    # Replace in the client configurations with the ip of the server and openvpn protocol
    for file in $(find -name client.ovpn); do
        sed -i "s/remote xxx\.xxx\.xxx\.xxx 443/remote $HOST_ADDR $HOST_SSL_PORT/" $file;
        echo "<ca>" >> $file;
        cat "/etc/openvpn/ca.crt" >> $file;
        echo "</ca>" >> $file;
        echo "<tls-auth>" >> $file;
        cat "/etc/openvpn/ta.key" >> $file;
        echo "</tls-auth>" >> $file;
    done
  fi
done

apache2-foreground
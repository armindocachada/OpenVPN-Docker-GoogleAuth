#!/usr/bin/env bash

cd /var/www/html
# Copy ta.key inside the client-conf directory
for directory in "./client-conf/gnu-linux/" "./client-conf/osx-viscosity/" "./client-conf/windows/"; do
  cp "/etc/openvpn/"{ca.crt,ta.key} $directory
  chown -R www-data:www-data $directory
done

apache2-foreground
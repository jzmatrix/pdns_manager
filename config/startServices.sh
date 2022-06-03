#!/bin/bash

# Generate Self-Signed Cert
openssl req -x509 -newkey rsa:4096 -nodes -keyout /tmp/openssl.key -out /tmp/openssl.crt -subj /CN=catchall -days 3650 
cat /tmp/openssl.crt >  /STORAGE/PEM/catchall.pem
cat /tmp/openssl.key >> /STORAGE/PEM/catchall.pem


# Install packages that pipeline doesn't like installing
apt-get update
apt-get -y install screen openssh-client openssh-server

# Copy config files
cp /config-haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg
cp /config-dnsmanager/ConfigUser.php /var/www/html/backend/config/ConfigUser.php
echo "" >> /etc/haproxy/haproxy.cfg
cp /config-ssh/authorized_keys /root/.ssh/authorized_keys
cp /config-ssh/ssh.public /root/.ssh/id_rsa.pub
cp /config-ssh/ssh.private /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa

# Pre-pull SSH Key
# /usr/bin/ssh-keyscan pdns.ziemba.net >> root/.ssh/known_hosts

# Perform initial SSL pull, and start HaProxy (if pull succeeds)
# /opt/sslUpdate/sslUpdate

# Start the configuration/configMap monitor for HaProxy
/usr/bin/screen -dmS ConfigMonitor /opt/monitorConfig

# Start apache
apache2ctl start

# Start SSHd daemon holder (Not used to SSH in to container, but to hold PID 1 when haproxy reloads)
/usr/sbin/sshd -D

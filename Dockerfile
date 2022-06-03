FROM debian:11
################################################################################
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install curl gpg && \
    curl https://haproxy.debian.net/bernat.debian.org.gpg | gpg --dearmor > /usr/share/keyrings/haproxy.debian.net.gpg && \
    echo deb "[signed-by=/usr/share/keyrings/haproxy.debian.net.gpg]" http://haproxy.debian.net bullseye-backports-2.4 main > /etc/apt/sources.list.d/haproxy.list && \
    apt-get update && \
    apt-get --no-install-recommends -y install vim net-tools lsof nmap openssl tzdata ca-certificates rsync apt-transport-https ca-certificates haproxy=2.4.\* && \
    /bin/rm -f /etc/localtime && \
    cp /usr/share/zoneinfo/America/New_York /etc/localtime && \
    echo "America/New_York" > /etc/timezone && \
    apt-get autoremove && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /opt/sslUpdate && \
    mkdir /var/run/sshd && \
    mkdir -p /STORAGE/PEM/ && \
    chmod 0755 /var/run/sshd
################################################################################
ADD config/startServices.sh /opt/startServices.sh
ADD config/bash_profile /root/.bash_profile
ADD config/sslUpdate /opt/sslUpdate/sslUpdate
ADD config/monitorConfig /opt/monitorConfig
################################################################################
################################################################################
RUN chmod 755 /opt/startServices.sh && \
    chmod 644 /root/.bash_profile && \
    chmod 755 /opt/sslUpdate/sslUpdate && \
    chmod 755 /opt/monitorConfig 
################################################################################
################################################################################
CMD [ "/opt/startServices.sh" ]
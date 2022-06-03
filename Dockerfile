FROM debian:10
################################################################################
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install passwd lsb-release apt-transport-https ca-certificates wget curl gpg && \
    ###
    # Add repo config for HaProxy
    curl https://haproxy.debian.net/bernat.debian.org.gpg | gpg --dearmor > /usr/share/keyrings/haproxy.debian.net.gpg && \
    # echo deb "[signed-by=/usr/share/keyrings/haproxy.debian.net.gpg]" http://haproxy.debian.net bullseye-backports-2.4 main > /etc/apt/sources.list.d/haproxy.list && \
    echo deb "[signed-by=/usr/share/keyrings/haproxy.debian.net.gpg]" http://haproxy.debian.net buster-backports-2.2 main > /etc/apt/sources.list.d/haproxy.list && \
    ###
    # Add repo config for PHP
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    ###
    # General package installs
    apt-get update && \
    apt-get --no-install-recommends -y install vim net-tools lsof nmap openssl tzdata rsync haproxy=2.2.\* && \
    ###
    # PHP package installs w/ apache
    apt-get -y install php7.4 apache2  pkg-config libmongoc-1.0-0 php7.4-dev php7.4-xml php7.4-cli php7.4-json php7.4-memcache php7.4-memcached php7.4-mysql php7.4-common && \
    # apt -y install php7.4-bcmath php7.4-bz2 php7.4-cgi php7.4-curl php7.4-gd php7.4-geoip php7.4-gmp php7.4-imagick php7.4-intl php7.4-mbstring php7.4-mcrypt  php7.4-mongodb  php7.4-opcache php7.4-pspell php7.4-readline php7.4-snmp php7.4-tidy php7.4-xmlrpc php7.4-xsl php7.4-zip php-pear && \
    ###
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
    chmod 0755 /var/run/sshd && \
    mkdir /run/haproxy
################################################################################
ADD www /var/www/html
ADD config/php7/php.ini /etc/php/7.4/apache2/php.ini
ADD config/apache2/apache2.conf /etc/apache2/apache2.conf
ADD config/apache2/ports.conf /etc/apache2/ports.conf
ADD config/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
ADD config/apache2/info.conf /etc/apache2/mods-available/info.conf
ADD config/apache2/status.conf /etc/apache2/mods-available/status.conf
ADD config/startServices.sh /opt/startServices.sh
ADD config/bash_profile /root/.bash_profile
ADD config/sslUpdate /opt/sslUpdate/sslUpdate
ADD config/monitorConfig /opt/monitorConfig
################################################################################
################################################################################
RUN chmod 644 /etc/php/7.4/apache2/php.ini && \
    chmod 644 /etc/apache2/apache2.conf && \
    chmod 644 /etc/apache2/sites-available/000-default.conf && \
    chmod 644 /etc/apache2/mods-available/info.conf && \
    chmod 644 /etc/apache2/mods-available/status.conf && \
    ln -f -s /etc/apache2/conf-available/php7.4-cgi.conf /etc/apache2/conf-enabled/ && \
    ln -f -s /etc/apache2/mods-available/info.conf /etc/apache2/mods-enabled/ && \
    ln -f -s /etc/apache2/mods-available/info.load /etc/apache2/mods-enabled/ && \
    ln -f -s /etc/apache2/mods-available/remoteip.load /etc/apache2/mods-enabled/ && \
    ln -f -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/ && \
    ln -f -s /etc/apache2/mods-available/status.conf /etc/apache2/mods-enabled/ && \
    ln -f -s /etc/apache2/mods-available/status.load /etc/apache2/mods-enabled/ && \
    chmod 755 /opt/startServices.sh && \
    chmod -R 755 /var/www/html/* && \
    chmod 644 /root/.bash_profile && \
    chmod 755 /opt/sslUpdate/sslUpdate && \
    chmod 755 /opt/monitorConfig 
################################################################################
################################################################################
CMD [ "/opt/startServices.sh" ]
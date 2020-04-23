#!/bin/bash
# Tested on Ubuntu 14.04.5 LTS
# proftpd 1.3.5 compiled with mod_copy module
# PHP 5.6
# Reference: http://www.linuxfromscratch.org/blfs/view/7.7/server/proftpd.html

set -e

# Echo script purpose and give warning
echo -e "\nThis script will install proftpd 1.3.5 with mod_copy module\n"
echo "This is a vulnerable version of proftpd that will result in RCE"
echo "Do not use on an actual production environment"

# Get proftpd-1.3.5 package
wget ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.5.tar.gz

tar -xf proftpd-1.3.5.tar.gz

# Set up proftp user
echo -e "[+]\nSetting up proftpd user and /bin/false shell\n"
echo -e "[+]\nRequesting sudo user password and root password\n"
sudo groupadd -g 69 proftpd && 
sudo useradd -c proftpd -d /srv/ftp -g proftpd \
     -s /usr/bin/proftpdshell -u 69 proftpd &&

sudo install -v -d -m775 -o proftpd -g proftpd /srv/ftp &&
sudo ln -v -s /bin/false /usr/bin/proftpdshell &&
su -c "echo /usr/bin/proftpdshell >> /etc/shells" root

# Compile proftp from source
cd proftpd-1.3.5/ 

echo -e "[+]\nCompiling proftp from source as regular user\n"
echo -e "[+]\nRequesting user password for user [yellow]\n"
su -c "./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var/run --with-modules=mod_copy && make" yellow

sudo make install

# Prepare web server
echo -e "[+]\nSetting up Apache + PHP web server\n"
sudo mkdir -p /var/www/html
sudo chmod 777 /var/www/html

sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install php5.6

# Start proftpd
echo -e "[+]\nStarting proftpd\n"
sudo /usr/sbin/proftpd

# Test the vulnerability with the POC below:
# http://www.linuxfromscratch.org/blfs/view/7.7/server/proftpd.html

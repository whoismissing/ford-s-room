#!/bin/bash
# https://www.drupal.org/docs/7/install
# Tested on Ubuntu Server 17.10
# Apache 2.4.27
# mysql Ver 14.14 Distrib 5.7.19
# PHP 7.1.17

# Check if root before running rest of the install script
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit
fi

# Echo script purpose and give user warning
echo -e "\nThis script will install Drupal 7.30 which is vulnerable to exploit/multi/http/drupal_drupageddon" 
echo "The purpose of this installation is for testing and learning purposes"
echo "Please do not use on an actual production environment"
echo -e "\nIf you would still like to continue, press [Y] otherwise press any other key to exit"

read -n1 -r -p "> " key
if [ "$key" = 'Y' ]; then
    echo -e "\nContinuing..."
else
    echo -e "\nExiting..."
    exit 99
fi

echo "==================================================="
echo "Database settings will be:"
echo -e "mysql users\nroot:P@ssw0rd\ndrupadmin:P@ssw0rd\n"
echo "database name = drupal"

echo -e "\n[+] Installing LAMP + dependencies\n"
# Download LAMP packages and dependencies [ user will be prompted to set mysql-server password ]
apt-get install apache2 mysql-server php7.1 php7.1-mysql libapache2-mod-php7.1 php7.1-gd php7.1-xml openssh-server

echo -e "\n[+] Getting drupal\n"
# Get vulnerable drupal version [ 7.0 - 7.31 ]
wget https://ftp.drupal.org/files/projects/drupal-7.30.tar.gz
tar -xzf drupal-7.30.tar.gz

echo -e "\n[+] Setting up mysql db\n"
# Set up mysql database for drupal
mysql -u root -pP@ssw0rd -e "CREATE DATABASE drupal; CREATE USER 'drupadmin'@'localhost' IDENTIFIED BY 'P@ssw0rd'; GRANT ALL ON drupal.* TO 'drupadmin'@'localhost' IDENTIFIED BY 'P@ssw0rd'; FLUSH PRIVILEGES;"

echo -e "\n[+] Configuring drupal file permissions\n"
# Configure drupal
cp drupal-7.30/sites/default/default.settings.php drupal-7.30/sites/default/settings.php
cp -r drupal-7.30/* /var/www/html/
chmod 666 /var/www/html/sites/default/settings.php
chmod 666 /var/www/html/sites/default/default.settings.php
mv /var/www/html/index.html /var/www/
mkdir /var/www/html/sites/default/files
chmod 755 /var/www/html/sites/default/files
chgrp -R www-data /var/www/html/sites/default/files
chmod -R g+w /var/www/html/sites/default/files
chmod 2775 /var/www/html/sites/default/files

echo -e "\n[+] Restarting apache\n"
systemctl restart apache2

echo -e "\n==================================================="
echo "==================================================="
echo "Database settings will be:"
echo -e "drupadmin:P@ssw0rd\n"
echo "database name = drupal"

# Go to http://[yoursite]/install.php in web browser to continue the installation in the web portal, when finished press space to continue and finish the rest of the installation script
echo -e "\tOpen your web browser and go to http://localhost/install.php to continue the installation. When you are finished there, then"
read -n1 -r -p "Press space to continue..." key
if [ "$key" = '' ]; then
    echo ""
fi

echo -e "[+] Setting post-install permissions\n"
# Post install permissions
chmod 555 /var/www/html/sites/default 
chmod 444 /var/www/html/sites/default/settings.php 

# Test the vulnerability with metasploit:
# exploit - exploit/multi/http/drupal_drupageddon
# payload - php/meterpreter/reverse_tcp

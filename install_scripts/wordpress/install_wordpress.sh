#!/bin/bash
# Usage [run as root]: bash install_wordpress.sh
# Tested on Ubuntu Server 17.10, thus package names may differ from other distros / versions
# Script to set up and [mostly] configure an anonymous ftp, wordpress, and ssh server
# Probably better off setting up vagrant / docker
# You will be prompted to set up mysql-server root:P@ssw0rd

#  Check if root before running rest of the install script
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit
fi

# Echo script purpose and give user warning
echo -e "\nThis script will install anonymous FTP and wordpress with weak credentials" 
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

# Download all packages and dependencies
echo -e "\n[+] Installing vsftpd, LAMP + dependencies, and openssh-server\n"
apt-get install vsftpd apache2 mysql-server php7.1 php7.1-fpm php7.1-mysql libapache2-mod-php7.1 php7.1-curl php7.1-gd php7.1-mbstring php7.1-mcrypt php7.1-xml php7.1-xmlrpc openssh-server

echo -e "\n[+] Getting latest wordpress\n"
wget https://wordpress.org/latest.tar.gz

# Configure vsftpd for anonymous access only
echo -e "\n[+] Configuring anonymous FTP\n"
cp /etc/vsftpd.conf /etc/vsftpd.conf.orig
mkdir -p /var/ftp/pub
chown nobody:nogroup /var/ftp/pub
echo "vsftpd test file" | sudo tee /var/ftp/pub/test.txt
sed -i '-e s/anonymous_enable=.*/anonymous_enable=YES/' '-e s/local_enable=.*/local_enable=NO/' /etc/vsftpd.conf
echo "anon_root=/var/ftp/" >> /etc/vsftpd.conf
echo "no_anon_password=YES" >> /etc/vsftpd.conf
echo "hide_ids=YES" >> /etc/vsftpd.conf
echo "pasv_min_port=40000\npasv_max_port=50000" >> /etc/vsftpd.conf
systemctl restart vsftpd

# Set up mysql database with one-liner to run queries from command line, the lack of space after -p is not a typo
echo -e "\n[+] Setting up mysql db\n"
echo "Database settings will be:"
echo -e "mysql users\nroot:P@ssw0rd\nmyuser:P@ssw0rd\n"
echo "database name = wordpress"
mysql -u root -pP@ssw0rd -e "CREATE DATABASE wordpress;CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'P@ssw0rd';GRANT ALL ON wordpress.* TO 'myuser'@'localhost' IDENTIFIED BY 'P@ssw0rd';FLUSH PRIVILEGES;"

# Configure wordpress
echo -e "\n[+] Configuring wordpress file permissions and wp-config.php\n"
tar -xzf latest.tar.gz
cp wordpress/wp-config-sample.php wordpress/wp-config.php
cp -r wordpress/* /var/www/html/
mv /var/www/html/index.html /var/www/
chown -R www-data:www-data /var/www/html/
chmod -R 777 /var/www/html/
sed -i '-e s/database_name_here/wordpress/' '-e s/username_here/myuser/' '-e s/password_here/P@ssw0rd/' /var/www/html/wp-config.php

systemctl restart apache2
echo -e "\n========================================================="
echo "========================================================="
echo "Database settings will be:"
echo -e "mysql users\nroot:P@ssw0rd\nmyuser:P@ssw0rd\n"
echo "database name = wordpress"

# Get server IP addr
ipaddr=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')

# At this point go to web browser and navigate to http://localhost/wp-admin to continue the installation in the web portal. When finished, press space to continue and finish the rest of the installation
echo "Open your web browser and go to http://$ipaddr/wp-admin to continue the installation. When you are finished there, then"
read -n1 -r -p "Press space to continue..." key

if [ "$key" = '' ]; then
    echo "Continuing"
fi

# Configure wordpress localhost redirect
echo -e "[+] Configuring wordpress site redirect with IP address $ipaddr\n"
mysql -u root -pP@ssw0rd <<MY_QUERY
USE wordpress
UPDATE wp_options set option_value='http://$ipaddr' where option_name='siteurl';
UPDATE wp_options set option_value='http://$ipaddr' where option_name='home';
MY_QUERY

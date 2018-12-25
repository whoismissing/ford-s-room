#!/bin/bash
# https://www.mediawiki.org/wiki/Manual:Running_MediaWiki_on_Debian_or_Ubuntu
# Tested on Ubuntu Server 17.10 and Ubuntu Server 18.04.1 LTS with some adjustments
# To install php7.1-mbstring, enable universe in /etc/apt/sources.list
# deb http://us.archive.ubuntu.com/ubuntu/ artful universe main
# deb http://us.archive.ubuntu.com/ubuntu/ artful-security universe main
# Mediawiki v1.31
# Script format modified from install_drupal730.sh

# Check if root before running rest of the install script
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit
fi

# Echo script purpose and give user warning
echo -e "\nThis script will install mediawiki 1.31"
echo "The purpose of this installation is for testing and learning purposes"
echo "Please be wary of using on an actual production environment due to the lack of error checking and storage of credentials in clear-text"
echo -e "\nIf you would still like to continue, press [Y] otherwise press any other key to exit"

read -n1 -r -p "> " key
if [ "$key" = 'Y' ]; then
    echo -e "\nContinuing..."
else
    echo -e "\nExiting..."
    exit 99
fi

# Modify vars as seen fit
rootdbpasswd="P@ssw0rd"
usrdbpasswd="P@ssw0rd"
ipaddr=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}') # or use hostname -I
url="localhost"

echo -e "\n[+] Installing LAMP + dependencies\n"
echo -e "cmd:\tapt-get install apache2 mysql-server php7.1 php7.1-mysql libapache2-mod-php7.1 php7.1-gd php7.1-xml php7.1-mbstring\n"
# Download LAMP packages and dependencies [ user will be prompted to set mysql-server password ]
apt-get install apache2 mysql-server php7.1 php7.1-mysql libapache2-mod-php7.1 php7.1-gd php7.1-xml php7.1-mbstring
# Enable universe repository for php7.2-mbstring when running on Ubuntu 18.04.1
# add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
# apt-get install apache2 mysql-server php7.2 php7.2-mysql libapache2-mod-php7.2 php7.2-gd php7.2-xml php7.2-cmmon php7.2-mbstring

echo -e "\n[+] Getting mediawiki tar and copying to /var/www/html/\n"
# Get mediawiki v1.31
wget https://releases.wikimedia.org/mediawiki/1.31/mediawiki-1.31.1.tar.gz
tar -xzf mediawiki-1.31.1.tar.gz
cp -r mediawiki-1.31.1/* /var/www/html/
mv /var/www/html/index.html /var/www/

# On Ubuntu 18, mysql-server package will have no mysql server password prompt, instead need to set password via sudo mysql_secure_installation, so pause here
echo "==================================================="
echo "Database settings will be:"
echo -e "mysql users\nroot:$rootdbpasswd\nwikidbadmin:$usrdbpasswd\n"
echo "database name = wikidb"
echo "If script is being run on Ubuntu 18, pause here, otherwise just skip this"
echo "In another terminal, run sudo mysql_secure_installation, press Y when finished"
read -n1 -r -p "> " key
if [ "$key" = 'Y' ]; then
    echo -e "\nContinuing..."
else
    echo -e "\nExiting..."
    exit 99
fi

echo -e "\n[+] Setting up initial mysql db\n"
# Set up mysql database for mediawiki
mysql -u root -p$rootdbpasswd -e "CREATE DATABASE wikidb; CREATE USER 'wikidbadmin'@'localhost' IDENTIFIED BY '$usrdbpasswd'; GRANT ALL ON wikidb.* TO 'wikidbadmin'@'localhost' IDENTIFIED BY '$usrdbpasswd'; FLUSH PRIVILEGES;"

echo -e "\n[+] Configuring mediawiki file permissions\n"
# Configure mediawiki
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

echo -e "\n[+] Enable mbstring and xml php modules, then restarting apache\n"
phpenmod mbstring
phpenmod xml
systemctl restart apache2

echo -e "\n==================================================="
echo "==================================================="
echo "Database settings will be:"
echo -e "wikidbadmin:$usrdbpasswd\n"
echo "database name = wikidb"

# Go to http://[yoursite]/install.php in web browser to continue the installation in the web portal, when finished press space to continue and finish the rest of the installation script
echo -e "\tOpen your web browser and go to http://$ipaddr/install.php to continue the installation. When you are finished there, then"
read -n1 -r -p "Press space to continue..." key
if [ "$key" = '' ]; then
    echo ""
fi

echo -e "[+] Getting LocalSettings.php\n"
# Get LocalSettings.php
wget http://$url/LocalSettings.php -P /var/www/html

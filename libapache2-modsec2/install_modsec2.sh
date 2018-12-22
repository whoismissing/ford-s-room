#!/bin/bash
# Install modsecurity [apache2] from repository
# Tested on Ubuntu 17.10
# Installing and configuring libapache2-mod-security2 v2.9.1-3 with OWASP core rule set v3.0.2

# Check if root before running rest of the install script
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit
fi

# Echo script purpose and give user warning
echo -e "\nThis script will install modsecurity2 for apache with the OWASP core rule set"
echo "The purpose of this installation is for testing and learning purposes"
echo "Please do not use on an actual production environment due to a lack of error-checking in this script"
echo -e "\nIf you would still like to continue, press [Y] otherwise press any other key to exit"

read -n1 -r -p "> " key
if [ "$key" = 'Y' ]; then
    echo -e "\nContinuing..."
else
    echo -e "\nExiting..."
    exit 99
fi

echo -e "\n[+] Installing libapache2-mod-security2 package\n"
apt-get install libapache2-mod-security2 || echo "Installation failed" && exit

echo -e "\n[+] Configuring /etc/modsecurity/modsecurity.conf\n"
# Echo Important Configurations:
echo "Some important configurations are:"
echo -e "\tSecRuleEngine On"
echo -e "\tSecRequestBodyAccess On"
echo -e "\tSecDebugLog /opt/modsecurity/var/log/debug.log"
echo -e "\tSecDebugLogLevel 9"
echo -e "\tSecAuditEngine On"
echo -e "\tSecAuditLogType Concurrent"
echo -e "\tSecAuditLog /var/log/apache2/modsec_audit.log # Even though it's concurrent, still need this line"
echo -e "\tSecAuditLogStorageDir /var/log/modsecurity/audit"
echo -e "\tSecAuditLogDirMode \"default\""
echo -e "\tSecAuditLogFileMode \"default\""

cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

# Modify Line 7 from DetectionOnly to On for blocking
sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf
# Modify Lines 192 - 196 to set up audit logs as concurrent and set log storage location to /opt/modsecurity/var/audit
sed -i 's/SecAuditLogType Serial/SecAuditLogType Concurrent/' /etc/modsecurity/modsecurity.conf
sed -i 's/#SecAuditLogStorageDir /SecAuditLogStorageDir /' /etc/modsecurity/modsecurity.conf
# Insert lines 197 and 198
sed -i '197iSecAuditLogDirMode \"default\"' /etc/modsecurity/modsecurity.conf
sed -i '198iSecAuditLogFileMode \"default\"' /etc/modsecurity/modsecurity.conf

echo -e "\n[+] Setting up audit log file permissions in /opt/modsecurity/var/audit/\n"
# Set up audit log file permissions
mkdir -p /opt/modsecurity/var/audit/
chown -R www-data:www-data /opt/modsecurity/var/audit

echo -e "\n[+] Getting OWASP core rule set and moving rules to the right place\n"
# Get OWASP core rule set and move to the right place
# git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v3.0.2.tar.gz
tar -xzf v3.0.2.tar.gz
mv owasp-modsecurity-crs-3.0.2/rules /etc/modsecurity

echo -e "\n[+] Modifying /etc/apache2/mods-available/security2.conf with the correct Include statements\n"
echo -e "# Include configuration files in this order:"
echo -e "\t/etc/modsecurity/modsecurity.conf"
echo -e "\t/etc/modsecurity/crs-setup.conf"
echo -e "\t/etc/modsecurity/rules/*.conf"

cp /etc/modsecurity/crs/crs-setup.conf /etc/modsecurity/crs-setup.conf

# Comment out IncludeOptional /usr/share/modsecurity-crs/owasp-crs.load
sed -i 's/IncludeOptional /#IncludeOptional /' /etc/apache2/mods-available/security2.conf
# Insert Include statements for configuration files
sed -i '10i\\tInclude /etc/modsecurity/modsecurity.conf' /etc/apache2/mods-available/security2.conf
sed -i '11i\\tInclude /etc/modsecurity/crs-setup.conf' /etc/apache2/mods-available/security2.conf
sed -i '12i\\tInclude /etc/modsecurity/rules/*.conf' /etc/apache2/mods-available/security2.conf

echo -e "\n[+] Restarting apache\n"
systemctl restart apache2

echo -e "\n[+] Installation script is done - hopefully modsecurity is installed\n"

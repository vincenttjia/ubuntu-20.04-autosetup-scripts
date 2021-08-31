#!/bin/bash
apt-get update
apt-get install freeradius freeradius-mysql freeradius-utils -y
apt-get install php-common php-gd php-curl php-mysql -y
apt-get install mysql-server mysql-client -y

# Make sure that NOBODY can access the server without a password
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'vincent1234'"
mysql -e "CREATE USER 'freeradius'@'localhost' IDENTIFIED BY 'freeradius'"
mysql -e "CREATE USER 'adminpanel'@'localhost' IDENTIFIED BY 'adminpanel'"
mysql -e "CREATE DATABASE radius"
mysql -e "GRANT ALL PRIVILEGES ON radius.* TO 'freeradius'@'localhost'"
mysql -e "GRANT ALL PRIVILEGES ON radius.* TO 'adminpanel'@'localhost'"
mysql radius < /etc/freeradius/3.0/mods-config/sql/main/mysql/schema.sql
mysql radius < /etc/freeradius/3.0/mods-config/sql/main/mysql/setup.sql
mysql -e "FLUSH PRIVILEGES"

ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/sql

cp default /etc/freeradius/3.0/sites-available/default
chown freerad:freerad /etc/freeradius/3.0/sites-available/default
chmod 640 /etc/freeradius/3.0/sites-available/default

cp sql /etc/freeradius/3.0/mods-available/sql
chown freerad:freerad /etc/freeradius/3.0/mods-available/sql
chmod 640 /etc/freeradius/3.0/mods-available/sql

cp clients.conf /etc/freeradius/3.0/clients.conf
chown freerad:freerad /etc/freeradius/3.0/clients.conf
chmod 640 /etc/freeradius/3.0/clients.conf

systemctl enable freeradius
systemctl restart freeradius

apt-get install apache2 -y
apt-get install php libapache2-mod-php -y
a2enmod mpm_prefork && sudo a2enmod php7.0
apt-get install php-gd php-mail php-mail-mime php-pear php-db -y
service apache2 restart

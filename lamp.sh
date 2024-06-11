#!/usr/bin/sudo bash
apt update && apt upgrade -y
apt install apache2 apache2-utils libapache2-mod-security2 acl mariadb-server php php8.3-fpm phpmyadmin certbot python3-certbot-apache samba cifs-utils -y
systemctl enable apache2
a2enmod http2
a2enmod brotli
a2enmod security2
ufw allow http
ufw allow https
chown www-data:www-data /var/www/html/ -R
systemctl enable mariadb
mysql_secure_installation
a2enmod php8.3
systemctl restart apache2
a2dismod php8.3
a2enmod proxy_fcgi setenvif
a2enconf php8.3-fpm
a2dismod php8.3
a2dismod mpm_prefork
a2enmod mpm_event
systemctl restart apache2
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

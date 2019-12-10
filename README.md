# UbuntuConfig

Ubuntu 18.04 - LAMP Setup

Install Ubuntu 18.04 Server from https://ubuntu.com/download/server

## Step 1: Update Software Packages
```
sudo apt update
sudo apt upgrade
```

## Step 2: Install Apache Web Server
```
sudo apt install -y apache2 apache2-utils
systemctl status apache2  // Check status
sudo systemctl enable apache2  // Enable at boot
apache2 -v  // Check version
sudo ufw allow http  // Configure firewall
sudo chown www-data:www-data /var/www/html/ -R  // Change user of doc root
```

## Step 3: Install MariaDB Database Server
```
sudo apt install mariadb-server mariadb-client
systemctl status mariadb  // Check status
sudo systemctl enable mariadb  // Enable at boot
sudo mysql_secure_installation  // Secure installation
mariadb --version  // Check version
```

## Step 4: Install PHP7.2
```
sudo apt install php7.2 libapache2-mod-php7.2 php7.2-mysql php-common php7.2-cli php7.2-common php7.2-json php7.2-opcache php7.2-readline php7.2-curl
sudo a2enmod php7.2
sudo systemctl restart apache2
php --version
```

Switch to using FPM
```
sudo a2dismod php7.2
sudo apt install php7.2-fpm
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php7.2-fpm
sudo systemctl restart apache2
```

## Step 5: Install phpMyAdmin
```
sudo apt update
sudo apt install phpmyadmin
```
Once installed, create an admin acount
```
sudo mysql -u root
create user admin@localhost identified by 'your-preferred-password';
grant all privileges on *.* to admin@localhost with grant option;
flush privileges;
exit;
```

## Step 6: Install LetsEncrypt certbot
```
sudo apt install certbot python3-certbot-apache
```
And then run the following command to get a certificate, replace `example.com` with your domain name
```
sudo certbot --apache --agree-tos --redirect --hsts --staple-ocsp --must-staple -d example.com --email you@example.com
```

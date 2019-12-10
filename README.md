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

### Create your vitual host file
Create a config by typing `sudo nano /etc/apache2/sites-available/domain.com.conf`
```
<VirtualHost *:80>
   ServerName domain.com
   ServerAdmin admin@domain.com
   DocumentRoot /var/www/html/domain.com
   ErrorLog ${APACHE_LOG_DIR}/error.log
   CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
Enable site by typing `sudo a2enmod domain.com.conf`
   
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
Optional - Update to latest stable release
```
cd ~
wget https://files.phpmyadmin.net/phpMyAdmin/4.9.2/phpMyAdmin-4.9.2-all-languages.zip
sudo apt install unzip
unzip phpMyAdmin-4.9.2-all-languages.zip
sudo mv /usr/share/phpmyadmin /usr/share/phpmyadmin-original
sudo mv phpMyAdmin-4.9.2-all-languages /usr/share/phpmyadmin
```

Edit the vendor config file `sudo nano /usr/share/phpmyadmin/libraries/vendor_config.php`

Find the following line `define('CONFIG_DIR', '');`

Change it to `define('CONFIG_DIR', '/etc/phpmyadmin/');`

Save and close the file. Then create the tmp folder to store cache files. `sudo mkdir /usr/share/phpmyadmin/tmp`

Change user ownership and group ownership to www-data. `sudo chown www-data:www-data /usr/share/phpmyadmin/tmp`


## Step 6: Install LetsEncrypt certbot
```
sudo apt install certbot python3-certbot-apache
```
And then run the following command to get a certificate, replace `example.com` with your domain name
```
sudo certbot --apache --agree-tos --redirect --hsts --staple-ocsp --must-staple -d example.com --email you@example.com
```

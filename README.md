# UbuntuConfig

Ubuntu LAMP Setup

Install Ubuntu Server from https://ubuntu.com/download/server

## Step 1: Update Software Packages
```
sudo apt update && sudo apt upgrade -y
```


## Step 2: Install Apache Web Server
```
sudo apt install -y apache2 apache2-utils
systemctl status apache2  // Check status
sudo systemctl enable apache2  // Enable at boot
apache2 -v  // Check version

sudo ufw allow http  // Configure firewall for http
sudo ufw allow https  // Configure firewall for https
sudo chown www-data:www-data /var/www/html/ -R  // Change user of doc root

sudo setfacl -R -m "u:{$USER}:rwx" /var/www/html  // Set user permissions recursively for your username
getfacl var/www/html  // Check permissions
```

### Create your vitual host file
Change `domain.com` to match your domain name.
Create a config by typing `sudo nano /etc/apache2/sites-available/domain.com.conf`
```
<VirtualHost *:80>
   ServerAdmin admin@domain.com
   ServerName domain.com
   ServerAlias www.domain.com
   DocumentRoot /var/www/html/domain.com
   ErrorLog ${APACHE_LOG_DIR}/error.log
   CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
Enable site by typing `sudo a2ensite domain.com`
   
## Step 3: Install MariaDB Database Server
```
sudo apt install mariadb-server
mariadb --version  // Check version
systemctl status mariadb  // Check status
sudo systemctl enable mariadb  // Enable at boot
sudo mysql_secure_installation  // Secure installation
```

## Step 4: Install PHP7.4
```
sudo apt install php7.4 libapache2-mod-php7.4 php7.4-mysql php-common php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline php7.4-curl
sudo a2enmod php7.4
sudo systemctl restart apache2
php --version
```

Switch to using FPM
```
sudo a2dismod php7.4
sudo apt install php7.4-fpm
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php7.4-fpm
sudo systemctl restart apache2
```

## Step 5: Install phpMyAdmin
```
sudo add-apt-repository ppa:phpmyadmin/ppa  // Add phpmyadmin repository
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
sudo certbot --apache --agree-tos --redirect --hsts --staple-ocsp --must-staple -d example.com,www.domain.com --email you@domain.com
```

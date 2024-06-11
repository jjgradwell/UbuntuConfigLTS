# Ubuntu Server 22.04 LTS Config

Ubuntu LAMP Setup

Install Ubuntu Server from https://ubuntu.com/download/server

Once the page has loaded, click on 'Option 2 - Manual Install' to access the download link

## Step 1: Update Software Packages

Update the software repositories and perform all upgrades to install software

```
   sudo apt update && sudo apt upgrade -y
```

## Step 2: Install Apache Web Server

To install a fully functional Apache server, enter each of these commands on a separate line in the terminal, change {$USER} to your username

```
   sudo apt install apache2 apache2-utils libapache2-mod-security2 -y
   systemctl status apache2  // Check status
   sudo systemctl enable apache2  // Enable at boot
   apache2 -v  // Check version

   // Enable mods
   sudo a2enmod http2
   sudo a2enmod brotli
   sudo a2enmod security2

   // Setup Ubuntu Firewall
   sudo ufw allow http  // Configure firewall for http
   sudo ufw allow https  // Configure firewall for https
   sudo ufw allow ssh from {ip list} proto tcp  // Configure firewall for ssh access from select ips
   sudo chown www-data:www-data /var/www/html/ -R  // Change user of doc root

   // Configure File Access List
   sudo apt install acl // Install the file access control list package
   sudo setfacl -R -m "u:{$USER}:rwx" /var/www/html  // Set user permissions recursively for your username
   getfacl /var/www/html  // Check permissions
```

### Create your vitual host file (for each domain you are creating)

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

Once installed, create an admin acount

```
   sudo mysql -u root
   CREATE USER 'admin'@'localhost' IDENTIFIED BY 'your-preferred-password'; // This command is case sensitive
   GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION; // This command is case sensitive
   FLUSH PRIVILEGES; // This command is case sensitive
   exit;
```

## Step 4: Install PHP

```
   sudo apt install php php-json
   sudo a2enmod php8.3
   sudo systemctl restart apache2
   php --version
```

Switch to using FPM

```
   sudo a2dismod php8.3
   sudo apt install php8.3-fpm
   sudo a2enmod proxy_fcgi setenvif
   sudo a2enconf php8.3-fpm
   sudo a2dismod php8.3
   sudo a2dismod mpm_prefork
   sudo a2enmod mpm_event
   sudo systemctl restart apache2
```

## Step 5: Install phpMyAdmin

```
   sudo apt install phpmyadmin
```

If the above command fails, use the following commands to install
```
   sudo add-apt-repository ppa:phpmyadmin/ppa  // Add phpmyadmin repository
   sudo apt update
   sudo apt install phpmyadmin
```

Edit the vendor config file `sudo nano /usr/share/phpmyadmin/libraries/vendor_config.php`

Find the following line `define('CONFIG_DIR', '');` and change it to `define('CONFIG_DIR', '/etc/phpmyadmin/');`

Save and close the file. Then create the tmp folder to store cache files. `sudo mkdir /usr/share/phpmyadmin/tmp`

Change user ownership and group ownership to www-data. `sudo chown www-data:www-data /usr/share/phpmyadmin/tmp`

To ensure that phpmyadmin works on systems with a strong content-security-policy, edit the apache.conf file by typing `sudo nano /etc/phpmyadmin/apache.conf`, and add the following lines into the <Directory> directive
   
```
    <IfModule mod_headers.c>
      Header always set Strict-Transport-Security "max-age=31536000"
      Header always set Content-Security-Policy "default-src 'self' 'unsafe-inline'; upgrade-insecure-requests; block-all-mixed-content;"
      Header always set Cache-Control "max-age=0, no-cache, no-store, must-revalidate"
    </IfModule>
```

## Step 6: Install LetsEncrypt certbot

Install Cerbot by using the following command

```
   sudo apt install certbot python3-certbot-apache
```

After installation, run the following command to generate a strong Diffe-Helman exchange key
```
   sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
```
   
And then run the following command to get a certificate, replace `example.com` with your domain name
   
```
     sudo certbot --apache --agree-tos --redirect --hsts --staple-ocsp --must-staple -d example.com,www.domain.com --email you@domain.com
```

## Step 7: Create Network Shares (Optional)
   
Open the terminal and install samba with the following command:
   
```
  sudo apt-get install samba cifs-utils
```

Set your workgroup (if necesary) by finding the following line and change it to match your workgroup name
   
```
   sudo nano /etc/samba/smb.conf
   # Change this to the workgroup/NT-domain name your Samba server will part of
   workgroup = WORKGROUP
```
   
At the bottom of the file, add your shares, changing ```/your-share-folder``` to the name of the directory you are going to share, changing {$user} to the user accounts that have write premissions
   
```
# MyShare
[MyShare]
   comment = YOUR COMMENTS
   path = /your-share-folder
   read only = no
   writeable = Yes
   create mask = 0755
   directory mask = 0755
   write list = {users} // Comma separated list
   valid users = {users} // Comma separated list
```

Add the users that are allowed access to the system, replacing {$user} with the actual user name
   
```
   sudo useradd {$user}
   sudo passwd {$user}
```

Now create the samba accounts, supplying a password for each account you add when prompted
   
```
   sudo smbpasswd -a {user}
```

Create the share folder: ```sudo mkdir /your-share-folder```

Set the permissions: ```sudo chmod 0775 /your-share-folder```

And then restart samba to use your changes
   
```
   sudo service smbd restart
```
   

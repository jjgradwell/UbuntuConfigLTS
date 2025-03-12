# Ubuntu Server LTS Config

Download Ubuntu Server from https://ubuntu.com/download/server and write the image to a usb drive using BelenaEtcher, and then install

## Update Software Packages

```
sudo apt update && sudo apt upgrade -y
```

## Install Apache Web Server

To install a fully functional Apache server, enter each of these commands on a separate line in the terminal, change {user} to your username

```
sudo apt install apache2 apache2-utils libapache2-mod-security2 libapache2-mod-evasive -y
sudo a2enmod http2 brotli rewrite headers

systemctl status apache2  // Check status
sudo systemctl enable apache2  // Enable at boot
apache2 -v  // Check version
sudo usermod -a -G www-data {user}
```

### Fixing mod_evasive errors (ie. 403 errors for phpMyAdmin
If using mod_evasive you need to edit the `/etc/apache2/mods-available/evasive.conf` file and modify the following to match your private/public IP addresses. Also uncomment each line in the file by removing the # symbol from the begining.

```
DOSWhitelist 127.0.0.1
DOSWhitelist 192.168.0.*
DOSWhitelist <public-ip>
````


Setup Ubuntu Firewall

```
   sudo systemctl enable ufw
   sudo ufw allow "Apache Full"  // Configure firewall for http
```

Configure File Access Control List

```
sudo apt install acl // Install the file access control list package
sudo setfacl -Rdm "g:{user}:rwx" /var/www/html
getfacl /var/www/html  // Check permissions
```
   

## Install MariaDB Database Server

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

## Install PHP and switch to FPM

```
sudo apt install php8.3 php8.3-fpm php8.3-yaml
sudo a2dismod php8.3 mpm_prefork
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php8.3-fpm
sudo a2enmod mpm_event
sudo systemctl restart apache2
php --version
```

## Create your virtual host files (for each domain you are creating)

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


## Install phpMyAdmin

```
sudo apt install phpmyadmin
```

To ensure that phpmyadmin works on systems with a strong content-security-policy, edit the apache.conf file by typing `sudo nano /etc/phpmyadmin/apache.conf`, and add the following lines into the <Directory> directive
   
```
    AllowOverride all
    Require ip 127.0.0.1 ::1 192.168.0.0/23
    Require all granted

    <IfModule mod_security.c>
        SecRuleEngine Off
    </IfModule>

   <IfModule mod_headers.c>
      Header unset Content-Security-Policy
      Header always set Content-Security-Policy "default-src 'self' 'unsafe-inline';"
      Header always set Cache-Control "max-age=0, no-cache, no-store, must-revalidate"
   </IfModule>
```

Add the following lines to the `/etc/apache2/apache2.conf` file, as this will prevent the 403/404 errors from appearing
```
<Directory /usr/share/phpmyadmin>
    Options Indexes FollowSymLinks MultiViews
    DirectoryIndex index.php
    AllowOverride all
    Require all granted
</Directory>
```
## Install LetsEncrypt Certbot

```
sudo apt install certbot python3-certbot-apache
```

And then run the following command to get a certificate, replace `-d example.ca` with your domain name, and `--email email@example.com` to your email address
   
```
sudo certbot --apache --agree-tos --redirect --hsts --staple-ocsp --must-staple -d example.com --email you@domain.com
```

## Create Network Shares (Optional)
   
Open the terminal and install samba with the following command:
   
```
sudo apt-get install samba cifs-utils
```

Set your workgroup (if necesary) by finding the following line and change it to match your workgroup name (WINDOWS)
   
```
sudo nano /etc/samba/smb.conf
# Change this to the workgroup/NT-domain name your Samba server will part of
workgroup = WORKGROUP
```
   
At the bottom of the file, add your shares, changing `/your-share-folder` to the name of the directory you are going to share
   
```
# MyShare
[MyShare]
   comment = YOUR COMMENTS
   path = /your-share-folder
   read only = no
   writeable = Yes
   create mask = 0755
   directory mask = 0755
   write list = {users} // Comma separated list of samba accounts
   valid users = {users} // Comma separated list of samba accounts
   follow symlinks = yes
   wide links = yes
   veto files = /._*/.DS_Store/.AppleDB/.AppleDouble/.AppleDesktop/:2eDS_Store/Network Trash Folder/Temporary Items/TheVolumeSettingsFold>
   delete veto files = yes
```

Add the users that are allowed access to the system, replacing {user} with the actual user name, and create a Samba password for the account
   
```
sudo useradd {user} // If new user
sudo passwd {user} // If new user
sudo smbpasswd -a {user}
```

After creating a samba password for your user, you need to add them to the `/etc/samba/smbusers` file

```
sudo nano /etc/samba/smbusers
```

And add users using the following format `{user} = "{user}"`

Create the share folder: `sudo mkdir /your-share-folder`

Set the permissions: `sudo chmod 0775 /your-share-folder`

And then restart samba to use your changes
   
```
sudo ufw allow from 192.168.0.0/23 to any app Samba   // Limit shares to local network
sudo systemctl restart smbd
```



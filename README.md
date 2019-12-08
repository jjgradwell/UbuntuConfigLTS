# Ubuntu 18.04LTS LAMP install

From a fresh installation of Ubuntu run the following commands to update and upgrade all packages
```
sudo apt update
sudo apt upgrade -y
```

# Add repositories for latest versions of phpMyAdmin/Apache
```
sudo add-apt-repository ppa:ondrej/apache2
sudo add-apt-repository ppa:phpmyadmin/ppa
sudo apt update
```

Then install these missing utilities and Apache2
```
sudo apt install -y curl wget zip unzip apache2
```

Check the status of Apache2 to ensure that is running
```
systemctl status apache2
```

Change settings in UFW (Ubuntu Firewall) to allow full access for Apache2
```
sudo ufw allow in "Apache Full"
```

Enable mod_rewrite and restart Apache2
```
sudo a2enmod rewrite
sudo systemctl restart apache2
```

Install MariaDB and check the status
```
sudo apt install mariadb-server
sudo systemctl status mariadb
```

Secure your MariaDB installation
```
sudo mysql_secure_installation
```

Test the password you supplied for the root user account
```
sudo mysql -u root -p
```

Install PHP7.2 and required modules, and phpMyAdmin
```
sudo apt install php libapache2-mod-php php-mysql
sudo apt install php7.2 php7.2-fpm php7.2-mysql php-common php7.2-cli php7.2-common php7.2-json php7.2-opcache php7.2-readline php7.2-mbstring php7.2-xml php7.2-gd php7.2-curl php7.2-imap php7.2-zip php7.2-intl php7.2-mbstring php7.2-bcmath  php7.2-zip
sudo apt install phpmyadmin php-gettext
```

Update /etc/apache2/mods-enabled/dir.conf
```
# Change this line
DirectoryIndex index.html index.cgi index.pl index.xhtml index.htm
# To
DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
```

Update the user/owner of the document root of your server to www-data, and set file access controls for `username`
```
sudo chown www-data:www-data /var/www/html -R
sudo chmod -R 755 /var/www/html
sudo setfacl -R -m "u:username:rwx" /var/www/html/
sudo setfacl -R -m "g:username:rwx" /var/www/html/
```

Update /etc/apache2/apache2.conf to include the configuration file for phpMyAdmin if not already included at the bottom of file
```
# add to bottom of file if not already there
Include /etc/phpmyadmin/apache.conf
```

# Misc phpMyAdmin errors

In /usr/share/phpmyadmin/libraries/plugin_interface.lib.php
```
# Change this line
  if ($options != null && count($options) > 0) {
# To match this line
  if ($options != null && count((array)$options) > 0) {
```

In /usr/share/phpmyadmin/libraries/sql.lib.php find the function named PMA_isRememberSortingOrder
```
Change this
  ['select_expr'] == 1)
To this
  ['select_expr']) == 1)
  
  
Change this
  ['select_expr'][0] == '*')))
To this
  ['select_expr'][0] == '*'))
```

# Brotli compression
```
a2enmod brotli
```

Now add these line to /usr/local/apache/conf.d/brotli.conf
```
LoadModule brotli_module modules/mod_brotli.so
<IfModule mod_brotli.c>
BrotliCompressionQuality 6

BrotliFilterNote Input brotli_input_info
BrotliFilterNote Output brotli_output_info
BrotliFilterNote Ratio brotli_ratio_info
LogFormat '"%r" %{brotli_output_info}n/%{brotli_input_info}n (%{brotli_ratio_info}n%%)' brotli
CustomLog "logs/brotli_log" brotli

#Don't compress content which is already compressed
SetEnvIfNoCase Request_URI \
\.(gif|jpe?g|png|swf|woff|woff2) no-brotli dont-vary

#Make sure proxies don't deliver the wrong content
Header append Vary User-Agent env=!dont-vary
</IfModule>
```

# Install SAMBA
```
sudo apt install samba samba-common-bin
sudo systemctl start smbd
sudo systemctl start nmbd
```

Create a share in /etc/samba/smb.conf
```
# add to bottom of file 
  [Private]
  comment = needs username and password to access
  path = /srv/private/
  browseable = yes
  guest ok = no
  writable = yes
  valid users = @samba
```
Save the file, and test the config
```
testparm
```


Create samba users and set passwords where `username` is a valid system username
```
sudo adduser `username`
sudo smbpasswd -a `username`
sudo groupadd samba
sudo gpasswd -a `username` samba
```

Restart the Samba server
```
sudo systemctl restart smbd nmbd
```

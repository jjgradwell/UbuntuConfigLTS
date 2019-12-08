# Ubuntu 18.04LTS LAMP install

From a fresh installation of Ubuntu run the following commands to update and upgrade all packages
```
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl wget zip unzip
```

## Add repositories for latest Apache/PHP/phpMyAdmin
```
sudo add-apt-repository ppa:ondrej/apache2
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:phpmyadmin/ppa
sudo apt install software-properties-common
sudo apt update
```

# Install OpenSSH server, enable firewall and set permissions
```
sudo apt-get install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
sudo ufw allow ssh
sudo ufw enable
sudo ufw status
```

# Install Apache and enable mods
```
sudo apt install -y apache2
sudo systemctl status apache2
sudo ufw allow in "Apache Full"

sudo a2enmod http2
sudo a2enmod brotli
sudo a2enmod rewrite
```

## Brotli configuration
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

## Restart Apache
```
sudo systemctl restart apache2
```

# Install MariaDB
```
sudo apt install mariadb-server
sudo systemctl status mariadb
sudo mysql_secure_installation
sudo mysql -u root -p    /* Test root password */
```

# Install PHP7.3 and phpMyAdmin
```
sudo apt install php libapache2-mod-php php-mysql php-gettext
sudo apt install php-fpm php-common php-cli php-json php-opcache php-readline php-mbstring php-xml php-gd php-curl php-imap php-intl php-bcmath php-zip phpmyadmin
```

# Change Apache config files
Update /etc/apache2/mods-enabled/dir.conf
```
# add index.php to this line
DirectoryIndex index.html index.cgi index.pl index.xhtml index.htm
```

## Update the user/owner of the document root
```
sudo chown www-data:www-data /var/www/html -R
sudo chmod -R 755 /var/www/html
```

## Update File Access Control Lists
Change `username` to match the account you login with
```
sudo setfacl -R -m "u:username:rwx" /var/www/html/   /* Allow your account to edit, write to files */
```

## Update /etc/apache2/apache2.conf
```
# add to bottom of file if not already there
Include /etc/phpmyadmin/apache.conf
```

## Misc phpMyAdmin errors
In /usr/share/phpmyadmin/libraries/plugin_interface.lib.php
```
# Find this line
  if ($options != null && count($options) > 0) {
# And replace with
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

## Create samba users and set passwords where `username` is a valid system username
```
sudo adduser `username`
sudo smbpasswd -a `username`
sudo groupadd samba
sudo gpasswd -a `username` samba
sudo systemctl restart smbd nmbd
```

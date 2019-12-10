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

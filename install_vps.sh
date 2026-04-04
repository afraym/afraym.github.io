#!/bin/bash

# Update package list
sudo apt update

# Install Nginx
sudo apt install -y nginx

# Install prerequisites for PHP repository
sudo apt install -y lsb-release ca-certificates apt-transport-https software-properties-common curl unzip git

# Add PHP 8.3 repository
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# Install PHP 8.3 and important extensions for Laravel
sudo apt install -y php8.3 php8.3-fpm php8.3-mysql php8.3-xml php8.3-mbstring php8.3-curl php8.3-zip php8.3-bcmath php8.3-gd php8.3-cli php8.3-intl php8.3-readline php8.3-soap php8.3-redis

# Install MySQL Server
sudo apt install -y mysql-server

# Install Composer (PHP dependency manager)
EXPECTED_SIGNATURE="$(curl -s https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid Composer installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php

# Enable and start services
sudo systemctl enable nginx
sudo systemctl enable php8.3-fpm
sudo systemctl enable mysql

sudo systemctl start nginx
sudo systemctl start php8.3-fpm
sudo systemctl start mysql

echo "Installation complete: Nginx, PHP 8.3, MySQL, Composer, and Laravel extensions are installed."
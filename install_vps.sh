#!/bin/bash

# Update package list
sudo apt update

# Install Nginx
sudo apt install -y nginx


# Install prerequisites for PHP and repository management
sudo apt install -y lsb-release ca-certificates apt-transport-https software-properties-common curl unzip git

# Detect Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs)

if dpkg --compare-versions "$UBUNTU_VERSION" gt "22.04"; then
    # For Ubuntu > 22.04, install PHP directly from default repo
    sudo apt update
    sudo apt install -y php php-fpm php-mysql php-xml php-mbstring php-curl php-zip php-bcmath php-gd php-cli php-intl php-readline php-soap php-redis
else
    # For Ubuntu <= 22.04, use Ondřej Surý’s PPA for PHP 8.3
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt update
    sudo apt install -y php8.3 php8.3-fpm php8.3-mysql php8.3-xml php8.3-mbstring php8.3-curl php8.3-zip php8.3-bcmath php8.3-gd php8.3-cli php8.3-intl php8.3-readline php8.3-soap php8.3-redis
fi

# Prompt for MySQL root password
read -sp "Enter MySQL root password: " MYSQL_ROOT_PASSWORD

echo "\nInstalling MySQL Server..."
sudo apt install -y mysql-server

# Secure MySQL installation (non-interactive)
sudo mysql --user=root <<_EOF_
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
_EOF_

echo "MySQL root password set.\nYou can now login with: mysql -u root -p"

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
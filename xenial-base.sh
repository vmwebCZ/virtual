#!/bin/bash
source common.sh
echo "1.0" > tmp/VERSION

if ask 'Proceed git settings?' y; then
  read -p "Insert e-mail (eg john@doe.com)" email
  fullname=$(getent passwd `whoami` | cut -d ':' -f 5 | cut -d ',' -f 1)
  git config --global user.email "$email"
  git config --global user.name "$fullname"
  git config --global push.default current
fi

mkdir -p ~/.config
chmod -R g+r ~/.config
chmod g+x ~/.config
mkdir -p tmp

echo "APT::Install-Recommends \"0\";
APT::Install-Suggests \"0\";
" | sudo tee -a /etc/apt/apt.conf.d/95norecommend

pause 'Instalace mc a pridani repositories'
sudo apt-get update > /dev/null
sudo apt-get install -y software-properties-common mc
sudo add-apt-repository -y ppa:pdoes/ppa
#sudo add-apt-repository -y ppa:ondrej/php
sudo add-apt-repository -y ppa:webupd8team/java
sudo sed -i "/^# deb .*partner/ s/^# //" /etc/apt/sources.list

pause 'Apt-get update'
sudo apt-get update > /dev/null
sudo apt-get install -y mc

while true
do
  read -s -p "Password for MySQL: " mysqlpass
  echo
  read -s -p "Password for MySQL (again): " mysqlpass2
  echo
    [ "$mysqlpass" = "$mysqlpass2" ] && break
    echo "Please try again..."
done
echo "$mysqlpass" > tmp/mysql.pass
echo "mysql-server mysql-server/root_password password $mysqlpass" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $mysqlpass" | sudo debconf-set-selections
sudo apt-get install -y mysql-server mysql-client

pause 'Instalace memcached a imagemagick'
sudo apt-get install -y memcached imagemagick

pause 'Instalace Oracle JRE 8'
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo apt-get install -y oracle-java8-installer

pause 'Instalace wkHTMLtoPDF'
sudo apt-get install -y libmagickwand-dev libsasl2-dev xfonts-75dpi wkhtmltopdf
#wget -O tmp/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb http://default.vmweb.cz/install/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
#sudo dpkg -i --force-depends tmp/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb

pause 'Instalace Apache2 + PHP 7.0'
sudo apt-get install -y php php-dev php-common apache2 apache2-utils libapache2-mod-php php-pear
sudo apt-get install -y php-bz2 php-cli php-curl php-gd php-imagick php-imap php-json php-mbstring php-mcrypt
sudo apt-get install -y php-mysql php-memcached php-xdebug
sudo rm -f /etc/php/7.0/cli/conf.d/20-xdebug.ini
sudo a2enmod rewrite
sudo a2enmod php7.0
sudo a2dismod mpm_event
sudo a2dismod mpm_event
sudo a2enmod mpm_prefork
sudo rm -r -f /var/www/html
ln -s /var/www ~/www

pause 'Instalace Compass'
sudo apt-get install -y ruby ruby-dev
sudo gem install compass

pause 'Instalace NodeJS'
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs

pause 'Instalace PhantomJS'
sudo apt-get install -y build-essential chrpath libssl-dev libxft-dev
sudo apt-get install -y libfreetype6 libfreetype6-dev
sudo apt-get install -y libfontconfig1 libfontconfig1-dev
sudo npm install -g phantomjs-prebuilt

pause 'Instalace Solr automaticky, port 8983'
wget -O tmp/solr-6.1.0.tgz http://default.vmweb.cz/install/solr-6.1.0.tgz
cd tmp
tar xzf solr-6.1.0.tgz solr-6.1.0/bin/install_solr_service.sh --strip-components=2
sudo bash ./install_solr_service.sh solr-6.1.0.tgz
sudo sed -i 's|name="jetty.host"|name="jetty.host" default="127.0.0.1"|g' /opt/solr/server/etc/jetty-http.xml
rm tmp/solr-6.0.1.tgz
rm tmp/install_solr_service.sh
cd ..

pause 'Instalace Composer a Drush'
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
#sudo ln -s /usr/local/bin/composer /usr/bin/composer

pause 'Nastaveni GitHub OAuth'
read -p "Insert GitHub oAuth token, see: https://github.com/settings/tokens" githubtoken
composer config -g github-oauth.github.com $githubtoken

pause 'Instalace composer packages'
composer global require pear/Console_Color2
composer global require drush/drush
sudo ln -s "/home/$name/.config/composer/vendor/drush/drush/drush" /usr/local/bin/drush
sudo ln -s "/home/$name/.config/composer/vendor/drush/drush/drush.complete.sh" /etc/bash_completion.d/
composer global require drupal/console
sudo ln -s "/home/$name/.config/composer/vendor/drupal/console/bin/drupal" /usr/local/bin/drupal
composer global require phing/phing
sudo ln -s "/home/$name/.config/composer/vendor/phing/phing/bin/phing" /usr/local/bin/phing
composer global require phpunit/phpunit
sudo ln -s "/home/$name/.config/composer/vendor/phpunit/phpunit/bin/phpunit" /usr/local/bin/phpunit
composer global require squizlabs/php_codesniffer
sudo ln -s "/home/$name/.config/composer/vendor/squizlabs/php_codesniffer/scripts/phpcs" /usr/local/bin/phpcs
sudo ln -s "/home/$name/.config/composer/vendor/squizlabs/php_codesniffer/scripts/phpcbf" /usr/local/bin/phpcbf
composer global require behat/behat
sudo ln -s "/home/$name/.config/composer/vendor/behat/behat/bin/behat" /usr/local/bin/behat

#pause 'Kompilace twig library'
#cd /home/vmweb/.config/composer/vendor/twig/twig/ext/twig
#phpize
#./configure
#make
#sudo make install
#https://github.com/twigphp/Twig/issues/1695 -> https://www.drupal.org/node/2568247

pause 'Kopirovani /etc a var'
cd ~/virtual
sudo cp -r xenial-base/etc/* /etc
sudo cp -r xenial-base/var/* /var
sudo chown -R solr:solr /var/solr
sudo chown -R :www-data /etc/apache2/sites*
sudo chmod -R g+w /etc/apache2/sites*
sudo service mysql restart
sudo service solr restart
echo "" | sudo tee -a /etc/memcached.conf
echo "# Increase slab pages size" | sudo tee -a /etc/memcached.conf
echo "-I 4M" | sudo tee -a /etc/memcached.conf

pause 'Nastaveni apache'
sudo mkdir -p /var/log/apache2/drupal
sudo mkdir -p /var/log/apache2/others
sudo mkdir -p /var/www/html
cd /var/www/html && sudo wget http://default.vmweb.cz/install/index.html
sudo rm -f /etc/apache2/sites-enabled/*
sudo a2enconf dev.conf
sudo a2ensite 000-default.conf
sudo a2ensite 001-default-ssl.conf

pause 'Zmena groups a prav /var/www'
sudo usermod -g www-data $name
sudo usermod -a -G  $name  $name
sudo usermod -a -G sudo  $name  # important!
sudo usermod -a -G solr  $name
sudo chmod -R g+w /var/www
sudo setfacl -d -m g::rwx /var/www
sudo setfacl -d -m o::rx /var/www
sudo chown -R www-data:www-data /var/www

echo 'Vygeneruj si SSH klic prikazem: ssh-keygen -t rsa -b 4096 -C "your_email@example.com"'

if ask 'Change install repository to SSH?' y; then
  cd ~/virtual
  git remote set-url origin git@github.com:vmwebCZ/virtual.git
fi

echo 'Vypada to, ze hotovo. Restartuj virtual, a instaluj VBox Additions'

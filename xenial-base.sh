#!/bin/bash
source common.sh
mkdir -p tmp
echo "1.0" > tmp/VERSION

if ask "Proceed git settings?" y; then
  read -p "Insert e-mail (eg john@doe.com)" email
  fullname=$(getent passwd `whoami` | cut -d ':' -f 5 | cut -d ',' -f 1)
  git config --global user.email "$email"
  git config --global user.name "$fullname"
  git config --global push.default current
fi

if ask "Running first time?"; then
  mkdir -p ~/.config
  chmod g+r ~/.config
  chmod g+x ~/.config
  mkdir -p tmp
fi

if ask "Apt no-recommends?" y; then
  echo "APT::Install-Recommends \"0\";
  APT::Install-Suggests \"0\";
  " | sudo tee -a /etc/apt/apt.conf.d/95norecommend
fi

if ask "Instalace mc a zakladninch veci?" y; then
  sudo apt-get update > /dev/null
  sudo apt-get install -y software-properties-common mc curl
fi

if ask "Aktualizovat apt repository for git?" y; then
  sudo add-apt-repository -y ppa:pdoes/ppa
  sudo apt-get update > /dev/null
fi

if ask "Partners repositores?" y; then
  sudo sed -i "/^# deb .*partner/ s/^# //" /etc/apt/sources.list
fi

if ask "Install MySQL" y; then
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
  sudo cp -r xenial-base/etc/mysql /etc
  sudo apt-get install -y mysql-server mysql-client
  sudo service mysql restart
fi

if ask "Install Memcached?" y; then
  sudo apt-get install -y memcached
  echo "" | sudo tee -a /etc/memcached.conf
  echo "# Increase slab pages size" | sudo tee -a /etc/memcached.conf
  echo "-I 4M" | sudo tee -a /etc/memcached.conf
fi

if ask "Install Imagemagick?" y; then
  sudo apt-get install -y imagemagick
fi

if ask "Install Oracle JDE 8?" y; then
  sudo add-apt-repository -y ppa:webupd8team/java
  sudo apt-get update > /dev/null
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
  sudo apt-get install -y oracle-java8-installer
fi

if ask "Install wkhtmltopdf?" y; then
  sudo apt-get install -y libmagickwand-dev libsasl2-dev xfonts-75dpi wkhtmltopdf
  #wget -O tmp/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb http://default.vmweb.cz/install/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
  #sudo dpkg -i --force-depends tmp/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
fi

if ask "Instalace Apache2 + PHP 7.0?" y; then
  sudo apt-get install -y php php-dev php-common apache2 apache2-utils libapache2-mod-php php-pear
  sudo apt-get install -y php-bcmath php-bz2 php-cli php-curl php-gd php-imagick php-imap php-json php-mbstring php-mcrypt php-zip
  sudo apt-get install -y php-mysql php-memcached php-xdebug
  sudo rm -f /etc/php/7.0/cli/conf.d/20-xdebug.ini
  sudo a2enmod rewrite
  sudo a2enmod php7.0
  sudo a2dismod mpm_event
  sudo a2dismod mpm_event
  sudo a2enmod mpm_prefork
  sudo rm -r -f /var/www/html
  ln -s /var/www ~/www
  sudo chown -R :www-data /etc/apache2/sites*
  sudo chmod -R g+w /etc/apache2/sites*
  pause 'Nastaveni apache'
  sudo mkdir -p /var/log/apache2/drupal
  sudo mkdir -p /var/log/apache2/others
  sudo mkdir -p /var/www/html
  cd /var/www/html && sudo wget http://default.vmweb.cz/install/index.html
  sudo rm -f /etc/apache2/sites-enabled/*
  sudo a2enconf dev.conf
  sudo a2ensite 000-default.conf
  sudo a2ensite 001-default-ssl.conf
fi;

if ask "Instalace Compass?" y; then
  sudo apt-get install -y ruby ruby-dev
  sudo gem install compass
fi

if ask "Instalace NodeJS?" y; then
  curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

if ask "Instalace PhantomJS" y; then
  sudo apt-get install -y build-essential chrpath libssl-dev libxft-dev
  sudo apt-get install -y libfreetype6 libfreetype6-dev
  sudo apt-get install -y libfontconfig1 libfontconfig1-dev
  sudo npm install -g phantomjs-prebuilt
fi

if ask "Instalace Solr automaticky, port 8983" y; then
  wget -O tmp/solr-6.1.0.tgz http://default.vmweb.cz/install/solr-6.1.0.tgz
  cd tmp
  tar xzf solr-6.1.0.tgz solr-6.1.0/bin/install_solr_service.sh --strip-components=2
  sudo bash ./install_solr_service.sh solr-6.1.0.tgz
  sudo sed -i 's|name="jetty.host"|name="jetty.host" default="127.0.0.1"|g' /opt/solr/server/etc/jetty-http.xml
  rm tmp/solr-6.0.1.tgz
  rm tmp/install_solr_service.sh
  cd ..
  sudo chown -R solr:solr /var/solr
  sudo usermod -a -G solr $name
  sudo service solr restart
fi


if ask "Instalace Composer" y; then
  curl -sS https://getcomposer.org/installer | php
  sudo mv composer.phar /usr/local/bin/composer
  ln -s "/home/$name/.config/composer" "/home/$name/.composer"
  #sudo ln -s /usr/local/bin/composer /usr/bin/composer
fi

if ask "Nastaveni GitHub OAuth"; then
  read -p "Insert GitHub oAuth token, see: https://github.com/settings/tokens - " githubtoken
  composer config -g github-oauth.github.com $githubtoken
fi

if ask "Instalace Drupal Console pres Composer?" y; then
  composer global require drupal/console
  sudo ln -s "/home/$name/.composer/vendor/drupal/console/bin/drupal" /usr/local/bin/drupal
fi

if ask "Instalace Drush pres Composer?" y; then
  composer global require pear/Console_Color2
  composer global require drush/drush
  sudo ln -s "/home/$name/.composer/vendor/drush/drush/drush" /usr/local/bin/drush
  sudo ln -s "/home/$name/.composer/vendor/drush/drush/drush.complete.sh" /etc/bash_completion.d/
fi

if ask "Instalace Phing pres Composer?" y; then
  composer global require phing/phing
  sudo ln -s "/home/$name/.composer/vendor/phing/phing/bin/phing" /usr/local/bin/phing
fi

if ask "Instalace PHPUnit pres Composer?" y; then
  composer global require phpunit/phpunit
  sudo ln -s "/home/$name/.composer/vendor/phpunit/phpunit/bin/phpunit" /usr/local/bin/phpunit
fi

if ask "Instalace PHP_CF pres Composer?" y; then
  composer global require squizlabs/php_codesniffer
  sudo ln -s "/home/$name/.composer/vendor/squizlabs/php_codesniffer/scripts/phpcs" /usr/local/bin/phpcs
  sudo ln -s "/home/$name/.composer/vendor/squizlabs/php_codesniffer/scripts/phpcbf" /usr/local/bin/phpcbf
fi

if ask "Instalace Behat pres Composer?" y; then
  composer global require behat/behat
  sudo ln -s "/home/$name/.composer/vendor/behat/behat/bin/behat" /usr/local/bin/behat
fi

if ask "Kompilace twig library"; then
  cd "/home/$NAME/.composer/vendor/twig/twig/ext/twig"
  phpize
  ./configure
  make
  sudo make install
  cd $dir
  #https://github.com/twigphp/Twig/issues/1695 -> https://www.drupal.org/node/2568247
fi

ask "Zmena groups a prav /var/www - nedelat na serveru!"; then;
  sudo usermod -g www-data $name
  sudo usermod -a -G  $name $name
  sudo usermod -a -G sudo $name  # important!
  sudo chmod -R g+w /var/www
  sudo apt-get -y install acl
  sudo setfacl -d -m g::rwx /var/www
  sudo setfacl -d -m o::rx /var/www
  sudo chown -R www-data:www-data /var/www
fi

echo 'Vygeneruj si SSH klic prikazem: ssh-keygen -t rsa -b 4096 -C "your_email@example.com"'

if ask 'Change install repository to SSH?' y; then
  cd $dir
  git remote set-url origin git@github.com:vmwebCZ/virtual.git
fi

echo 'Vypada to, ze hotovo. Restartuj virtual, a instaluj VBox Additions'

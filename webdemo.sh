#!/bin/bash
source common.sh

if ask 'Running first time?'; then
  pause 'Vytvoreni drupal adresare'
  mkdir -p /var/www/drupal

  pause 'Vytvoreni mysql uzivatele demo'
  cd ~/virtual/webdemo
  mysql -u root "-p$mysqlpass"  < demo_user.sql

  pause 'Uprava hosts souboru pro demo weby'
  echo "" | sudo tee -a /etc/hosts
  echo "" | sudo tee -a /etc/hosts
  echo "# Demo sites" | sudo tee -a /etc/hosts
fi

if ask 'Instalace ukazkoveho webu D8' y; then
  cd ~/virtual
  cp webdemo/020-demo-d8.conf /etc/apache2/sites-available
  mkdir -p /var/www/drupal/demo-d8
  cd /var/www/drupal/demo-d8
  git init
  if ask 'Use SSH to github repository? No means HTTPS.' y; then
    git remote add origin git@github.com:vmwebCZ/demo-d8.git
  else
    git remote add origin https://github.com/vmwebCZ/demo-d8.git
  fi
  git pull origin master
  mysql -u demo -pdemo -Bse "drop database if exists demo_d8;"
  mysql -u demo -pdemo -Bse "create database demo_d8;"
  cp docroot/sites/default/default.settings.php docroot/sites/default/settings.php
  mkdir docroot/sites/default/files
  sudo a2ensite 020-demo-d8.conf
  echo "127.0.0.1	demo-d8.dev" | sudo tee -a /etc/hosts
fi


if ask 'Instalace ukazkoveho webu D7' y; then
  cd ~/virtual
  cp webdemo/020-demo-d7.conf /etc/apache2/sites-available
  mkdir -p /var/www/drupal/demo-d7
  cd /var/www/drupal/demo-d7
  if ask 'Use SSH to github repository? No means HTTPS.' y; then
    git init && git remote add origin git@github.com:vmwebCZ/demo-d7.git
  else
    git init && git remote add origin https://github.com/vmwebCZ/demo-d7.git
  fi
  git pull origin master
  mysql -u demo -pdemo -Bse "drop database if exists demo_d7;"
  mysql -u demo -pdemo -Bse "create database demo_d7;"
  cp docroot/sites/default/default.settings.php docroot/sites/default/settings.php
  mkdir docroot/sites/default/files
  sudo a2ensite 020-demo-d7.conf
  echo "127.0.0.1	demo-d7.dev" | sudo tee -a /etc/hosts
fi

if ask 'Instalace ukazkoveho webu Lightning project' y; then
  cd ~/virtual
  cp webdemo/020-demo-lightning.conf /etc/apache2/sites-available
  mkdir -p /var/www/drupal/demo-lightning
  cd /var/www/drupal/demo-lightning
  if ask 'Use SSH to github repository? No means HTTPS.' y; then
    git init && git remote add origin git@github.com:acquia/lightning-project.git
  else
    git init && git remote add origin https://github.com/acquia/lightning-project.git
  fi
  git pull origin 8.x
  mysql -u demo -pdemo -Bse "drop database if exists demo_lightning;"
  mysql -u demo -pdemo -Bse "create database demo_lightning;"
  composer install
  cp docroot/sites/default/default.settings.php docroot/sites/default/settings.php
  mkdir docroot/sites/default/files
  sudo a2ensite 020-demo-lightning.conf
  echo "127.0.0.1	demo-lightning.dev" | sudo tee -a /etc/hosts
fi


sudo service apache2 restart

echo 'Vypada to, ze hotovo.'

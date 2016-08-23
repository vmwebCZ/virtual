#!/bin/bash
source common.sh

pause 'Vytvoreni others adresare'
mkdir -p /var/www/others

pause 'Instalace webAdmin'
mysqlpass=`cat tmp/mysql.pass`
mkdir -p /var/www/admin

read -p "Insert HTTP username auth for administration sites ($name)" adminname
adminname=${adminname:-$name}
htpasswd -c /var/www/admin/.htpasswd $adminname

cd /var/www/admin
git init
if ask 'Use SSH to github repository? No means HTTPS.' y; then
  git remote add origin git@github.com:vmwebCZ/webadmin.git
else
  git remote add origin https://github.com/vmwebCZ/webadmin.git
fi
git pull origin master
cd /var/www/admin/pma
cp config.DEFAULT.inc.php config.inc.php
sudo sed -i "s|ROOTPASS|$mysqlpass|g" config.inc.php

cd sql
mysql -u root "-p$mysqlpass" -Bse "create database phpmyadmin;"
mysql -u root "-p$mysqlpass" phpmyadmin < create_tables.sql
cd /var/www/admin/memcache
mkdir Temp
cd $dir
cp webadmin/010-admin.conf /etc/apache2/sites-available
sudo a2ensite 010-admin.conf

pause 'Uprava hosts souboru pro webAdmin'
echo "" | sudo tee -a /etc/hosts
echo "" | sudo tee -a /etc/hosts
echo "# Admin sites" | sudo tee -a /etc/hosts
echo "127.0.0.1	pga.dev" | sudo tee -a /etc/hosts
echo "127.0.0.1	pma.dev" | sudo tee -a /etc/hosts
echo "127.0.0.1	admin.dev" | sudo tee -a /etc/hosts

sudo service apache2 restart

pause 'Vypada to, ze hotovo'

#!/bin/bash
source common.sh

domain=
while [[ $proddomain = "" ]]; do
  read -p "Insert domain without WWW (eg domain.com) " proddomain
done

read -p "Insert 3rd level subdomain (default = www) " subdomain
subdomain=${subdomain:-www}

defaultdevdomain="$( cut -d '.' -f 1 <<< "$proddomain" ).dev"
read -p "Insert development domain (default=$defaultdevdomain) " devdomain
devdomain=${devdomain:-$defaultdevdomain}

projectname="$proddomain-$subdomain"
projectdir="/var/www/drupal/$projectname"

echo "Project name: $projectname"
echo "Project dir: $projectdir"


defaultrepository="git@github.com:vmwebCZ/template-d8.git"
read -p "Repository url (default=$defaultrepository)" repository
mkdir -p $projectdir
cd $projectdir
git init
git remote add origin  $repository
git pull origin master
if [[ $repository = $defaultrepository ]]; then
  rm -rf .git
  git init
fi

mysqldb=
while [[ $mysqldb = "" ]]; do
  read -p "Insert database name, must contain underscore (eg customer_project) " mysqldb
done

cd $dir
mysqluser="$( cut -d '_' -f 1 <<< "$mysqldb" )"
mysqlcommand=$(cat project/new_user.sql | sed "s|USERNAME|$mysqluser|g");
mysql -u root "-p$mysqlpass" -Bse "DROP USER IF EXISTS '$mysqluser'@'localhost';"
mysql -u root "-p$mysqlpass" -Bse "$mysqlcommand"
mysql -u root "-p$mysqlpass" -Bse "drop database if exists $mysqldb;"
mysql -u root "-p$mysqlpass" -Bse "create database $mysqldb;"

conffile="/etc/apache2/sites-available/030-$projectname.conf"
sudo cp project/site.conf $conffile
sudo sed -i "s|PROJECT|$projectname|g" $conffile
sudo sed -i "s|DOMAIN|$devdomain|g" $conffile
if [[ $repository = $defaultrepository ]]; then
  docroot="/docroot"
else
  read -p "Drupal subdirectory in project root (default = none, for default repository use /docroot)" docroot
  sudo sed -i "s|/docroot|$docroot|g" $conffile
fi


sudo a2ensite "030-$projectname"
sudo service apache2 restart

echo "127.0.0.1	$devdomain" | sudo tee -a /etc/hosts

echo "All done."
echo "You should now do:"
echo "cd $projectdir"
echo "phing init"

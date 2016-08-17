#!/bin/bash
source common.sh

domain=
while [[ $proddomain = "" ]]; do
  read -p "Insert domain without WWW (eg domain.com)" proddomain
done

read -p "Insert 3rd level subdomain (default = www)" subdomain
subdomain=${reply:-www}

devdomain=
while [[ $devdomain = "" ]]; do
  read -p "Insert development domain - .dev will be appended" devdomain
done
devdomain="$devdomain.dev"

projectname="$proddomain-$subdomain"
projectdir="/var/www/drupal/$projectname"

echo "Project name: $projectname"
echo "Project dir: $projectdir"

mkdir -p $projectdir
cd $projectdir
git init
git remote add origin git@github.com:vmwebCZ/template-d8.git
git pull origin master
rm -rf .git
git init


mysqldatabase=
while [[ $mysqldatabase = "" ]]; do
  read -p "Insert database name, must contain underscore (eg customer_project)" mysqldatabase
done

mysqluser="$( cut -d '_' -f 1 <<< "$mysqldatabase" )"
mysqlcommand=$(cat addproject/new_user.sql | sed "s|demo|$mysqluser|g")

echo "mysql user: $mysqluser"
echo "mysql database: $mysqldatabase"
echo "mysql command: $mysqlcommand"

# create mysql user if needed
# drop mysql database if exists
# create mysql database

# cp apache2 site conf
# a2ensite
# write /etc/hosts

# phing init ?

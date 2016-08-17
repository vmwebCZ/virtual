#!/bin/bash
source common.sh

read -p "Insert full name (eg John Doe)" fullname
read -p "Insert username (eg johndoe)" username
read -p "Insert e-mail (eg john@doe.com)" email

sudo useradd -m -d "/home/$username" -c "$fullname" $username
sudo usermod -g www-data $username
sudo usermod -a -G $username $username
sudo usermod -a -G sudo $username  # important!
sudo usermod -a -G solr $username
if ask "Running virtualbox?"; then
  sudo usermod -a -G vboxsf $username
fi
sudo passwd $username


sudo su - $username -c "git config --global user.email $email"
sudo su - $username -c "git config --global user.name $fullname"
sudo su - $username -c "git config --global push.default current"

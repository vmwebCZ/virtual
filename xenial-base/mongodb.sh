#!/bin/bash
source common.sh

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update > /dev/null

pause 'Instalace MongoDB serveru'
sudo apt-get install -y mongodb-org php-mongodb

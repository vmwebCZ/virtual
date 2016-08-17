#!/bin/bash
source common.sh

sudo apt-get update > /dev/null

pause 'Instalace Postgresql serveru'
sudo apt-get install -y postgresql php-pgsql

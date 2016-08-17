#!/bin/bash

name=$(whoami)

mysqlpass=`cat tmp/mysql.pass`

function pause(){
   read -p "$* - Press [Enter] to continue..."
}

function ask(){
  if [[ $2 == y ]]; then
    read -i "Y" -p "$1 - [Y/n]" reply
    local REPLY=${reply:-Y}
  else
    read -i "N" -p "$1 - [y/N]" reply
    local REPLY=${reply:-N}
  fi

  if [[ $REPLY =~ ^(y|Y) ]]; then
    return 0
  else
    return 1
  fi
}

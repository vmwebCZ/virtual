#!/bin/bash
source common.sh

sudo apt-get update > /dev/null
#sudo apt-get purge -y unity-lens-friends
sudo apt-get purge -y unity-lens-photos unity-lens-video unity-lens-music
sudo apt-get purge -y unity-scope-colourlovers unity-scope-devhelp
sudo apt-get purge -y unity-scope-openclipart unity-scope-texdoc unity-scope-gdrive
sudo apt-get purge -y unity-scope-video-remote unity-scope-virtualbox unity-scope-yelp
sudo apt-get purge -y unity-scope-zotero unity-scope-tomboy unity-scope-manpages
sudo apt-get purge -y unity-scope-calculator unity-scope-chromiumbookmarks unity-scope-firefoxbookmarks
sudo apt-get purge -y account-plugin-facebook account-plugin-flickr account-plugin-jabber
sudo apt-get purge -y account-plugin-twitter account-plugin-yahoo account-plugin-salut
sudo apt-get purge -y webbrowser-app webapp-container unity-webapps-common
sudo apt-get purge -y gnome-disk-utility landscape*  apport*
sudo apt-get purge -y evolution-data-server-online-accounts
sudo apt-get purge -y ttf-indic-fonts* ttf-punja* fonts-takao* fonts-kacst*
sudo apt-get purge -y fonts-khmeros* fonts-tibetan* fonts-nanump* fonts-sil*
sudo apt-get purge -y fonts-thai* fonts-tlwg* fonts-lao* fonts-lklug*
sudo apt-get purge -y unity-control-center-signon
sudo apt-get purge -y aisleriot gnome-sudoku gnome-mines gnome-mahjongg
sudo apt-get purge -y gnome-orca baobab brasero*
sudo apt-get purge -y indicator-messages 
#sudo apt-get purge -y indicator-bluetooth indicator-sound
sudo apt-get purge -y totem* libtotem*
sudo apt-get purge -y rhythmbox* rhythmbox-mozilla rhythmbox-plugin*
sudo apt-get purge -y ubuntu-sounds
sudo apt-get purge -y transmission*
sudo apt-get purge -y ubuntuone* usb-creator*
sudo apt-get purge -y yelp gnome-user-guide ubuntu-docs

sudo apt-get purge -y checkbox*
#sudo apt-get purge -y cheese* libcheese*
sudo apt-get purge -y simple-scan hplip sane* libsane*
sudo apt-get purge -y printer-driver-foo2zjs*

sudo apt-get purge -y deja-dup

if ask "apt-get autoremove?" y; then
  sudo apt-get autoremove -y
fi

if ask "apt-get dist-upgrade?" y; then
  sudo apt-get dist-upgrade -y
fi

if ask "Purge old kernel?" y; then
  sudo apt-get purge -y linux-headers*4.4.0-21* linux-image*4.4.0-21*
fi

pause "Now restart and install VBox Guest Additions"

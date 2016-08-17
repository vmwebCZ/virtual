#!/bin/bash
source common.sh
mkdir -p tmp
sudo usermod -a -G vboxsf $name

sudo apt-add-repository -y ppa:libreoffice/libreoffice-5-2
sudo add-apt-repository -y ppa:alexx2000/doublecmd
sudo apt-get update > /dev/null

sudo apt-get install -y synaptic doublecmd-gtk gnome-system-tools

if ask "Install PgAdmin3" y; then
  sudo apt-get install -y pgadmin3
fi

if ask "Switch from Nautilus to Nemo?"; then
  sudo add-apt-repository -y ppa:webupd8team/nemo
  sudo apt-get update > /dev/null
  sudo apt-get install -y nemo nemo-fileroller
  sudo apt-get purge -y nautilus
fi

if ask 'Install Ubuntu tweak tools?'; then
  sudo apt-get install -y unity-tweak-tool dconf-tools
fi

if ask 'Install Adobe Flash?' y; then
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
  sudo apt-get install -y ubuntu-restricted-extras flashplugin-installer
elif ask 'Instal MS fonts?' y; then
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
  sudo apt-get install -y ttf-mscorefonts-installer
fi

if ask 'Install Adobe Reader 9?' y; then
  sudo apt-get install -y libgtk2.0-0:i386 libnss3-1d:i386 libnspr4-0d:i386 libxml2:i386 libxslt1.1:i386 libstdc++6:i386
  wget -O tmp/adobereader-enu.deb http://default.vmweb.cz/install/AdbeRdr9.5.5-1_i386linux_enu.deb
  sudo dpkg -i --force-depends tmp/adobereader-enu.deb
  rm tmp/adobereader-enu.deb
fi

if ask 'Install Chromium browser?' y; then
  sudo apt-get install -y libappindicator1
  sudo apt-get install -y chromium-browser chromium-browser-l10n
fi

if ask 'Install Google Chrome?' y; then
  sudo apt-get install -y libappindicator1
  wget -O tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i --force-depends tmp/google-chrome-stable_current_amd64.deb
  rm tmp/google-chrome-stable_current_amd64.deb
fi

if ask 'Install Vivaldi?' y; then
  sudo apt-get install -y libappindicator1
  wget -O tmp/vivaldi_amd64.deb https://downloads.vivaldi.com/stable/vivaldi-stable_1.3.551.30-1_amd64.deb
  sudo dpkg -i --force-depends tmp/vivaldi_amd64.deb
  rm tmp/vivaldi_amd64.deb
fi

if ask 'Instal Atom editor?' y; then
  sudo apt-get install -y gconf2
  wget -O tmp/atom-amd64.deb https://atom.io/download/deb
  sudo dpkg -i --force-depends tmp/atom-amd64.deb
  rm tmp/atom-amd64.deb

fi

if ask 'Instal NetBeans IDE?'; then
  wget -O tmp/netbeans.sh http://default.vmweb.cz/install/netbeans-8.1-php-linux-x64.sh
  chmod +x tmp/netbeans.sh
  sudo ./tmp/netbeans.sh
fi

if ask 'Install Gartoon icons?'; then
  sudo apt-get install -y gnome-icon-theme-gartoon-redux libswitch-perl
fi

if ask 'Install Diodon (clipboard manager)?' y; then
  sudo apt-get install -y diodon libdiodon0
fi

if ask 'Install indicator-multiload?' y; then
  sudo apt-get install -y indicator-multiload
  dconf load /de/mh21/indicator-multiload/ < ./xenial-desktop/indicator-multiload.bak
fi

if ask 'Fix numlock?' y; then
  sudo apt-get install -y numlockx
  sudo sed -i 's|^exit 0.*$|# Numlock enable\n[ -x /usr/bin/numlockx ] \&\& numlockx on\n\nexit 0|' /etc/rc.local

fi

if ask 'apt-get autoremove?' y; then
  sudo apt-get -y autoremove
fi

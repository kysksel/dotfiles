#!/bin/sh

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/sublimehq-archive.gpg
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

sudo apt update
sudo apt install -y sublime-text sublime-merge

echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf 
sudo sysctl -p

#!/bin/sh

sudo apt install --no-install-recommends --no-install-suggests gpg

wget -qO - https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive.gpg
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/sublimehq-archive.gpg

echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker-archive.gpg] https://download.docker.com/linux/debian bullseye stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update
sudo apt install sublime-text sublime-merge docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -aG docker $USER
newgrp docker

sudo systemctl disable docker.service
sudo systemctl disable containerd.service

cat <<EOF >> ~/.bashrc

alias 2mon='xrandr --auto --output VGA-1 --right-of LVDS-1'
alias 1mon='xrandr --auto'

alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
alias art='sail art'
alias npm='sail npm'
alias composer='sail composer'
EOF

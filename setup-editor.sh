#!/bin/sh

sudo apt install --no-install-recommends --no-install-suggests -y gpg

wget -qO - https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive.gpg
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/sublimehq-archive.gpg

echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker-archive.gpg] https://download.docker.com/linux/debian bullseye stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update
sudo apt install -y sublime-text sublime-merge docker-ce docker-ce-cli containerd.io docker-compose-plugin

wget https://github.com/beekeeper-studio/beekeeper-studio/releases/download/v3.6.2/Beekeeper-Studio-3.6.2.AppImage
sudo mkdir /opt/appimages
sudo mv Beekeeper-Studio-3.6.2.AppImage /opt/appimages
sudo chmod +x /opt/appimages/Beekeeper-Studio-3.6.2.AppImage
sudo ln -s /opt/appimages/Beekeeper-Studio-3.6.2.AppImage /bin/beekeeper

sudo usermod -aG docker $USER
newgrp docker

sudo systemctl disable docker.service
sudo systemctl disable containerd.service

echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf 
sudo sysctl -p

cat <<EOF >> ~/.bashrc

alias 1mon='xrandr --auto'
alias 2mon='1mon && xrandr --auto --output VGA-1 --right-of LVDS-1'

alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
alias art='sail art'
alias npm='sail npm'
alias composer='sail composer'
EOF

cd /opt/sublime_text || exit
md5sum -c <<<"FECA809A08FD89F63C7CB9DA23089967  sublime_text" || exit
echo 00385492: 48 31 C0 C3          | sudo xxd -r - sublime_text
echo 0037B675: 90 90 90 90 90       | sudo xxd -r - sublime_text
echo 0037B68B: 90 90 90 90 90       | sudo xxd -r - sublime_text
echo 00386F4F: 48 31 C0 48 FF C0 C3 | sudo xxd -r - sublime_text
echo 00385156: C3                   | sudo xxd -r - sublime_text
echo 0036EF50: C3                   | sudo xxd -r - sublime_text

cd /opt/sublime_merge || exit
md5sum -c <<<"189196010502F17EB99A38D8F64163BA  sublime_merge" || exit
echo 003CB652: 48 31 C0 C3             | sudo xxd -r - sublime_merge 
echo 003CE75D: 90 90 90 90 90          | sudo xxd -r - sublime_merge 
echo 003CE778: 90 90 90 90 90          | sudo xxd -r - sublime_merge 
echo 003CCC12: 48 31 C0 48 FF C0 C3    | sudo xxd -r - sublime_merge 
echo 003CB39E: C3                      | sudo xxd -r - sublime_merge 
echo 003CAFCE: C3                      | sudo xxd -r - sublime_merge

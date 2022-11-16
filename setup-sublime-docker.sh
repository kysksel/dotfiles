#!/bin/bash

wget -qO - https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive.gpg
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/sublimehq-archive.gpg

echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker-archive.gpg] https://download.docker.com/linux/debian bullseye stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update
sudo apt install -y sublime-text=4143 sublime-merge=2079 docker-ce docker-ce-cli containerd.io docker-compose-plugin

wget https://github.com/beekeeper-studio/beekeeper-studio/releases/download/v3.7.9/Beekeeper-Studio-3.7.9.AppImage
sudo mkdir /opt/appimages
sudo mv Beekeeper-Studio-3.7.9.AppImage /opt/appimages
sudo chmod +x /opt/appimages/Beekeeper-Studio-3.7.9.AppImage
sudo ln -s /opt/appimages/Beekeeper-Studio-3.7.9.AppImage /bin/beekeeper

sudo usermod -aG docker $USER

sudo systemctl disable docker.service
sudo systemctl disable containerd.service

echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf 
sudo sysctl -p

chmod +x sv
sudo cp sv /bin/sv

cat <<EOF >> ~/.bashrc

alias artisan='sv artisan'
alias art='sv art'
alias npm='sv npm'
alias node='sv node'
alias composer='docker run --rm --interactive --tty --volume "$PWD":/app  --user $(id -u):$(id -g) composer'

alias gi='git init && git add .'
alias gii='git init && git add . && git commit -m initial'
alias ga='git add'
alias gaa='git add .'
alias gc='gaa && git commit -m'
alias gs='git status'
alias gl='git log --oneline'
alias gp='git push -u origin main'
alias gr='git reset --hard && git clean -df'

EOF

cd /opt/sublime_text || exit
md5sum -c <<<"AFDEBB91F2BF42C9B491BAFD517C0A49  sublime_text" || exit
echo 003A31F2: 48 31 C0 C3          | sudo xxd -r - sublime_text
echo 00399387: 90 90 90 90 90       | sudo xxd -r - sublime_text
echo 0039939D: 90 90 90 90 90       | sudo xxd -r - sublime_text
echo 003A4E30: 48 31 C0 48 FF C0 C3 | sudo xxd -r - sublime_text
echo 003A2E82: C3                   | sudo xxd -r - sublime_text
echo 0038C9F0: C3                   | sudo xxd -r - sublime_text

cd /opt/sublime_merge || exit
md5sum -c <<<"F58AACE8B32B442949BAA9E59E09483E  sublime_merge" || exit
echo 003CC9BA: 48 31 C0 C3             | sudo xxd -r - sublime_merge
echo 003CF9DD: 90 90 90 90 90          | sudo xxd -r - sublime_merge
echo 003CF9F3: 90 90 90 90 90          | sudo xxd -r - sublime_merge
echo 003CDFA2: 48 31 C0 48 FF C0 C3    | sudo xxd -r - sublime_merge
echo 003CC6D2: C3                      | sudo xxd -r - sublime_merge
echo 003CC130: C3                      | sudo xxd -r - sublime_merge

#!/bin/bash

sudo apt install --no-install-recommends --no-install-suggests -y gpg

wget -qO - https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive.gpg
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/sublimehq-archive.gpg

echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker-archive.gpg] https://download.docker.com/linux/debian bullseye stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update
sudo apt install -y sublime-text=4126 sublime-merge=2077 docker-ce docker-ce-cli containerd.io docker-compose-plugin

wget https://github.com/beekeeper-studio/beekeeper-studio/releases/download/v3.6.2/Beekeeper-Studio-3.6.2.AppImage
sudo mkdir /opt/appimages
sudo mv Beekeeper-Studio-3.6.2.AppImage /opt/appimages
sudo chmod +x /opt/appimages/Beekeeper-Studio-3.6.2.AppImage
sudo ln -s /opt/appimages/Beekeeper-Studio-3.6.2.AppImage /bin/beekeeper

sudo usermod -aG docker $USER

sudo systemctl disable docker.service
sudo systemctl disable containerd.service

echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf 
sudo sysctl -p

cat <<EOF >> ~/.bashrc

alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
alias artisan='sail artisan'
alias art='sail art'
alias npm='sail npm'
alias node='sail node'
alias composer='sail composer'

alias gi='git init && git add . && git commit -m initial'
alias ga='git add'
alias gaa='git add .'
alias gc='gaa && git commit -m'
alias gs='git status'
alias gl='git log --oneline'
alias gp='git push -u origin/main'
alias gr='git reset --hard && git clean -df'

laravel() {
    docker info > /dev/null 2>&1

    # Ensure that Docker is running...
    if [ \$? -ne 0 ]; then
        echo "Docker is not running."

        exit 1
    fi

    docker run --rm --pull=always -v "\$(pwd)":/opt -w /opt laravelsail/php81-composer:latest bash -c "laravel new \$1 && cd \$1 && php ./artisan sail:install --with=mysql "

    cd \$1

    ./vendor/bin/sail pull mysql
    ./vendor/bin/sail build

    CYAN='\033[0;36m'
    LIGHT_CYAN='\033[1;36m'
    WHITE='\033[1;37m'
    NC='\033[0m'

    echo ""

    if sudo -n true 2>/dev/null; then
        sudo chown -R \$USER: .
        echo -e "\${WHITE}Get started with:\${NC} cd \$1 && ./vendor/bin/sail up"
    else
        echo -e "\${WHITE}Please provide your password so we can make some final adjustments to your application's permissions.\${NC}"
        echo ""
        sudo chown -R \$USER: .
        echo ""
        echo -e "\${WHITE}Thank you! We hope you build something incredible. Dive in with:\${NC} cd \$1 && ./vendor/bin/sail up"
    fi
}
EOF

cd /opt/sublime_text
md5sum -c <<<"FECA809A08FD89F63C7CB9DA23089967  sublime_text" || exit
echo 00385492: 48 31 C0 C3          | sudo xxd -r - sublime_text
echo 0037B675: 90 90 90 90 90       | sudo xxd -r - sublime_text
echo 0037B68B: 90 90 90 90 90       | sudo xxd -r - sublime_text
echo 00386F4F: 48 31 C0 48 FF C0 C3 | sudo xxd -r - sublime_text
echo 00385156: C3                   | sudo xxd -r - sublime_text
echo 0036EF50: C3                   | sudo xxd -r - sublime_text

cd /opt/sublime_merge
md5sum -c <<<"189196010502F17EB99A38D8F64163BA  sublime_merge" || exit
echo 003CB652: 48 31 C0 C3             | sudo xxd -r - sublime_merge 
echo 003CE75D: 90 90 90 90 90          | sudo xxd -r - sublime_merge 
echo 003CE778: 90 90 90 90 90          | sudo xxd -r - sublime_merge 
echo 003CCC12: 48 31 C0 48 FF C0 C3    | sudo xxd -r - sublime_merge 
echo 003CB39E: C3                      | sudo xxd -r - sublime_merge 
echo 003CAFCE: C3                      | sudo xxd -r - sublime_merge

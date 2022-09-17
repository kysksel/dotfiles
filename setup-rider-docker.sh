#!/bin/sh

sudo apt install --no-install-recommends --no-install-suggests -y gpg

wget -qO - https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker-archive.gpg] https://download.docker.com/linux/debian bullseye stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

wget https://download.jetbrains.com/rider/JetBrains.Rider-2022.2.3.tar.gz
sudo tar -xzf JetBrains.Rider-2022.2.3.tar.gz -C /opt
sudo mv "/opt/JetBrains Rider-2022.2.3" /opt/Rider-2022.2.3
sudo ln -s /opt/Rider-2022.2.3/bin/rider.sh /bin/rider

unzip useragent.zip
mv .useragent ~

echo "--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED" | sudo tee -a /opt/Rider-2022.2.3/bin/rider64.vmoptions
echo "--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED" | sudo tee -a /opt/Rider-2022.2.3/bin/rider64.vmoptions
echo "-javaagent:$HOME/.useragent/ja-netfilter.jar=jetbrains" | sudo tee -a /opt/Rider-2022.2.3/bin/rider64.vmoptions

sudo usermod -aG docker $USER
newgrp docker

sudo systemctl disable docker.service
sudo systemctl disable containerd.service

echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf 
sudo sysctl -p

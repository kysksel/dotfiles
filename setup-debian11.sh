#!/bin/sh

#Create Swapfile
sudo fallocate -l 2G /swapfile
# alternative if error
#sudo dd if=/dev/zero of=/swapfile bs=2048 count=1048576
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo free -h
# Make Permanent
# /swapfile swap swap defaults 0 0

# Remove unnecesarry package
sudo apt autoremove --purge -y blue* cups*

# Install Minimal Package
sudo apt install --no-install-recommends --no-install-suggests -y \
                 xserver-xorg-core xserver-xorg-video-intel \
                 xserver-xorg-input-libinput x11-xserver-utils \
                 x11-xkb-utils x11-utils xinit intel-microcode \
                 terminator i3 i3status feh lightdm \
                 lxappearance pulseaudio alsa-utils \
                 pavucontrol qt5ct pcmanfm ntfs-3g\
                 policykit-1-gnome xarchiver unzip unrar \
                 suckless-tools lightdm-settings stacer \
                 xfonts-base slick-greeter\
                 xfonts-scalable fonts-nanum \
                 breeze-icon-theme gnome-icon-theme vlc \
                 gnome-themes-extra p7zip-full desktop-base \
                 gvfs fuse3 fonts-firacode \
                 fonts-ubuntu gpg \
                 fonts-noto fonts-noto-cjk-extra fonts-noto-core \
                 fonts-noto-hinted fonts-noto-ui-core \
                 fonts-noto-unhinted fonts-noto-cjk fonts-noto-color-emoji \
                 fonts-noto-extra fonts-noto-mono fonts-noto-ui-extra
                 
sudo systemctl enable lightdm

# Set Profile
cat <<EOF >> ~/.profile

export QT_QPA_PLATFORMTHEME="qt5ct"
EOF

cat <<EOF >> ~/.bashrc

alias br0='echo 100000 | sudo tee /sys/class/backlight/intel_backlight/brightness'
alias br1='echo 0 | sudo tee /sys/class/backlight/acpi_video0/brightness  && echo 200000 | sudo tee /sys/class/backlight/intel_backlight/brightness'
alias br2='echo 1 | sudo tee /sys/class/backlight/acpi_video0/brightness  && echo 300000 | sudo tee /sys/class/backlight/intel_backlight/brightness'
alias br3='echo 2 | sudo tee /sys/class/backlight/acpi_video0/brightness  && echo 400000 | sudo tee /sys/class/backlight/intel_backlight/brightness'
alias br4='echo 3 | sudo tee /sys/class/backlight/acpi_video0/brightness  && echo 500000 | sudo tee /sys/class/backlight/intel_backlight/brightness'
alias br5='echo 4 | sudo tee /sys/class/backlight/acpi_video0/brightness  && echo 600000 | sudo tee /sys/class/backlight/intel_backlight/brightness'
alias br6='echo 5 | sudo tee /sys/class/backlight/acpi_video0/brightness  && echo 700000 | sudo tee /sys/class/backlight/intel_backlight/brightness'
alias br7='echo 6 | sudo tee /sys/class/backlight/acpi_video0/brightness  && echo 800000 | sudo tee /sys/class/backlight/intel_backlight/brightness'
alias br8='echo 7 | sudo tee /sys/class/backlight/acpi_video0/brightness  && echo 900000 | sudo tee /sys/class/backlight/intel_backlight/brightness'
alias 1mon='xrandr --auto'
alias 2mon='1mon && xrandr --auto --output VGA-1 --right-of LVDS-1'
alias br20='xrandr --output VGA-1 --brightness 0.6'
alias br21='xrandr --output VGA-1 --brightness 1'
EOF

# Set i3WM
mkdir -p ~/.config/i3
mkdir -p ~/.config/qt5ct/colors
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/terminator
cp i3config ~/.config/i3/config
cp i3status ~/.config/i3/status
cp bg.png ~/.config/i3/bg.png
cp qt5color ~/.config/qt5ct/colors/Dracula.conf
cp qt5config ~/.config/qt5ct/qt5ct.conf
cp settings.ini ~/.config/gtk-3.0
cp terminator ~/.config/terminator/config

# Install Google Chrome
#wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#sudo apt install -y ./google-chrome-stable_current_amd64.deb
sudo apt install -y chromium
echo "chromium --force-dark-mode" | sudo tee /bin/chrome
sudo chmod +x /bin/chrome

# Set Themes and Icons
mkdir -p ~/.themes
mkdir -p ~/.icons
mkdir -p ~/.fonts
wget -O themes.zip https://github.com/dracula/gtk/archive/master.zip
wget -O icons.zip https://github.com/dracula/gtk/files/5214870/Dracula.zip
unzip themes.zip -d ~/.themes
unzip icons.zip -d ~/.icons
tar -xf fonts.tar.xz -C ~/.fonts
mv ~/.themes/gtk-master ~/.themes/Dracula

sudo cp rc.local /etc/
sudo chmod +x /etc/rc.local
sudo systemctl daemon-reload
sudo systemctl start rc-local
sudo systemctl status rc-local

git config --global init.defaultBranch main

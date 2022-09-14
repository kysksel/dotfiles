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
sudo apt autoremove --purge blue* cups*

# Install Minimal Package
sudo apt install --no-install-recommends --no-install-suggests \
                 xserver-xorg-core xserver-xorg-video-intel \
                 xserver-xorg-input-all xserver-xorg-input-libinput \
                 x11-xserver-utils x11-xkb-utils x11-utils xinit \
                 intel-microcode terminator i3 i3status feh lightdm \
                 slick-greeter lxappearance pulseaudio alsa-utils \
                 pavucontrol qt5ct pcmanfm ntfs-3g\
                 policykit-1-gnome xarchiver unzip unrar \
                 suckless-tools lightdm-settings stacer
sudo apt install fonts-noto fonts-nanum arc-theme papirus-icon-theme \
                 breeze-icon-theme  gnome-icon-theme
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
EOF

# Set i3WM
mkdir -p ~/.config/i3
mkdir -p ~/.config/qt5ct/colors
mkdir -p ~/.config/gtk-3.0
cp i3config ~/.config/i3/config
cp i3status ~/.config/i3/status
cp bg.png ~/.config/i3/bg.png
cp qt5color ~/.config/qt5ct/colors/Dracula.conf
cp qt5config ~/.config/qt5ct/qt5ct.conf
cp settings.ini ~/.config/gtk-3.0

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
echo "google-chrome-stable --force-dark-mode" | sudo tee /bin/google
sudo chmod +x /bin/google

# Set Themes and Icons
mkdir -p ~/.themes
mkdir -p ~/.icons
mkdir -p ~/.fonts
wget -O themes.zip https://github.com/dracula/gtk/archive/master.zip
wget -O icons.zip https://github.com/dracula/gtk/files/5214870/Dracula.zip
wget -O fonts.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/JetBrainsMono.zip
unzip themes.zip -d ~/.themes
unzip icons.zip -d ~/.icons
unzip fonts.zip -d ~/.fonts
mv ~/.themes/gtk-master ~/.themes/Dracula

sudo cp rc.local /etc/
sudo chmod +x /etc/rc.local
sudo systemctl daemon-reload
sudo systemctl start rc-local
sudo systemctl status rc-local

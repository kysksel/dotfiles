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
                 pavucontrol network-manager qt5ct pcmanfm \
                 policykit-1-gnome xarchiver unzip unrar \
                 suckless-tools git lightdm-settings stacer
sudo apt install fonts-noto fonts-nanum arc-theme
sudo systemctl enable lightdm

# Set Profile
cat <<EOF >> ~/.profile

export QT_QPA_PLATFORMTHEME="qt5ct"

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
mkdir -p ~/.config/i3/{i3status,background}/
mkdir -p ~/.config/qt5ct/colors/
cp i3config ~/.config/i3/config
cp i3status ~/.config/i3/i3status/config
cp bg.png ~/.config/i3/background
cp qt5config ~/.config/qt5ct/colors/Dracula.conf

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
echo "google-chrome-stable --force-dark-mode" | sudo tee /bin/google
sudo chmod +x /bin/google

# Set Themes and Icons
mkdir -p ~/.local/share/{icons,themes}/
wget -O themes.zip https://github.com/dracula/gtk/archive/master.zip
wget -O icons.zip https://github.com/dracula/gtk/files/5214870/Dracula.zip
unzip themes.zip -d ~/.local/share/themes
unzip icons.zip -d ~/.local/share/icons
mv ~/.local/share/themes/gtk-master ~/.local/share/themes/Dracula

sudo cp rc.local /etc/
sudo systemctl daemon-reload
sudo systemctl start rc-local
sudo systemctl status rc-local

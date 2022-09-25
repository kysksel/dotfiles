#!/bin/sh

cp i3config ~/.config/i3/config
cp i3status ~/.config/i3/status
#cp bg.png ~/.config/i3/bg.png
#cp qt5color ~/.config/qt5ct/colors/Dracula.conf
#cp qt5config ~/.config/qt5ct/qt5ct.conf
#cp settings.ini ~/.config/gtk-3.0
#cp terminator ~/.config/terminator/config

sudo systemctl disable console-setup.service
sudo systemctl disable keyboard-setup.service 

mode "Exit (L)ogout, (R)eboot, (P)oweroff" {
        bindsym r exec systemctl reboot
        bindsym l exit
        bindsym p exec systemctl poweroff

        # back to normal: Enter or Escape
        bindsym Return mode "default"
        bindsym Escape mode "default"
}

mode "(Sublime (Merge (Terminal" {
        bindsym S exec subl
        bindsym M exec smerge
        bindsym T exec terminator

        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym F1 mode "default"
}

bindsym F1 mode "(Sublime (Merge (Terminal"

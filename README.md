# Kellegram's Xmonad and Xmobar config

## Fedora cleanup
### Remove pre-installed WMs
    sudo dnf remove openbox qtile ratpoison awesome i3  
### Remove picom in case it's already installed
    sudo dnf remove picom

## Requirements
### Add RPM Fusion repos
https://rpmfusion.org/Configuration

### Install trayer
        

    1. Add RPM Fusion repositories to your system
    
    2. Download latest rpmsphere-release rpm from
    https://github.com/rpmsphere/noarch/tree/master/r

    3. Install rpmsphere-release rpm:

    # rpm -Uvh rpmsphere-release*rpm

    4. Install trayer rpm package:

    # dnf install trayer

### Install xmonad and related programs
    sudo dnf install cabal-install ghc xdg-user-dirs xdg-utils xmonad ghc-xmonad-contrib dmenu xdotool feh kitty nautilus



### Install most of the apps I use, including some in the config
    sudo dnf install light network-manager-applet blueman volumeicon obs-studio cmus vlc xmonad ghc-xmonad-contrib dmenu rofi git pavucontrol lxappearance tar flameshot code starship kitty 

### Pull the libraries needed to compile xmobar and the picom fork
    $ sudo dnf install dbus-devel pcre-devel libGL-devel libconfig-devel uthash-devel pixman-devel xcb-util-renderutil-devel libev-devel cmake meson alsa-lib-devel libXpm-devel make automake gcc gcc-c++ kernel-devel
    
    $ sudo dnf grpup install "C Development Tools and Libraries" 
    $ sudo dnf install @development-tools


### Pull my config
It should be put into the home directory. Remember to 'chmod +x' the trayer padding script found in ~/.config/xmobar/





Wallpapers:
https://wallhaven.cc/w/j5qlky
https://wallhaven.cc/w/zm1lrg
https://wallhaven.cc/w/13zzg9
https://wallhaven.cc/w/96llgx
https://wallhaven.cc/w/96l288
https://wallhaven.cc/w/2exmm9

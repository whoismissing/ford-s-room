#!/bin/bash
# Linux install script tested successfully on Ubuntu 18.04.1 LTS
# Usage: sudo bash ./linux_post_install.sh

# Terminate on any error
set -e

update_and_upgrade() {
    apt-get update
    apt-get upgrade
}

# exFAT USB support
install_exfat() {
    apt-get install exfat-fuse exfat-utils -y
}

# i3 window manager
install_i3() {
    apt install i3 feh -y
    # echo "exec --no-startup-id /usr/bin/feh --bg-scale ~/Pictures/desktop2.jpg" >> ~/.config/i3/config
}

install_term_tools() {
    apt install tmux screen git openvpn tlp vim curl -y
}

install_graphics_tools() {
    apt install inkscape -y
}

install_wireshark() {
    # ask for username

    apt install wireshark -y
    usermod -aG wireshark $username
}

install_brave_browser() {
    curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key add -

    source /etc/os-release

    echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/brave-browser-release-${UBUNTU_CODENAME}.list

    sudo apt update

    sudo apt install brave-browser brave-keyring
}

install_vbox() {
    echo "deb https://download.virtualbox.org/virtualbox/debian bionic contrib" >> /etc/apt/sources.list
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install virtualbox-6.0 # virtualbox-6.0
}

install_spotify() {
    apt install snap
    snap install spotify
}

install_sublime() {
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    sudo apt-get install apt-transport-https
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt-get update && sudo apt-get install sublime-text

}


download_desktop_debs() {
    # vscode deb
    wget https://go.microsoft.com/fwlink/?LinkID=760868

    # discord deb
    wget https://discordapp.com/api/download?platform=linux&format=deb

    # cherrytree deb
    wget http://www.giuspen.com/software/cherrytree_0.38.7-0_all.deb
}

download_r2_cutter() {
    wget https://github.com/radareorg/cutter/releases/download/v1.7.4/Cutter-v1.7.4-x64.Linux.AppImage
    chmod +x Cutter-v1.7.4-x64.Linux.AppImage
}

install_ctf_tools() {
    echo "Installing ctf tools"
    # install gcc 32-bit
    # install peda | gef | pwndbg
}

set_vimrc() {
    echo "syntax enable" > ~/.vimrc
    echo "set tabstop=4" >> ~/.vimrc
    echo "set softtabstop=4" >> ~/.vimrc
    echo "set expandtab" >> ~/.vimrc
    echo "set number" >> ~/.vimrc
    echo "set showcmd" >> ~/.vimrc
    echo "set cursorline" >> ~/.vimrc
    echo "set incsearch" >> ~/.vimrc
    echo "set hlsearch" >> ~/.vimrc
    echo "set shiftwidth=4" >> ~/.vimrc
}

get_cmdfu() {
    echo "Adding cmdfu to bashrc"
}

# reminder to get darkreader and lastpass browser extensions

main() {
    update_and_upgrade
    install_exfat
    install_i3
    install_term_tools
    install_graphics_tools

    ##install_wireshark

    install_brave_browser
    install_vbox
    install_spotify
    install_sublime

    download_desktop_debs
    download_r2_cutter

    ##install_ctf_tools

    set_vimrc

    ##get_cmdfu
}

main

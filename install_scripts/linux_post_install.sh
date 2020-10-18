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
    apt install tmux screen git openvpn tlp vim curl guake -y
}

install_graphics_tools() {
    apt install inkscape kazam -y
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
    sudo apt-get install virtualbox-6.0 # virtualbox-5.2
}

install_docker() {
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    sudo apt update
    sudo apt install docker-ce
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

download_ghidra() {
    wget https://ghidra-sre.org/ghidra_9.0_PUBLIC_20190228.zip
    unzip ghidra*.zip -d /opt/
    sudo apt install openjdk-11-jre-headless
    # Get JDK 11.0.2 deb
    # https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html
    # http://download.oracle.com/otn-pub/java/jdk/11.0.2+9/f51449fcd52f4d52b93a989c5c56ed3c/jdk-11.0.2_linux-x64_bin.deb
    # Get JDK 12 zips
    # https://www.oracle.com/technetwork/java/javase/downloads/jdk12-downloads-5295953.html
    export PATH=$PATH:jdk-11.0.3/bin/
}

install_32_bit_support() {
    sudo dpkg --add-architecture i386
    sudo apt-get update
    # install gcc 32-bit
    sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386
    sudo apt-get install multiarch-support
}

install_peda() {
    sudo apt-get install git
    git clone https://github.com/longld/peda.git ~/peda
    echo "source ~/peda/peda.py" >> ~/.gdbinit
}

install_gef() {
    wget -O ~/.gdbinit-gef.py -q https://github.com/hugsy/gef/raw/master/gef.py
    echo source ~/.gdbinit-gef.py >> ~/.gdbinit
}

install_ctf_tools() {
    echo "Installing ctf tools"
    install_32_bit_support
    # install peda | gef | pwndbg
    # install_peda
    install_gef
}

install_typora() {
    wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -

    # add Typora's repository
    sudo add-apt-repository 'deb https://typora.io/linux ./'
    sudo apt-get update -y

    # install typora
    sudo apt-get install typora -y
}

install_source_code_tools() {
    sudo apt-get install ctags zeal -y

    # Get sourcetrail appimage
    wget https://github.com/CoatiSoftware/Sourcetrail/releases/download/2020.1.117/Sourcetrail_2020_1_117_Linux_64bit.AppImage
}

install_python3_pip() {
    sudo apt-get install python3 python3-dev python3-pip -y
    pip install pyvenv --user
}

install_pwntools() {
    apt-get update
    apt-get install python3 python3-pip python3-dev git libssl-dev libffi-dev build-essential
    python3 -m pip install --upgrade pip
    python3 -m pip install --upgrade git+https://github.com/Gallopsled/pwntools.git@dev
}

install_golang() {
    wget https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.14.2.linux-amd64.tar.gz

    # Add path to bashrc
    # export PATH=$PATH:/usr/local/go/bin
}

set_tmux_conf() {
    echo "setw -g mode-keys vi" > ~/.tmux.conf
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
    echo 'cmdfu(){ curl "https://www.commandlinefu.com/commands/matching/$@/$(echo -n $@ | openssl base64)/plaintext"; }' >> .bashrc
}

# reminder to get darkreader and lastpass browser extensions

main() {
    #update_and_upgrade
    #install_exfat
    #install_i3
    #install_term_tools
    #install_graphics_tools

    ##install_wireshark

    #install_brave_browser
    #install_vbox
    #install_docker
    #install_spotify
    #install_sublime

    #download_desktop_debs
    #download_r2_cutter

    install_ctf_tools

    #set_vimrc

    ##get_cmdfu
}

main

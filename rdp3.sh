#!/bin/bash

# Colors
RED='\e[31m'
GREEN='\e[32m'
BLUE='\e[34m'
YELLOW='\e[33m'
RESET='\e[0m'

# ASCII Art
clear
echo -e "${YELLOW}🚀 Welcome to the Chrome Remote Desktop Installer! 🚀${RESET}"
echo -e "${GREEN}=============================================${RESET}"
echo -e "${BLUE}  ____ _                                _    "
echo -e "${BLUE} / ___| |__   ___  ___  ___  _ __   ___| |_  "
echo -e "${BLUE}| |   | '_ \ / _ \/ __|/ _ \| '_ \ / _ \ __| "
echo -e "${BLUE}| |___| | | |  __/\__ \ (_) | | | |  __/ |_  "
echo -e "${BLUE} \____|_| |_|\___||___/\___/|_| |_|\___|\__| "
echo -e "${GREEN}=============================================${RESET}"

# Guide to get CRP
echo -e "${GREEN}🔹 To get your Chrome Remote Desktop Code (CRP):${RESET}"
echo -e "${YELLOW}1. Open Google Chrome and go to: https://remotedesktop.google.com/access${RESET}"
echo -e "${YELLOW}2. Sign in with your Google account.${RESET}"
echo -e "${YELLOW}3. Click on 'Set up another computer'.${RESET}"
echo -e "${YELLOW}4. Install the Chrome Remote Desktop Host if prompted.${RESET}"
echo -e "${YELLOW}5. Click 'Generate Code' and copy the CRP.${RESET}"

# Ask for CRP
read -p "🔑 Enter your Chrome Remote Desktop Code (CRP): " crp

# Set default values
username="user"
password="root"
chrome_remote_desktop_url="https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb"

# Function to log messages
log() {
    echo -e "${YELLOW}$(date +'%Y-%m-%d %H:%M:%S') - $1${RESET}"
}

# Function to install packages
install_package() {
    package_url=$1
    log "📥 Downloading $package_url"
    wget -q --show-progress "$package_url"
    log "📦 Installing $(basename $package_url)"
    sudo dpkg --install $(basename $package_url)
    log "🔧 Fixing broken dependencies"
    sudo apt-get install --fix-broken -y
    rm $(basename $package_url)
}

# Installation steps
log "🚀 Starting installation"

# Create user
log "👤 Creating user '$username'"
sudo useradd -m "$username"
echo "$username:$password" | sudo chpasswd
sudo sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd

# Install Chrome Remote Desktop
install_package "$chrome_remote_desktop_url"

# Install XFCE desktop environment
log "🎨 Installing XFCE desktop environment"
sudo DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes -y xfce4 desktop-base dbus-x11 xscreensaver

# Set up Chrome Remote Desktop session
log "🖥️ Setting up Chrome Remote Desktop session"
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'

# Disable lightdm service
log "⛔ Disabling lightdm service"
sudo systemctl disable lightdm.service

# Install Firefox ESR
log "🔥 Installing Firefox ESR"
sudo apt update
sudo add-apt-repository ppa:mozillateam/ppa
sudo apt update
sudo apt install firefox-esr -y

# Start Chrome Remote Desktop
log "🚀 Starting Chrome Remote Desktop"
DISPLAY=":1" /opt/google/chrome-remote-desktop/start-host --code="$crp" &

log "✅ Installation completed successfully! 🎉 Enjoy your remote desktop!"

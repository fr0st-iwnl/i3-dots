#!/bin/bash
set -e

# -----------------------------
# Variables
# -----------------------------
CONFIG_REPO="$HOME/i3-dots"
WALLPAPER_ZIP="$HOME/wallz.zip"
SH_TOOLBOX_DIR="$HOME/sh-toolbox"
USER_NAME="$USER"  # Current logged-in user

# -----------------------------
# Update system
# -----------------------------
echo "==> Updating system..."
sudo pacman -Syu --noconfirm

# -----------------------------
# Install base packages
# -----------------------------
echo "==> Installing base packages..."
sudo pacman -S --noconfirm --needed \
    xdg-user-dirs xfce4-settings dunst libnotify \
    vim git feh picom xcompmgr pacman-contrib \
    lxappearance orchis-theme autotiling unzip file-roller \
    rofi firefox kitty thunar polybar nerd-fonts fastfetch \
    pavucontrol i3-wm i3status

# -----------------------------
# Set up user directories
# -----------------------------
echo "==> Setting up user directories..."
xdg-user-dirs-update

# -----------------------------
# Download and extract wallpapers
# -----------------------------
echo "==> Downloading wallpapers..."
curl -L -o "$WALLPAPER_ZIP" https://github.com/fr0st-iwnl/wallz/releases/latest/download/wallz.zip

echo "==> Extracting wallpapers..."
mkdir -p "$HOME/Pictures/wallpapers"
unzip -o "$WALLPAPER_ZIP" -d "$HOME/Pictures/wallpapers" > /dev/null 2>&1 || true
rm "$WALLPAPER_ZIP"

# -----------------------------
# Install paru (AUR helper)
# -----------------------------
if ! command -v paru &> /dev/null; then
    echo "==> Installing paru..."
    sudo pacman -S --noconfirm --needed base-devel
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd -
fi

# -----------------------------
# Install AUR packages (fix conflicts)
# -----------------------------
echo "==> Installing AUR packages..."
paru -S --noconfirm --needed i3lock-color betterlockscreen vscodium-bin

# -----------------------------
# Set up .config
# -----------------------------
echo "==> Setting up .config..."
if [ ! -d "$CONFIG_REPO" ]; then
    git clone https://github.com/fr0st-iwnl/i3-dots.git "$CONFIG_REPO"
fi

for config in "$CONFIG_REPO/.config/"*; do
    dest="$HOME/.config/$(basename $config)"
    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest"
    ln -s "$config" "$dest"
done

# -----------------------------
# Install sh-toolbox
# -----------------------------
echo "==> Installing sh-toolbox..."
if [ ! -d "$SH_TOOLBOX_DIR" ]; then
    git clone https://github.com/fr0st-iwnl/sh-toolbox.git "$SH_TOOLBOX_DIR"
fi
cd "$SH_TOOLBOX_DIR"
chmod +x sh-toolbox.sh

# Run sh-toolbox installer
yes "" | ./sh-toolbox.sh -i

# Install sxhkd required for keybind
echo "==> Installing sxhkd for keybindings..."
sudo pacman -S --noconfirm sxhkd

# Source bashrc to refresh environment
source ~/.bashrc

# Run keybind startup and automatically choose 1
echo "1" | ./sh-toolbox.sh --keybind startup


# -----------------------------
# Install and configure LightDM
# -----------------------------
echo "==> Installing LightDM..."
sudo pacman -S --noconfirm --needed lightdm lightdm-gtk-greeter

echo "==> Enabling LightDM to start on boot..."
sudo systemctl enable lightdm.service

echo "==> Configuring auto-login for user $USER_NAME..."
sudo mkdir -p /etc/lightdm/lightdm.conf.d
echo -e "[Seat:*]\nautologin-user=$USER_NAME\nautologin-session=i3" | sudo tee /etc/lightdm/lightdm.conf.d/50-autologin.conf

echo "==> Installation complete! Reboot your system and it will start directly into i3."

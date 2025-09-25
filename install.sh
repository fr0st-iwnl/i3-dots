# what i installed atm


sudo pacman -S xdg-user-dirs
sudo pacman -S xfce4-settings
xdg-user-dirs-update
sudo pacman -S vim
sudo pacman -S git
sudo pacman -S feh
sudo pacman -S lxappearance
sudo pacman -S orchis-theme
sudo pacman -S unzip
sudo pacman -S rofi
sudo pacman -S firefox
sudo pacman -S kitty
sudo pacman -S thunar
sudo pacman -S polybar
sudo pacman -S nerd-fonts


# install paru

sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# install packages with paru
paru -S vscodium-bin
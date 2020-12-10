#!/bin/sh

# Install AUR helper
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
yay -Syu yay

# Install all the applications in packages.txt
while read pkg
	do yay -S $pkg
done < packages.txt

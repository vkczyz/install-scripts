#!/bin/sh

cd $(dirname $0)

timedatectl set-ntp true && echo "System time synchronized!"

./install-pkgs.sh
./improve-fonts.sh
./get-dotfiles.sh

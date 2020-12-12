#!/bin/sh

# Record information about the system
hostname=host
root_disk=/dev/sda
vendor=$(cat /proc/cpuinfo | grep vendor_id | uniq | cut -d ' ' -f 2)

# Pre-install setup
timedatectl set-ntp true && echo "System time synchronized!"

# TODO: disk partitioning

# Format and mount partitions
# TODO: don't hardcode partition numbers
mkfs.fat -F 32 /dev/$(root_disk)1	# boot partition
mkfs.ext4 /dev/$(root_disk)2	# root partition
mkfs.ext4 /dev/$(root_disk)3	# home partition
mount /dev/$(root_disk)2 /mnt
mkdir /mnt/boot; mount /dev/$(root_disk)1 /mnt/boot
mkdir /mnt/home; mount /dev/$(root_disk)3 /mnt/home

# System preparation
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

# Set up the new environment
arch-chroot /mnt
$(dirname $0)/install-pkgs.sh
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
locale-gen
echo 'LANG=en_GB.UTF-8' >> /etc/locale.conf
echo 'KEYMAP=uk' >> /etc/vconsole.conf
echo '127.0.0.1	localhost\n::1		localhost\n127.0.1.1	"$hostname".localdomain "$hostname"' >> /etc/hosts

# Enable services
systemctl enable nftables.service
systemctl enable NetworkManager.service
systemctl enable cups.socket

# Run non-essential but useful scripts
$(dirname $0)/improve-fonts.sh

# Replace mkinitcpio with dracut
dracut /boot/initramfs-linux.img
dracut -N /boot/initramfs-linux-fallback.img
pacman -Rs mkinitcpio

passwd

# Install microcode for the appropriate vendor
case $vendor in 
	AuthenticAMD)
		pacman -S amd-ucode
		;;
	GenuineIntel)
		pacman -S intel-ucode
		;;
esac

# TODO: set up EFISTUB booting

# Finish up
exit
umount -R /mnt
reboot

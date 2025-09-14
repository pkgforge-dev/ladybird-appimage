#!/bin/sh

set -eux

deps="base-devel wget mesa file zsync appstream xorg-server-xvfb patchelf binutils strace git ladybird"

pacman-key --init

#Setup Chaotic AUR
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB

pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm

CONFIG="[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist"

if grep -q "$$chaotic-aur$$" /etc/pacman.conf; then
	echo "The [chaotic-aur] section already exists in /etc/pacman.conf."
else
	echo "$CONFIG" | tee -a /etc/pacman.conf >/dev/null
	echo "Configuration added to /etc/pacman.conf."
fi

pacman -Syuq --needed --noconfirm --noprogressbar $deps

GH_BASE="https://github.com"
GH_USER_CONTENT="https://raw.githubusercontent.com"

DEBLOATED_PKGS="${GH_USER_CONTENT}/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"
SHARUN="${GH_USER_CONTENT}/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
URUNTIME="${GH_USER_CONTENT}/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"

wget "${DEBLOATED_PKGS}" -O /tmp/get-debloated-pkgs.sh
chmod a+x /tmp/get-debloated-pkgs.sh
sh /tmp/get-debloated-pkgs.sh --add-opengl --prefer-nano libxml2-mini gtk3-mini opus-mini qt6-base-mini

wget "${SHARUN}" -O quick-sharun
chmod +x quick-sharun

wget "${URUNTIME}" -O uruntime2appimage
chmod +x uruntime2appimage

pacman -Scc --noconfirm

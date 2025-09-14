#!/bin/sh

set -eux

rm -rf AppDir dist

ARCH="$(uname -m)"
VERSION="$(pacman -Q ladybird-git 2>/dev/null | awk '{print $2}')"

export ADD_HOOKS="self-updater.bg.hook"
export DEPLOY_OPENGL=1
export DESKTOP="/opt/ladybird/usr/share/applications/org.ladybird.Ladybird.desktop"
export EXEC_WRAPPER=1
export ICON="/opt/ladybird/usr/share/icons/hicolor/scalable/apps/org.ladybird.Ladybird.svg"
export OUTNAME="Ladybird-${VERSION}-${ARCH}.AppImage"
export UPINFO="gh-releases-zsync|$(echo "${GITHUB_REPOSITORY}" | tr '/' '|')|latest|Ladybird-*$ARCH.AppImage.zsync"
export URUNTIME_PRELOAD=1

./quick-sharun \
	/opt/ladybird/usr/bin/* \
	/opt/ladybird/usr/lib/* \
	/opt/ladybird/usr/lib/ladybird/* \
	/opt/angle/usr/lib/*

mv -v ./AppDir/lib/angle/usr/lib/* ./AppDir/lib
cp -rv /opt/ladybird/usr/share/* ./AppDir/share
./uruntime2appimage

mkdir -p ./dist
mv -v ./*.AppImage* ./dist

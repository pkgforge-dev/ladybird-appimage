#!/bin/sh

set -eux

ARCH="$(uname -m)"
VERSION="$(/opt/ladybird/usr/bin/Ladybird --version | awk '{print $2}')"

export UPINFO="gh-releases-zsync|$(echo "${GITHUB_REPOSITORY}" | tr '/' '|')|latest|Ladybird-*$ARCH.AppImage.zsync"
export URUNTIME_PRELOAD=1
export DEPLOY_OPENGL=1
export EXEC_WRAPPER=1
export OUTNAME="Ladybird-${VERSION}-${ARCH}.AppImage"
export DESKTOP="/opt/ladybird/usr/share/applications/org.ladybird.Ladybird.desktop"
export ICON="/opt/ladybird/usr/share/icons/hicolor/scalable/apps/org.ladybird.Ladybird.svg"

./quick-sharun /opt/ladybird/usr/bin/Ladybird /opt/angle/usr/lib/*
./uruntime2appimage

mkdir -p ./dist
mv -v ./*.AppImage* ./dist

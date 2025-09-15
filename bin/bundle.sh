#!/bin/sh

set -eux

rm -rf AppDir dist

ARCH="$(uname -m)"
VERSION="$(pacman -Q ladybird-git 2>/dev/null | awk '{print $2}')"

export UPINFO="gh-releases-zsync|$(echo "${GITHUB_REPOSITORY}" | tr '/' '|')|latest|Ladybird-*$ARCH.AppImage.zsync"
export URUNTIME_PRELOAD=1
export DEPLOY_OPENGL=1
export EXEC_WRAPPER=1
export OUTNAME="Ladybird-${VERSION}-anylinux-${ARCH}"
export DESKTOP="/opt/ladybird/usr/share/applications/org.ladybird.Ladybird.desktop"
export ICON="/opt/ladybird/usr/share/icons/hicolor/scalable/apps/org.ladybird.Ladybird.svg"

./quick-sharun \
	/opt/ladybird/usr/bin/* \
	/opt/ladybird/usr/lib/* \
	/opt/ladybird/usr/lib/ladybird/* \
	/opt/angle/usr/lib/*

mv -v ./AppDir/lib/angle/usr/lib/* ./AppDir/lib
cp -rv /opt/ladybird/usr/share/* ./AppDir/share
OUTNAME="$OUTNAME.AppImage" ./uruntime2appimage

echo "Generating [dwfs]AppBundle..."
UPINFO="gh-releases-zsync|$(echo "${GITHUB_REPOSITORY}" | tr '/' '|')|latest|Ladybird-*$ARCH.dwfs.AppBundle.zsync"
OUTNAME="$OUTNAME.dwfs.AppBundle"
./pelf --add-appdir ./AppDir                  \
	--appimage-compat                         \
	--disable-use-random-workdir              \
	--add-updinfo "$UPINFO"                   \
	--compression "-C zstd:level=22 -S26 -B8" \
	--appbundle-id="org.ladybirdbrowser.ladybird#github.com/$GITHUB_REPOSITORY:$VERSION@$(date +%d_%m_%Y)" \
	--output-to "./$OUTNAME"
zsyncmake ./*.AppBundle -u ./*.AppBundle

mkdir -p ./dist
mv -v ./*.AppBundle* ./dist
mv -v ./*.AppImage*  ./dist

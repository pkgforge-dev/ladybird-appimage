#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q ladybird | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/LadybirdBrowser/ladybird/refs/heads/master/Base/res/icons/128x128/app-browser.png
export DESKTOP=https://raw.githubusercontent.com/LadybirdBrowser/ladybird/refs/heads/master/Meta/CMake/freedesktop/org.ladybird.Ladybird.desktop
export ANYLINUX_LIB=1

# Deploy dependencies
quick-sharun \
	/opt/ladybird/usr/bin/*          \
	/opt/ladybird/usr/lib/*          \
	/opt/ladybird/usr/lib/ladybird/* \
	/opt/angle/usr/lib/*             \
	/opt/ladybird/usr/share

mv -v ./AppDir/lib/angle/usr/lib/* ./AppDir/lib

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage

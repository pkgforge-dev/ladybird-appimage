#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook:x86-64-v3-check.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/LadybirdBrowser/ladybird/refs/heads/master/Base/res/icons/128x128/app-browser.png
export DESKTOP=https://raw.githubusercontent.com/LadybirdBrowser/ladybird/refs/heads/master/Meta/CMake/freedesktop/org.ladybird.Ladybird.desktop

# Deploy dependencies
export LD_LIBRARY_PATH="/opt/ladybird/usr/lib:/opt/angle/usr/lib"
quick-sharun \
	/opt/ladybird/usr/bin/* \
	/opt/ladybird/usr/lib   \
	/opt/angle/usr/lib      \
	/opt/ladybird/usr/share/*
unset LD_LIBRARY_PATH
# ANGLE provides its own libEGL/libGLESv2 which must override the mesa ones,
# otherwise the GLES symbols collide. Move them to the top of AppDir/lib.
mv -v ./AppDir/lib/angle/usr/lib/* ./AppDir/lib

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
pacman -S --noconfirm vulkan-swrast # app now needs a vulkan device to launch
quick-sharun --test ./dist/*.AppImage

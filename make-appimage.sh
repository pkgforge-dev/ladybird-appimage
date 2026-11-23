#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/org.ladybird.Ladybird.svg
export DESKTOP=/usr/share/applications/org.ladybird.Ladybird.desktop
export DEPLOY_VULKAN=1

# Deploy dependencies
quick-sharun \
	/opt/ladybird/bin/*     \
	/opt/ladybird/libexec/* \
	/opt/ladybird/share/*   \
	/usr/lib/libavcodec.so*

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
pacman -S --noconfirm vulkan-swrast # app now needs a vulkan device to launch
quick-sharun --test ./dist/*.AppImage

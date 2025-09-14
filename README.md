<h1><p align="center">
  <img src="./assets/images/ladybird.png" alt="Ladybird Logo" width="128">
  <img src="./assets/images/appimage.png" alt="AppImage Logo" width="128">
  <br>Ladybird AppImage<br>
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
  <img src="https://github.com/pkgforge-dev/ladybird-appimage/actions/workflows/ci.yaml/badge.svg" alt="Build Status">
  <img src="https://img.shields.io/github/v/release/pkgforge-dev/ladybird-appimage" alt="GitHub Release">
  <img src="https://img.shields.io/github/release-date/pkgforge-dev/ladybird-appimage" alt="GitHub Release Date">
  <img src="https://img.shields.io/github/downloads/pkgforge-dev/ladybird-appimage/total" alt="GitHub Downloads (all assets/images, all releases)">
  <img src="https://img.shields.io/github/downloads/pkgforge-dev/ladybird-appimage/latest/total" alt="GitHub Downloads (all assets/images, latest release)">
</p></h1>

This repository provides build scripts to create a Universal AppImage for [Ladybird](https://ladybird.org/). This unofficial build offers an executable AppImage compatible with any Linux distribution (Including musl based).

## ⚙️ Installation

1. Command Line (Manual)

   Run the following commands in your terminal:

   ```bash
   # Download the latest AppImage package from releases
   wget https://github.com/pkgforge-dev/ladybird-appimage/releases/download/${VERSION}/Ladybird-${VERSION}-${ARCH}.AppImage

   # Make the AppImage executable
   chmod +x Ladybird-${VERSION}-${ARCH}.AppImage

   # Run the AppImage
   ./Ladybird-${VERSION}-${ARCH}.AppImage

   # Optionally, add the AppImage to your PATH for easier access

   # With sudo for system wide availability
   sudo install ./Ladybird-${VERSION}-${ARCH}.AppImage /usr/local/bin/ladybird

   # Without sudo, XDG base spec mandate
   install ./Ladybird-${VERSION}-${ARCH}.AppImage $HOME/.local/bin/ladybird

   # Now you can run Ladybird from anywhere using the command:
   ladybird
   ```

1. Using [**AM**](https://github.com/ivan-hc/AM) or [**AppMan**](https://github.com/ivan-hc/AppMan) _(Choose one as appropriate)_

   ```bash
   # Install
   am -i ladybird

   # Upgrade
   am -u ladybird

   # Uninstall
   am -r ladybird
   ```

## ⏫ Updating

Since AppImages are self-contained executables, there is no formal installation process beyond setting executable permissions.

1. Download the latest AppImage package from the [releases](https://github.com/pkgforge-dev/ladybird-appimage/releases) section.
1. Follow the same steps as in the [Installation](#installation) section to make it executable and run it.

## 🤝 Contributing

Contributions & Bugfixes are welcome. If you like to contribute, please feel free to fork the repository and submit a pull request.

For any questions or discussions, please open an issue in the repository.

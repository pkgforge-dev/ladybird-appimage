#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	autoconf-archive \
	brotli           \
	cmake            \
	cpptrace         \
	curl             \
	dbus             \
	fast_float       \
	fmt              \
	libdwarf         \
	libedit          \
	libpsl           \
	libtommath       \
	nasm             \
	ninja            \
	openssl          \
	python           \
	qt6-positioning  \
	rust             \
	sdl3             \
	simdjson         \
	simdutf          \
	sqlite           \
	tar              \
	woff2            \
	zip

if [ "$ARCH" = 'x86_64' ]; then
	pacman -Syu --noconfirm libva-intel-driver
fi

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano intel-media-driver-mini ffmpeg-mini

# Use the system ANGLE package instead of building it via vcpkg, it is a huge
# Chromium-based build and the Arch package ships the same chromium/7258 version
make-aur-package --chaotic-aur angle

# If the application needs to be manually built that has to be done down here
echo "Building Ladybird..."
echo "---------------------------------------------------------------"
git clone https://github.com/LadybirdBrowser/ladybird ./ladybird
cd ./ladybird

VERSION=r$(git rev-list --count HEAD).$(git rev-parse --short HEAD)
echo "$VERSION" > ~/version

# vcpkg is used to build the third party dependencies, the checkout
# needs to match the builtin-baseline of the manifest
git clone https://github.com/microsoft/vcpkg.git ./vcpkg
git -C ./vcpkg checkout "$(awk -F'"' '/"builtin-baseline"/{print $4; exit}' vcpkg.json)"

# Let vcpkg build only what the system cannot provide: skia, wuffs, mimalloc,
# the ladybird ffmpeg and the pdfjs assets. Everything else comes from pacman.
python3 - <<'EOF'
import json

system_deps = {
    'angle', 'brotli', 'cpptrace', 'curl', 'dbus', 'fast-float', 'fmt',
    'libdwarf', 'libedit', 'libproxy', 'libpsl', 'libtommath', 'openssl',
    'sdl3', 'simdjson', 'simdutf', 'sqlite3', 'woff2',
}

with open('vcpkg.json') as f:
    data = json.load(f)

data['dependencies'] = [d for d in data['dependencies']
                        if (d if isinstance(d, str) else d['name']) not in system_deps]
data['overrides'] = [o for o in data['overrides'] if o['name'] not in system_deps]

with open('vcpkg.json', 'w') as f:
    json.dump(data, f, indent=2)
EOF

export VCPKG_ROOT="$PWD/vcpkg"
export VCPKG_DISABLE_METRICS="true"
export RUSTUP_TOOLCHAIN=stable

# Apply required patches:
# From the AUR 'ladybird' package:
# - gcc-wno-restrict: GCC emits -Wrestrict warnings which break the build because of -Werror
# Needed for the AppImage:
# - sandbox-allow-time: allow the time() syscall in the seccomp sandbox
# - ca-certificates: allow reading CA bundles in the sandbox and support SSL_CERT_FILE
for patch in ../patches/*.patch; do
	patch -N -p1 --forward -i "$patch"
done

# The Release preset builds shared libraries (lagom + vcpkg deps).
# ENABLE_CI_BASELINE_CPU makes Ladybird target x86-64-v3 instead of
# -march=native. Without it the build bakes in whatever the CI runner supports
# (AVX-512), and the AppImage dies with SIGILL on CPUs that lack it. This is
# the same option the Ladybird Flatpak sets. make-appimage.sh deploys the
# x86-64-v3-check hook so users on older CPUs get a clear warning.
cmake \
	--preset Release \
	-B ./Build/release \
	-S ./ \
	-DCMAKE_BUILD_TYPE=Release \
	-DENABLE_CI_BASELINE_CPU=ON \
	-DENABLE_LTO_FOR_RELEASE=OFF \
	-DENABLE_INSTALL_HEADERS=OFF \
	-DCMAKE_INSTALL_PREFIX='/opt/ladybird/usr' \
	-DCMAKE_INSTALL_LIBEXECDIR='lib/ladybird' \
	-DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" \
	-DVCPKG_ROOT="$VCPKG_ROOT" \
	-Wno-dev

cmake --build ./Build/release
cmake --install ./Build/release

# cmake --install only installs Ladybird's own targets. The vcpkg dependencies
# are built as shared libraries and only exist in the build tree, so copy them
# into the install prefix for quick-sharun.
for vcpkg_libdir in ./Build/release/vcpkg_installed/*/lib; do
	[ -d "$vcpkg_libdir" ] || continue
	for vcpkg_lib in "$vcpkg_libdir"/*.so*; do
		[ -e "$vcpkg_lib" ] || continue
		cp -a "$vcpkg_lib" /opt/ladybird/usr/lib/
	done
done

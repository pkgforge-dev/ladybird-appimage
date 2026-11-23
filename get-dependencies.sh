#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	binutils          \
	kvantum           \
	libdrm            \
	libglvnd          \
	libpulse          \
	lxqt-qtplugin     \
	mesa              \
	qt6-base          \
	qt6-positioning   \
	qt6-svg           \
	qt6-wayland       \
	qt6ct             \
	tar               \
	vulkan-icd-loader \
	wayland           \
	wget              \
	xcb-util-cursor   \
	xcb-util-wm       \
	xz

if [ "$ARCH" = 'x86_64' ]; then
	pacman -Syu --noconfirm libva-intel-driver
fi

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano intel-media-driver-mini ffmpeg-mini

echo "Downloading Ladybird..."
echo "---------------------------------------------------------------"
case "$ARCH" in
	aarch64) deb_arch=arm64;;
	x86_64)  deb_arch=amd64;;
	*)
		echo "Unsupported architecture: $ARCH" >&2
		exit 1
		;;
esac

APT_BASE="https://apt.ladybird.org"
PACKAGES_META=$(wget --retry-connrefused --tries=30 -qO- \
	"$APT_BASE/dists/resolute/main/binary-$deb_arch/Packages")

read -r VERSION DEB_PATH DEB_SHA256 <<-EOF
$(printf '%s\n' "$PACKAGES_META" | awk '
	/^Version: /  { ver = $2 }
	/^Filename: / { file = $2 }
	/^SHA256: /   { sha = $2 }
	/^$/ && ver != "" { print ver, file, sha; ver = file = sha = "" }
	END { if (ver != "") print ver, file, sha }
' | sort -V | tail -n 1)
EOF

echo "${VERSION%%-*}" > ~/version

wget --retry-connrefused --tries=30 "$APT_BASE/$DEB_PATH" -O /tmp/ladybird.deb
printf '%s  /tmp/ladybird.deb\n' "$DEB_SHA256" | sha256sum -c -

(
	cd /tmp
	ar x /tmp/ladybird.deb
	tar --no-overwrite-dir -xf /tmp/data.tar.* -C /
	rm -f /tmp/ladybird.deb /tmp/debian-binary /tmp/control.tar.* /tmp/data.tar.*
)

sed -i 's|/opt/ladybird/bin/||g' /usr/share/applications/org.ladybird.Ladybird.desktop

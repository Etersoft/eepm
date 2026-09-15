#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

# Let the generic AppImage packer handle desktop integration and metadata,
# then add the Vial hidraw access rule to the resulting package.
tmp_return="$(mktemp)"
sh "$(dirname "$0")/generic-appimage.sh" "$TAR" "$tmp_return" "$VERSION" "$URL" || fatal
PKGFILE="$(cat "$tmp_return")"
rm -f "$tmp_return"
[ -n "$PKGFILE" ] || fatal "Can't find generic AppImage package"

BASEDIR="$(basename "${PKGFILE%.tar}")"
erc --here unpack "$PKGFILE" || fatal
install -dm0755 "$BASEDIR/usr/lib/udev/rules.d"
cat <<'EOF' | create_file "$BASEDIR/usr/lib/udev/rules.d/70-entropy-vial.rules"
# Entropy Vial hidraw access v2
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="1000", TAG+="uaccess", TAG+="udev-acl"
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="0005:E126:*", MODE="0660", GROUP="1000", TAG+="uaccess", TAG+="udev-acl"
EOF

rm -f "$PKGFILE"
erc pack "$PKGFILE" "$BASEDIR" || fatal
rm -rf "$BASEDIR"
return_tar "$PKGFILE"

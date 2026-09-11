#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

epm assure ostree || fatal
ARCH="$(epm print info -a)"
case "$ARCH" in
    x86_64) LIBDIR=x86_64-linux-gnu ;;
    aarch64) LIBDIR=aarch64-linux-gnu ;;
    *) fatal "Unsupported architecture for $PRODUCT" ;;
esac
RUNTIME="runtime/org.gnome.Platform/$ARCH/49"
LIBPATH="/files/lib/$LIBDIR"

REPO="$(mktemp -d)" || fatal
trap 'rm -rf "$REPO"' EXIT
trap 'exit 1' HUP INT TERM

prepare_flatpak_runtime "$REPO" "$TAR" "$RUNTIME"
COMMIT="$FLATPAK_RUNTIME_COMMIT"
ostree pull --repo="$REPO" --subpath="$LIBPATH/libxml2.so.16" flathub "$COMMIT" || fatal

# Resolve the symlink, then use the same commit for the library and manifest
# even if the remote runtime is updated during packing.
LIBFILE="$(ostree ls --repo="$REPO" "$COMMIT" "$LIBPATH/libxml2.so.16" | sed -n 's/.* -> \(libxml2\.so\.16\.[0-9.]*\)$/\1/p')"
[ -n "$LIBFILE" ] || fatal "Can't resolve libxml2.so.16 in GNOME 49"
ostree pull --repo="$REPO" --subpath="$LIBPATH/$LIBFILE" --subpath=/files/manifest.json flathub "$COMMIT" || fatal
ostree cat --repo="$REPO" "$COMMIT" /files/manifest.json > "$REPO/manifest.json" || fatal
VERSION="$(sed -n '/"name": "components\/libxml2.bst"/,/"sources"/p' "$REPO/manifest.json" | sed -n 's/.*"version": "\([0-9.]*\)".*/\1/p' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't determine libxml2 version from the runtime manifest"

mkdir -p usr/lib64 || fatal
ostree cat --repo="$REPO" "$COMMIT" "$LIBPATH/$LIBFILE" > "usr/lib64/$LIBFILE" || fatal
chmod 755 "usr/lib64/$LIBFILE" || fatal
ln -s "$LIBFILE" usr/lib64/libxml2.so.16 || fatal

PKGNAME=$PRODUCT-$VERSION.tar
erc pack "$PKGNAME" usr || fatal
cat <<EOF >"$PKGNAME.eepm.yaml"
name: $PRODUCT
version: $VERSION
group: System/Libraries
license: MIT
url: https://gitlab.gnome.org/GNOME/libxml2
summary: libxml2 runtime library (libxml2.so.16)
description: libxml2 runtime from GNOME 49, installed alongside the system libxml2.so.2. Runtime commit $COMMIT.
provides: libxml2.so.16()(64bit)
EOF

return_tar "$PKGNAME"

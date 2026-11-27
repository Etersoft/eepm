#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

APP_ID=dev.boxxy.BoxxyTerminal
REF="app/$APP_ID/x86_64/stable"
REPO_URL="https://boxxy-dev.github.io/boxxy-flatpak-remote/repo"

[ -s "$TAR" ] || fatal "Missing Boxxy OSTree config"

a='' ostree --repo=.ostree-repo init --mode=bare-user-only || fatal "Can't init OSTree repository"
a='' ostree --repo=.ostree-repo remote add --no-gpg-verify boxxy "$REPO_URL" || fatal "Can't add Boxxy repository"
a='' ostree --repo=.ostree-repo pull boxxy "$REF" || fatal "Can't pull $REF"
commit=$(a='' ostree --repo=.ostree-repo rev-parse "$REF") || fatal "Can't resolve $REF"
a='' ostree --repo=.ostree-repo checkout --user-mode "$commit" app_checkout || fatal "Can't checkout $REF"

APP_DIR=app_checkout/files
METAINFO="$APP_DIR/share/metainfo/$APP_ID.metainfo.xml"
VERSION=$(sed -n 's/.*<release[[:space:]][^>]*version="\([0-9][0-9.]*\)".*/\1/p' "$METAINFO" | head -n1)
[ -n "$VERSION" ] || fatal "Can't read Boxxy version from $METAINFO"

install -Dm755 "$APP_DIR/bin/boxxy-terminal" usr/bin/boxxy-terminal || fatal
install -Dm755 "$APP_DIR/libexec/boxxy-agent" usr/bin/boxxy-agent || fatal
install -Dm644 "$APP_DIR/share/applications/$APP_ID.desktop" "usr/share/applications/$APP_ID.desktop" || fatal
install -Dm644 "$METAINFO" "usr/share/metainfo/$APP_ID.metainfo.xml" || fatal
mkdir -p usr/share/icons || fatal
cp -a "$APP_DIR/share/icons/." usr/share/icons/ || fatal

PKGNAME="$PRODUCT-$VERSION.tar"
erc pack "$PKGNAME" usr || fatal "Can't pack $PKGNAME"

cat <<EOF >"$PKGNAME.eepm.yaml" || fatal
name: $PRODUCT
version: $VERSION
group: Terminals
license: MIT
url: https://boxxy.dev/
summary: Boxxy Terminal
description: A GTK terminal emulator.
EOF

return_tar "$PKGNAME"

#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

APP_ID="com.nvidia.geforcenow"

# TAR is the downloaded .flatpakrepo descriptor — parse the ostree repository URL
[ -f "$TAR" ] || fatal "Can't find flatpakrepo file"
repo_url=$(sed -n 's/^Url=//p' "$TAR")
[ -n "$repo_url" ] || fatal "Can't parse ostree Url from $TAR"

# Checkout the flatpak app from NVIDIA's repository via ostree (no flatpak needed).
# NB: ostree calls are prefixed with `a=''` so RPM shell AutoReq does not add
# Requires: ostree to the eepm package (ostree is a build-time tool here, the app
# itself does not need it). pack.d has no docmd, hence the a='' idiom (see repack.d).
ostree_repo="$(pwd)/.ostree-repo"
a='' ostree init --repo="$ostree_repo" --mode=archive || fatal "Can't init ostree repo"
a='' ostree remote add --repo="$ostree_repo" --no-gpg-verify eepm "$repo_url" || fatal "Can't add ostree remote"
flatpak_ref="app/$APP_ID/x86_64/master"
a='' ostree pull --repo="$ostree_repo" eepm "$flatpak_ref" || fatal "Can't pull $flatpak_ref"
commit=$(a='' ostree rev-parse --repo="$ostree_repo" "$flatpak_ref") || fatal "Can't resolve $flatpak_ref"
a='' ostree checkout --repo="$ostree_repo" --user-mode "$commit" app_checkout || fatal "Can't checkout $flatpak_ref"

APP_DIR="app_checkout/files"
[ -d "$APP_DIR" ] || APP_DIR="app_checkout"
CEF_DIR="$APP_DIR/cef"
[ -x "$CEF_DIR/GeForceNOW" ] || fatal "Can't find GeForceNOW binary in $CEF_DIR"

DESKTOP_FILE="$APP_DIR/share/applications/com.nvidia.geforcenow.desktop"

VERSION=$(sed -n 's/.*"productVersion"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$APP_DIR/nvc/NvTelemetry.json" 2>/dev/null | head -n1)
[ -n "$VERSION" ] || fatal "Can't get version from NvTelemetry.json"

mkdir -p opt/$PRODUCT usr/bin usr/share/applications usr/share/icons

# Copy the app, but drop bin/ — those are flatpak-specific launchers (bash scripts
# calling flatpak/ostree, gawk, wget, ...) that the native /usr/bin/$PRODUCT
# wrapper (running cef/GeForceNOW directly) replaces. Keeping them would let RPM
# shell AutoReq pull ostree and friends into the package Requires.
for item in "$APP_DIR/"* ; do
    [ "$(basename "$item")" = "bin" ] && continue
    cp -a "$item" opt/$PRODUCT/
done

cat <<EOF >usr/bin/$PRODUCT
#!/bin/sh
cd /opt/$PRODUCT/cef || exit 1
exec ./GeForceNOW "\$@"
EOF
chmod 755 usr/bin/$PRODUCT

cp "$DESKTOP_FILE" usr/share/applications/$PRODUCT.desktop || fatal "Can't copy desktop file"
subst "s|^Exec=.*|Exec=$PRODUCT %U|" usr/share/applications/$PRODUCT.desktop
subst "s|^TryExec=.*||" usr/share/applications/$PRODUCT.desktop

cp -a "$APP_DIR/share/icons/." usr/share/icons/ 2>/dev/null

# drop the ostree checkout and repo — they must not land in the package
rm -rf "$ostree_repo" app_checkout

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME opt usr

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Games
license: Proprietary
url: https://www.nvidia.com/en-us/geforce-now/
summary: NVIDIA GeForce NOW cloud gaming
description: NVIDIA GeForce NOW transforms your device into a high-end gaming rig.
EOF

return_tar $PKGNAME

#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

erc --here unpack "$TAR" || fatal
[ -d usr/lib/millennium ] || fatal "Can't find usr/lib/millennium in archive"

chmod 755 usr/lib/millennium/libmillennium_luavm_x86 || fatal
chmod 755 usr/lib/millennium/libmillennium_pvs64 || fatal

mkdir -p usr/bin || fatal
cat <<'EOF' >usr/bin/millennium-setup
#!/bin/sh

if [ "$(id -u)" -eq 0 ] ; then
    echo "Do not run millennium-setup as root." >&2
    exit 1
fi

steam_dir="$HOME/.steam/steam"
beta_file="$steam_dir/package/beta"

# Millennium recommends using the stable Steam client for the first launch.
if [ -f "$beta_file" ] ; then
    echo "Disabling Steam beta for the first Millennium launch ..."
    rm -f "$beta_file" || exit 1
fi

mkdir -p "$steam_dir/ubuntu12_32" "$steam_dir/ubuntu12_64" || exit 1
ln -sf /usr/lib/millennium/libmillennium_bootstrap_x86.so "$steam_dir/ubuntu12_32/libXtst.so.6" || exit 1
ln -sf /usr/lib/millennium/libmillennium_bootstrap_hhx64.so "$steam_dir/ubuntu12_64/libXtst.so.6" || exit 1
ln -sf /usr/lib/millennium/libmillennium_hhx64.so "$steam_dir/ubuntu12_64/libmillennium_hhx64.so" || exit 1

echo "Millennium is enabled. Restart Steam to load it."
EOF
chmod 755 usr/bin/millennium-setup || fatal

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Games
license: MIT
url: https://github.com/SteamClientHomebrew/Millennium
summary: Modding framework for Steam Client themes and plugins
description: Open-source modding framework for creating and managing Steam Client themes and plugins.
EOF

return_tar $PKGNAME.tar

#!/bin/sh

# Build the complete Discord app from the official distro packages.
# The official deb/tar.gz only ship updater_bootstrap, which downloads the app
# into ~/.config/discord on first launch. The updater fetches the host and
# its modules as brotli-compressed tarballs (full.distro); we download them
# all here and disable the updater, so the installed app downloads nothing.

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || fatal "Missing Discord version"

MANIFEST_URL="https://updates.discord.com/distributions/app/manifests/latest?channel=stable&platform=linux&arch=x64"

epm assure brotli || fatal

# use eget for all downloads (it supports IPFS)
eget -O manifest.json "$MANIFEST_URL" || fatal "Can't download Discord manifest"
epm tool json -b < manifest.json > manifest.txt || fatal "Can't parse Discord manifest"

# ["path"] -> value
manifest_value()
{
    grep -F "$1" manifest.txt | head -n1 | sed -e 's|.*[[:space:]]||' -e 's|"||g'
}

# check sha256 only for the version described by the manifest
MANIFEST_VERSION="$(manifest_value '["full","url"]' | sed -e 's|.*/linux/x64/\([^/]*\)/full\.distro$|\1|')"
[ -n "$MANIFEST_VERSION" ] || fatal "Can't get Discord version from manifest"
if [ "$MANIFEST_VERSION" = "$VERSION" ] ; then
    CHECKSHA=1
else
    echo "Warning: the manifest describes Discord $MANIFEST_VERSION, packing $VERSION without sha256 check"
    CHECKSHA=''
fi

# file ["path","package_sha256"]
check_sha256()
{
    [ -n "$CHECKSHA" ] || return 0
    local sha="$(manifest_value "$2")"
    [ -n "$sha" ] || fatal "Missing sha256 for $1 in manifest"
    [ "$(sha256sum "$1" | cut -d' ' -f1)" = "$sha" ] || fatal "sha256 mismatch for $1"
}

# unpack distro file (brotli-compressed tar with files/ and delta_manifest.json) into dir
unpack_distro()
{
    mkdir -p "$2" || fatal
    a='' brotli -dc "$1" | tar -x -C "$2" || fatal "Can't unpack $1"
    [ -d "$2/files" ] || fatal "Missing files/ in $1"
}

check_sha256 "$TAR" '["full","package_sha256"]'
unpack_distro "$TAR" host
mkdir -p opt || fatal
mv host/files opt/$PRODUCT || fatal
mkdir -p opt/$PRODUCT/modules || fatal

# skip modules with unsatisfiable requires (on deb systems one missing lib drops all Depends):
# discord_dispatch (game store installer) needs libssl.so.1.1,
# discord_ndi (NDI streaming output) bundles libndi.so.6 and needs avahi
SKIP_MODULES="discord_dispatch discord_ndi"

MODULES="$(grep -o '^\["modules","[^"]*","full","url"\]' manifest.txt | cut -d'"' -f4 | grep -v -x -F "$(echo $SKIP_MODULES | tr ' ' '\n')")"
[ -n "$MODULES" ] || fatal "Can't get Discord modules from manifest"

for mod in $MODULES ; do
    url="$(manifest_value "[\"modules\",\"$mod\",\"full\",\"url\"]" | sed -e "s|/linux/x64/$MANIFEST_VERSION/|/linux/x64/$VERSION/|")"
    eget -O $mod.distro "$url" || fatal "Can't download $mod module"
    check_sha256 $mod.distro "[\"modules\",\"$mod\",\"full\",\"package_sha256\"]"
    unpack_distro $mod.distro $mod
    mv $mod/files opt/$PRODUCT/modules/$mod || fatal
    rm -rf $mod $mod.distro
done
rm -f manifest.json manifest.txt

# krisp (noise suppression) fails to init without this directory
mkdir -p opt/$PRODUCT/modules/discord_krisp/KMS/logs

# disable the updater and load modules from the package
BUILDINFO=opt/$PRODUCT/resources/build_info.json
grep -q '"version"' $BUILDINFO || fatal "Unknown $BUILDINFO format"
sed -i -e "s|\(\"version\": *\"[^\"]*\"\)|\1,\n  \"disableUpdater\": true,\n  \"localModulesRoot\": \"/opt/$PRODUCT/modules\"|" $BUILDINFO || fatal

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=$PRODUCT --url -- %u
Icon=$PRODUCT
Type=Application
Categories=Network;InstantMessaging;
MimeType=x-scheme-handler/discord;
EOF

install_file opt/$PRODUCT/discord.png /usr/share/pixmaps/$PRODUCT.png

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Instant messaging
license: Proprietary
url: https://discord.com
summary: All-in-one voice and text chat for gamers
description: Discord from the official site.
EOF

return_tar $PKGNAME.tar

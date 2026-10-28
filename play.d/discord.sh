#!/bin/sh

PKGNAME=discord
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Discord from the official site"
URL="https://discord.com"
# allow to replace the official deb (installed by the previous epm play discord on deb systems)
SKIPREPACK=1

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(fetch_url "https://updates.discord.com/distributions/app/manifests/latest?channel=stable&platform=linux&arch=x64" | grep -o -m1 'linux/x64/[0-9.]*/full\.distro' | head -n1 | cut -d/ -f3)"
    [ -n "$VERSION" ] || fatal "Can't get latest Discord version"
fi

# the complete app (host) and its modules are downloaded in pack.d/discord.sh
PKGURL="https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/$VERSION/full.distro"

install_pack_pkgurl "$VERSION"

#!/bin/sh

PKGNAME=mailruagent
SUPPORTEDARCHES="x86_64"
VERSION="$2"
# is not supported
DESCRIPTION='' #"Mail.ru Agent for Linux from the official site"
URL="https://agent.mail.ru/linux"

. $(dirname $0)/common.sh

warn_version_is_not_supported

VERSION="*"
if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- -H Snap-Device-Series:16 https://api.snapcraft.io/v2/snaps/info/agent | epm --inscript tool json -b | grep version | head -n1 | sed -e 's|.*"\([0-9.]*\)".*|\1|') || fatal "Can't get current version" #'
fi

PKGURL="https://hb.bizmrg.com/agent-www/linux/x64/agent.tar.xz"
install_pack_pkgurl "$VERSION"

#PKGURL="$(eget -O- -H Snap-Device-Series:16 https://api.snapcraft.io/v2/snaps/info/agent | epm --inscript tool json -b | grep '\["channel-map",0,"download","url"\]' | head -n1 | sed -e 's|.*"\(.*\)"$|\1|' )" || fatal "Can't get URL"

#epm install "$PKGURL"

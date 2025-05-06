#!/bin/sh

PKGNAME=windscribe
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Windscribe GUI tool for Linux'
URL="https://github.com/Windscribe/Desktop-App"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/Windscribe/Desktop-App/" "${PKGNAME}_${VERSION}_$arch.deb")
else
    PKGURL="https://github.com/Windscribe/Desktop-App/releases/download/v$VERSION/${PKGNAME}_${VERSION}_$arch.deb"
fi

install_pkgurl

cat <<EOF
Note: run
# serv windscribe-helper on
to enable needed windscribe system service (daemon)
And run this commands by root
groupadd -r windscribe
setcap cap_setgid+ep /opt/windscribe/Windscribe
to windscribe work
EOF

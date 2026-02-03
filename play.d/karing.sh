#!/bin/sh

PKGNAME=karing
VERSION="$2"
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Simple & Powerful proxy utility - singbox GUI based on flutter"
URL="https://karing.app/"

. $(dirname $0)/common.sh

case "$(epm print info -p)" in
rpm)
	pkgtype=rpm
	;;
*)
	pkgtype=deb
	;;
esac

if [ "$VERSION" = "*" ]; then
	VERSION="$(get_github_tag "https://github.com/KaringX/karing/")"
fi
PKGURL="https://github.com/KaringX/karing/releases/download/v${VERSION}/karing_${VERSION}_linux_amd64.$pkgtype"

install_pack_pkgurl $VERSION

cat <<EOF

Note: For TUN mode functionality, sudo must be enabled in the system:
$ su -
# control sudowheel enabled
# exit

This allows Karing to create TUN interfaces for system-wide traffic routing.
EOF

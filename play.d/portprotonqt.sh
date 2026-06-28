#!/bin/sh

PKGNAME=portprotonqt
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Modern GUI for managing and launching games from PortProton and Steam"
URL="https://git.linux-gaming.ru/Linux-Gaming/PortProtonQt"

. $(dirname $0)/common.sh

# upstream ships one rpm per Fedora release (fc42..fc45); we repack any of them,
# so pin one dist and use the concrete RELEASE from app-versions, giving a download
# URL without a glob that can be resolved in the IPFS cache. Fall back for --latest.
[ -n "$RELEASE" ] || RELEASE="*"

PKGURL="$(get_gitea_url "$URL" "${PKGNAME}-${VERSION}-${RELEASE}.fc42.x86_64.rpm")"

install_pkgurl

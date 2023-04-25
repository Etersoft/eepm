#!/bin/sh

PKGNAME="teamviewer"
SUPPORTEDARCHES="x86_64 armhf"
DESCRIPTION="Teamviewer from the official site"

. $(dirname $0)/common.sh


arch="$(epm print info -a)"
case "$arch" in
    x86_64|x86)
        ;;
    armhf)
        PKGNAME="teamviewer-host"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac


# See https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=teamviewer

repack=''
[ "$(epm print info -p)" = "deb" ] || repack='--repack'

# epm uses eget to download * names
epm $repack install "https://download.teamviewer.com/download/linux/$(epm print constructname $PKGNAME)" || exit

cat <<EOF

Note: run
# serv teamviewerd on
to enable needed teamviewer system service (daemon)
EOF

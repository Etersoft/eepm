#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME="teamviewer"

arch="$($DISTRVENDOR -a)"
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

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Install Teamviewer from the official site" && exit

# See https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=teamviewer

repack=''
[ "$($DISTRVENDOR -p)" = "deb" ] || repack='--repack'

# epm uses eget to download * names
epm $repack install "https://download.teamviewer.com/download/linux/$(epm print constructname $PKGNAME)" || exit

echo
echo "Note: run
# serv teamviewerd on
to enable needed teamviewer system service
"

#!/bin/sh

PKGNAME=sublime-text
DESCRIPTION='Sublime Text 4 from the official site'

. $(dirname $0)/common.sh

arch="$($DISTRVENDOR -a)"
case "$arch" in
    x86_64)
        arch=x64
        ;;
    aarch64)
        arch=arm64
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

PKG=$($EGET --list --latest https://www.sublimetext.com/download "sublime_text_build_*_$arch.tar.xz") || fatal "Can't get package URL"
[ -n "$PKG" ] || fatal "Can't get package URL"

PKGFILE=$(echo /tmp/$(basename $PKGURL) | sed -e "s|/sublime_text_build_|/$PKGNAME-|")
$EGET -O $PKGFILE $PKGURL || exit

epm install --repack "$PKG" || exit

rm -fv $PKGFILE

echo
echo "NOTE: Sublime Text 4 is a proprietary software. We recommend use open source editors: Codium, VS Code, Atom."

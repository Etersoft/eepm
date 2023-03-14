#!/bin/sh

PKGNAME=sublime-text
SUPPORTEDARCHES="x86_64 aarch64"
DESCRIPTION='Sublime Text 4 from the official site'

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
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

PKGURL=$(epm tool eget --list --latest https://www.sublimetext.com/download_thanks "sublime_text_build_*_$arch.tar.xz") || fatal "Can't get package URL"
[ -n "$PKGURL" ] || fatal "Can't get package URL"

PKGFILE=$(echo /tmp/$(basename $PKGURL) | sed -e "s|/sublime_text_build_|/$PKGNAME-|")
epm tool eget -O $PKGFILE $PKGURL || exit

epm install --repack "$PKGFILE" || exit

rm -fv $PKGFILE

echo
echo "NOTE: Sublime Text 4 is a proprietary software. We recommend to use open source editors: Codium, VS Code, Atom."

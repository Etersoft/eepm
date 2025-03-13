#!/bin/sh

fatal()
{
    echo "$*" >&2
    exit 1
}

SPECNAME=$(realpath $(dirname $0)/../../eepm.spec)

ls "$SPECNAME" || fatal

cd ~/Projects/git/eepm.aur/ || fatal

if [ -f /usr/share/eterbuild/eterbuild ] ; then

    # load common functions, compatible with local and installed script
    . /usr/share/eterbuild/eterbuild
    load_mod spec etersoft

    VERSION="$(get_version $SPECNAME)"
    [ -n "$VERSION" ] || fatal

    echo "$ subst \"s|^pkgver=.*|pkgver=$VERSION|\" PKGBUILD"

    subst "s|^pkgver=.*|pkgver=$VERSION|" PKGBUILD
fi


if [ $(epm print info -g) != "pacman" ] ; then
    echo "Rerun the script on Arch based system"
    ssh manjaro bash -x ~/Projects/git/eepm/packaging/AUR/update.sh
    exit 0
fi

updpkgsums
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO

. PKGBUILD
git commit -m "new version $pkgver"

makepkg -C -f --noconfirm

echo "Check the result and run git push"


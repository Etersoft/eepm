#!/bin/sh

SPECNAME=$(pwd)/../../eepm.spec

cd ~/Projects/git/eepm.aur/ || exit

if [ -f /usr/share/eterbuild/eterbuild ] ; then

    # load common functions, compatible with local and installed script
    . /usr/share/eterbuild/eterbuild
    load_mod spec etersoft

    VERSION="$(get_version $SPECNAME)"

    echo "$ subst \"s|^pkgver=.*|pkgver=$VERSION|\" PKGBUILD"

    subst "s|^pkgver=.*|pkgver=$VERSION|" PKGBUILD
fi


if [ $(epm print info -g) != "pacman" ] ; then
    echo "Rerun the script on Arch based system"
    exit 1
fi

updpkgsums
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO
git commit

makepkg -C -f --noconfirm

echo "Check the result and run git push"


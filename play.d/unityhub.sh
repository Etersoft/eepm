#!/bin/sh

PKGNAME=unityhub
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Unity Hub from the official site"
URL="https://unity.com/"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
pkgtype=$(epm print info -p)

# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unityhub

case "$arch" in
    x86_64)
        debarch=amd64
        rpmarch=x86_64
        ;;
esac

DEBREPOURL="https://hub.unity3d.com/linux/repos/deb"
DEBPACKAGESURL="$DEBREPOURL/dists/stable/main/binary-$debarch/Packages.gz"
RPMREPOURL="https://hub.unity3d.com/linux/repos/rpm/stable"

# Direct package URLs are used because minimal deb containers cannot import the
# vendor repo key reliably (no gpg/apt-key).
case "$pkgtype" in
    rpm)
        repo="$RPMREPOURL"
        pkgarch=$rpmarch
        packagedir=unityhub_$pkgarch
        latestmask="$packagedir/unityhub-[0-9][0-9.]*-[0-9]\\.$pkgarch\\.rpm"
        filebase="unityhub-$VERSION-1.$pkgarch"
        ;;
    *)
        pkgtype=deb
        repo="$DEBREPOURL"
        pkgarch=$debarch
        packagedir=pool/main/u/unity/unityhub_$pkgarch
        filebase="unityhub_${VERSION}_$pkgarch"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    case "$pkgtype" in
        rpm)
            filename="$(get_rpm_repo_latest_file "$repo" "$latestmask")"
            ;;
        deb)
            filebase="$(get_deb_repo_latest_filename "$DEBPACKAGESURL" unityhub)"
            [ -n "$filebase" ] && filename="$packagedir/$filebase.$pkgtype"
            ;;
    esac
    [ -n "$filename" ] || fatal "Can't get latest unityhub $pkgtype filename from $repo"
else
    is_version_older "$VERSION" 3.20.0 && filebase="UnityHubSetup-$VERSION-$pkgarch"

    [ "$pkgtype" = "deb" ] && is_version_older "$VERSION" 3.15.3 && filebase="unityhub-$pkgarch-$VERSION"

    filename="$packagedir/$filebase.$pkgtype"
fi

PKGURL="$repo/$filename"

install_pkgurl

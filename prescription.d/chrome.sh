#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

if [ "$1" = "--remove" ] ; then
    epm remove google-chrome-stable
    exit
fi

[ "$1" != "--run" ] && echo "Install The popular and trusted web browser by Google (Stable Channel) from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

arch=$($DISTRVENDOR --distro-arch)
pkgtype=$($DISTRVENDOR -p)

# don't used
complex_get()
{
    epm assure curl || fatal
    # see https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=google-chrome
    _channel=stable
    pkgver=$(a= curl -s https://dl.google.com/linux/chrome/rpm/stable/x86_64/repodata/other.xml.gz | gzip -df | grep -A1 google-chrome-stable | tail -n1 | sed -e 's|.* ver="\(.*\)" .*|\1|')

    pkgtype=deb

    PKG="https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-${_channel}/google-chrome-${_channel}_${pkgver}-1_amd64.deb"
}

PKG="https://dl.google.com/linux/direct/google-chrome-stable_current_$arch.$pkgtype"

epm install --repack "$PKG"

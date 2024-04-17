#!/bin/sh

PKGNAME=cascadeur
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Cascadeur - a physics‑based 3D animation software"
URL="https://cascadeur.com/download"

. $(dirname $0)/common.sh

# TODO: ask license

if [ "$VERSION" = "*" ] ; then
    #distr="$(epm print info -s)"
    #repo="$(epm print info -r)"
    VERSION="2024.1"
fi

# 'Older versions of Cascadeur' on  https://cascadeur.com/download is broken
# https://cdn.cascadeur.com/builds/linux/63/cascadeur-linux.tgz
case "$VERSION" in
    "2024.1")    # 67
# ALT Sisyphus:
#  cascadeur: Depends: libbz2.so.1.0()(64bit) но пакет не может быть установлен
#             Depends: libgdbm.so.6()(64bit) но пакет не может быть установлен

        PKGURL="ipfs://QmPGBGkFm5aCc6PGPGwyc2cxTBbNWgCkJiGRoDeBFDDkK5?filename=cascadeur-linux.tgz"
        ;;
#    "2023.2.1")  #
        #PKGURL="ipfs://?filename=cascadeur-linux.tgz"
        #;;
    "2023.2")    # 64
        PKGURL="ipfs://QmSVoQTjtf5zdTCTkMo7AaY2MxjXUqvVFVfCGMTGjhMh7B?filename=cascadeur-linux.tgz"
        ;;
    "2023.1.1")  # 63
        PKGURL="ipfs://QmeertRBvLagCJrUoH9gfm3vu1eUSqLSjVAfAjeYcLuHsT?filename=cascadeur-linux.tgz"
        ;;
    "2023.1")    # 62
        # https://cdn.cascadeur.com/builds/linux/62/cascadeur-linux_2023.1.tgz
        PKGURL="ipfs://QmPYBGCqAS9DrrEydQzCAdi5oHGF7xL9mWo6mwwMpPQk9e?filename=cascadeur-linux.tgz"
        ;;
    "2022.3.1") # 59
        PKGURL="ipfs://Qma8WF8iPwgKNPM6UdZHWse4q1cTnPAvjMRkGsbbWYi18w?filename=cascadeur-linux.tgz"
        ;;
    "2022.3")   # 58
        PKGURL="ipfs://QmRMuJ9c47X7vVkZccxBoavj3bRfV9FojS2CXLFqk56tiu?filename=cascadeur-linux.tgz"
        ;;
    *)
        fatal "Sorry, we know nothing about cascadeur version $VERSION."
        ;;
esac

install_pack_pkgurl "$VERSION"
exit

# (liblapack.so.3)
page="$(eget -O- https://cascadeur.com/ru/download)"
BUILDID=$(echo "$page" | grep 'data-platform="linux"' | grep 'data-build-id=' | sed -e 's|.*data-build-id="\(.*\)" data-modal.*|\1|') #"
VERSION=$(echo "$page" | grep 'main-download__info-version' | sed -e 's|.*<div class="main-download__info-version">\(.*\)</div>.*|\1|') #'
# https://cdn.cascadeur.com/builds/linux/62/cascadeur-linux_2023.1.tgz
PKGURL="https://cdn.cascadeur.com/builds/linux/$BUILDID/cascadeur-linux_$VERSION.tgz"

# TODO: ask license
install_pack_pkgurl "$VERSION"

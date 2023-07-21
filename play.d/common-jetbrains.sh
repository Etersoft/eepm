#!/bin/sh

. $(dirname $0)/common.sh

# PS
# Returns URL like https://download.jetbrains.com/python/pycharm-professional-2022.2.1.tar.gz
get_jetbrains_url()
{
    CODE="$1"
    arch="$(epm print info -a)"
    case $arch in
        aarch64)
            OS=linuxARM64
            ;;
        *)
            OS=linux
            ;;
    esac

    epm tool eget -O- "https://data.services.jetbrains.com/products/releases?code=$CODE&latest=true&type=release" | epm --inscript tool json -b | \
        grep '"'$CODE'",0,"downloads","'$OS'","link"' | sed -e 's|.*[[:space:]]||' | sed -e 's|"||g'
}

# PS python
get_jetbrains_pkgurl()
{
    local CODE="$1"
    local PART="$2"
    if [ "$VERSION" = "*" ] ; then
        get_jetbrains_url $CODE
    else
        echo "https://download-cdn.jetbrains.com/$PART/$PKGNAME-$VERSION.tar.gz"
    fi
}

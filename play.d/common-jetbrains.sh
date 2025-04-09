#!/bin/sh

. $(dirname $0)/common.sh

# PS
# Returns URL like https://download.jetbrains.com/python/pycharm-professional-2022.2.1.tar.gz
get_jetbrains_url()
{
    local OS
    local CODE="$1"
    local arch="$(epm print info -a)"
    case $arch in
        aarch64)
            OS=linuxARM64
            ;;
        *)
            OS=linux
            ;;
    esac

    # Note, replacing download with download-cdn due HTTP 451
    get_json_value "https://data.services.jetbrains.com/products/releases?code=$CODE&latest=true&type=release" '["'$CODE'",0,"downloads","'$OS'","link"]' | \
        sed -e "s|download.jetbrains.com|download-cdn.jetbrains.com|"
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

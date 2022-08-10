#!/bin/sh

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

get_latest_version()
{
    local URL="https://eepm.ru/app-versions"
    epm tool eget -q -O- "$URL/$1"
}

print_product_alt()
{
    [ -n "$1" ] || return
    shift
    echo "$*"
}

case "$1" in
    "--remove")
        epm remove $PKGNAME
        exit
        ;;
    "--help")
        if [ -n "$PRODUCTALT" ] ; then
            echo "Help about additional parameters."
            echo "Use epm play $(basename $0 .sh) [$(echo "$PRODUCTALT" | sed -e 's@ @|@g')]"
        fi
        [ -n "$TIPS" ] && echo "$TIPS"
        exit
        ;;
    "--package-name")
        [ -n "$DESCRIPTION" ] || exit 0
        echo "$PKGNAME"
        exit
        ;;
    "--product-alternatives")
        print_product_alt $PRODUCTALT
        exit
        ;;
    "--installed")
        epm installed $PKGNAME
        exit
        ;;
    "--installed-version")
        epm print version for package $PKGNAME
        exit
        ;;
    "--description")
        echo "$DESCRIPTION"
        exit
        ;;
    "--update")
        if ! epm installed $PKGNAME ; then
            echo "Skipping update of $PKGNAME (package is not installed)"
            exit
        fi
        pkgver="$(epm print version for package $PKGNAME)"
        if [ -n "$pkgver" ] && [ "$(get_latest_version $PKGNAME)" = "$pkgver" ] ; then
            echo "There is no newer version of $PKGNAME then installed version $pkgver."
            exit
        fi
        ;;
    "--run")
        # just pass
        ;;
    *)
        fatal "Unknown command $1"
        ;;
esac


check_supported_arch()
{
    # skip checking if no arches
    [ -n "$1" ] || return 0
    for i in $* ; do
        [ "$(epm print info -a)" = "$i" ] && return 0
    done

    return 1
}

check_url_is_accessible()
{
    local res
    epm tool eget --check "$1"
}

# update URL variable
update_url_if_need_mirrored()
{
    local MIRROR="$1"
    local SECONDURL
    check_url_is_accessible "$URL" && return
    if [ -n "$MIRROR" ] ; then
        check_url_is_accessible "$MIRROR" && URL="$MIRROR"
        return
    fi

    MIRROR="https://mirror.eterfund.ru"
    SECONDURL="$(echo "$URL" | sed -e "s|^.*://|$MIRROR/|")"
    check_url_is_accessible "$SECONDURL" && URL="$SECONDURL" && return

    MIRROR="https://mirror.eterfund.org"
    SECONDURL="$(echo "$URL" | sed -e "s|^.*://|$MIRROR/|")"
    check_url_is_accessible "$SECONDURL" && URL="$SECONDURL" && return

}

check_supported_arch $SUPPORTEDARCHES || fatal "Only $SUPPORTEDARCHES is supported"

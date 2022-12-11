#!/bin/sh

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

check_url_is_accessible()
{
    local res
    epm tool eget --check "$1"
}

is_supported_arch()
{
    local i
    [ -n "$SUPPORTEDARCHES" ] || return 0
    for i in $SUPPORTEDARCHES ; do
        [ "$i" = "$1" ] && return 0
    done
    return 1
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

get_latest_version()
{
    URL="https://eepm.ru/app-versions"
    update_url_if_need_mirrored
    epm tool eget -q -O- "$URL/$1"
}

print_product_alt()
{
    [ -n "$1" ] || return
    shift
    echo "$*"
}

get_pkgvendor()
{
    epm print field Vendor for package $1
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
        is_supported_arch "$2" || exit 0
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
            echo "There is no newer version of $PKGNAME than installed version $pkgver."
            exit
        fi
        ;;
    "--run")
        # just pass
        ;;
    *)
        fatal "Unknown command '$1'. Use this script only via epm play."
        ;;
esac


check_supported_arch()
{
    # skip checking if no arches
    [ -n "$1" ] || return 0
    local arch="$(epm print info -a)"
    for i in $* ; do
        [ "$arch" = "$i" ] && return 0
    done

    return 1
}

# legacy compatibility and support direct run the script
if [ -z "$DISTRVENDOR" ] ; then
    export DISTRVENDOR="epm print info"
    if [ -x "../bin/epm" ] ; then
        export PATH="$(realpath ../bin):$PATH"
    fi
fi

if [ -z "$SUDO" ] && [ "$UID" != "0" ] ; then
    SUDO="sudo"
fi

check_supported_arch $SUPPORTEDARCHES || fatal "Only '$SUPPORTEDARCHES' architectures is supported"

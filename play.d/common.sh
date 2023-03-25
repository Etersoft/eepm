#!/bin/sh

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

eget()
{
    epm tool eget "$@"
}

check_url_is_accessible()
{
    local res
    eget --check "$1"
}


cd_to_temp_dir()
{
    PKGDIR=$(mktemp -d)
    trap "rm -fr $PKGDIR" EXIT
    cd $PKGDIR || fatal
}

is_supported_arch()
{
    local i

    # skip checking if there are no arches
    [ -n "$SUPPORTEDARCHES" ] || return 0
    [ -n "$1" ] || return 0

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
    local epmver="$(epm --short --version)"
    # TODO: use check_url_is_accessible with more short URL (domain?)
    URL="https://eepm.ru/releases/$epmver/app-versions"
    if ! update_url_if_need_mirrored ; then
        URL="https://eepm.ru/app-versions"
        update_url_if_need_mirrored || return
    fi
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
        if epm mark showhold | grep -q "^$PKGNAME$" ; then
            echo "Skipping update of $PKGNAME (package is on hold, see '# epm mark showhold')"
            exit
        fi
        pkgver="$(epm print version for package $PKGNAME)"
        latestpkgver="$(get_latest_version $PKGNAME)"
        # ignore update if have no latest package version or the latest package version no more than installed one
        if [ -n "$pkgver" ] ; then
            if [ -z "$latestpkgver" ] ; then
                echo "Can't get info about latest version of $PKGNAME, so skip updating installed version $pkgver."
                exit
            fi
            # latestpkgver < pkgver
            if [ "$(epm print compare package version $latestpkgver $pkgver)" = "-1" ] ; then
                echo "Latest available version of $PKGNAME: $latestpkgver. Installed installed version: $pkgver."
                exit
            fi
        fi
        ;;
    "--run")
        # just pass
        ;;
    *)
        fatal "Unknown command '$1'. Use this script only via epm play."
        ;;
esac


# legacy compatibility and support direct run the script
if [ -z "epm print info" ] ; then
    export DISTRVENDOR="epm print info"
    if [ -x "../bin/epm" ] ; then
        export PATH="$(realpath ../bin):$PATH"
    fi
fi

if [ -z "$SUDO" ] && [ "$UID" != "0" ] ; then
    SUDO="sudo"
fi

is_supported_arch "$(epm print info -a)" || fatal "Only '$SUPPORTEDARCHES' architectures is supported"

#!/bin/sh

# kind of hack: inheritance --force from main epm
echo "$EPM_OPTIONS" | grep -q -- "--force" && force="--force"
echo "$EPM_OPTIONS" | grep -q -- "--auto" && auto="--auto"

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

[ -n "$BIGTMPDIR" ] || [ -d "/var/tmp" ] && BIGTMPDIR="/var/tmp" || BIGTMPDIR="/tmp"

cd_to_temp_dir()
{
    PKGDIR=$(mktemp -d --tmpdir=$BIGTMPDIR)
    trap "rm -fr $PKGDIR" EXIT
    cd $PKGDIR || fatal
}

# check if <arg> is a real command
is_command()
{
    epm tool which "$1" >/dev/null
}


. $(dirname $0)/common-outformat.sh

check_tty

#__showcmd_shifted()
#{
#    local s="$1"
#    shift
#    shift $s
#    showcmd "$*"
#}


# add to all epm calls
EPM="$(epm tool which epm)" || fatal
epm()
{
    #if [ "$1" = "tool" ] ; then
    #    __showcmd_shifted 1 "$@"
    if [ "$1" != "print" ] && [ "$1" != "tool" ] && [ "$1" != "status" ] ; then
        showcmd "$(basename $EPM) $*"
    fi
    $EPM "$@"
}


eget()
{
    epm tool eget "$@"
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


get_latest_version()
{
    local ver
    local epmver="$(epm --short --version)"
    local URL
    for URL in "https://eepm.ru/releases/$epmver/app-versions" "https://eepm.ru/app-versions" ; do
        ver="$(eget -q -O- "$URL/$1")" || continue
        ver="$(echo "$ver" | head -n1 | cut -d" " -f1)"
        [ -n "$ver" ] && echo "$ver" && return
    done
}

print_product_alt()
{
    [ -n "$1" ] || return
    shift
    echo "$*"
}

get_pkgvendor()
{
    epm print field Vendor for package "$1"
}

# arg: minimal require of libstdc++ version
# return true is we have such version
is_stdcpp_enough()
{
    local needed="$1"
    local STDCPKG="libstdc++"
    epm installed $STDCPKG || STDCPKG="libstdc++6"

    if epm installed $STDCPKG ; then
        local stdcver
        stdcver=$(epm print version for package "$STDCPKG" | head -n1)
        if [ -n "$stdcver" ] && [ "$(epm print compare version "$stdcver" "$needed")" = "-1" ] ; then
            return 1
        fi
    fi
    return 0
}


get_first()
{
    echo "$1"
}

check_alternative_pkgname()
{
    [ -n "$BASEPKGNAME" ] || BASEPKGNAME="$PKGNAME"
    [ -n "$BASEPKGNAME" ] || return

    # default: with first entry in $PEODUCTALT
    PKGNAME="$BASEPKGNAME-$(get_first $PRODUCTALT)"

    # override with VERSION
    local i
    for i in $PRODUCTALT ; do
        if [ "$i" = "''" ] ; then
            PKGNAME=$BASEPKGNAME
            continue
        fi
        if [ "$VERSION" = "$i" ] ; then
            PKGNAME=$BASEPKGNAME-$i
            VERSION=""
            return
        fi
    done

    # when VERSION is not in PRODUCTALT, check installed package
    for i in $PRODUCTALT ; do
        if [ "$i" = "''" ] ; then
            continue
        fi
        if epm installed $BASEPKGNAME-$i ; then
            PKGNAME=$BASEPKGNAME-$i
            break
        fi
    done
}

is_repacked_package()
{
    local pkg="$1"
    [ -n "$pkg" ] || pkg="$PKGNAME"
    [ -n "$pkg" ] || return 0 #fatal "is_repacked_package() is called without package name"

    epm status --installed $pkg || return 0

    # actually only for ALT
    [ "$(epm print info -s)" = "alt" ] || return 0

    [ -n "$force" ] && return 0

    if epm status --original $pkg ; then
       echo "Package $pkg is already installed from ALT repository (use --force to override it)."
       return 1
    fi

    if epm status --certified $pkg ; then
       # allow install/update if we agreed with their package
       return 0
    fi

    if epm status --thirdparty $pkg ; then
       echo "Package $pkg is already installed, packaged by vendor $(epm print field Vendor for $pkg)."
       return 1
    fi

    if ! epm status --repacked $pkg ; then
       echo "Package $pkg is already installed (possible, manually packed)."
       return 1
    fi

    return 0
}


# support for direct run a play script
if [ -x "../bin/epm" ] ; then
    export PATH="$(realpath ../bin):$PATH"
fi

# set PKGNAME to $BASEPKGNAME-$VERSION if $VERSION is found in PRODUCTALT
[ -n "$PRODUCTALT" ] && check_alternative_pkgname

case "$1" in
    "--remove")
        is_repacked_package || exit 0
        epm remove $PKGNAME
        exit
        ;;
    "--info")
        if [ -n "$PRODUCTALT" ] ; then
            echo "Help about additional parameters."
            echo "Use epm play $(basename $0 .sh) [= $(echo "$PRODUCTALT" | sed -e 's@ @|@g')]"
        fi
        [ -n "$TIPS" ] && echo "$TIPS"
        [ -n "$URL" ] && echo "Url: $URL"
        exit
        ;;
    "--package-name")
        #[ -n "$DESCRIPTION" ] || exit 0
        echo "$PKGNAME"
        exit
        ;;
    "--product-alternatives")
        print_product_alt $PRODUCTALT
        exit
        ;;
    "--installed")
        #epm installed $PKGNAME
        is_repacked_package $PKGNAME
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

        if epm mark checkhold "$PKGNAME" ; then
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
            # latestpkgver <= $pkgver
            if [ -z "$force" ] && [ "$(epm print compare package version $latestpkgver $pkgver)" != "1" ] ; then
                if [ "$latestpkgver" = "$pkgver" ] ; then
                    echo "Latest available version of $PKGNAME $latestpkgver is already installed."
                else
                    echo "Latest available version of $PKGNAME: $latestpkgver, but you a newer version installed: $pkgver."
                fi
                exit
            fi

            echo "Updating $PKGNAME from $pkgver to the latest available version (equal to $latestpkgver or newer) ..."
            #if [ -n "$force" ] ; then
            #    echo "Updating $PKGNAME from $pkgver to latest available version ..."
            #else
            #    echo "Updating $PKGNAME from $pkgver to $latestpkgver version ..."
            #    VERSION="$latestpkgver"
            #fi
        fi
        # pass to run play code
        ;;
    "--run")
        # just pass to run play code
        ;;
    *)
        fatal "Unknown command '$1'. Use this script only via epm play."
        ;;
esac

# --update/--run

is_supported_arch "$(epm print info -a)" || fatal "Only '$SUPPORTEDARCHES' architectures is supported"


# skip install if there is package installed not via epm play
is_repacked_package $REPOPKGNAME || exit 0

# default version value (can be overrided with arg $2 or by update)
[ -n "$VERSION" ] || VERSION="*"

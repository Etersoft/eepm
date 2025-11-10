#!/bin/sh

# kind of hack: inheritance --force from main epm
echo "$EPM_OPTIONS" | grep -q -- "--force" && force="--force"
echo "$EPM_OPTIONS" | grep -q -- "--auto" && auto="--auto"
echo "$EPM_OPTIONS" | grep -q -- "--latest" && latest="true"
[ -n "$EGET_IPFS_DB" ] && ipfs="true"


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

# print a path to the command if exists in $PATH
if a= type -a type 2>/dev/null >/dev/null ; then
print_command_path()
{
    a= type -fpP -- "$1" 2>/dev/null
}
elif a= which which 2>/dev/null >/dev/null ; then
    # the best case if we have which command (other ways needs checking)
    # TODO: don't use which at all, it is a binary, not builtin shell command
print_command_path()
{
    a= which -- "$1" 2>/dev/null
}
else
print_command_path()
{
    a= type "$1" 2>/dev/null | sed -e 's|.* /|/|'
}
fi

# check if <arg> is a real command
is_command()
{
    print_command_path "$1" >/dev/null
}

is_url()
{
    echo "$1" | grep -q "^[filehtps]*:/"
}


#__showcmd_shifted()
#{
#    local s="$1"
#    shift
#    shift $s
#    showcmd "$*"
#}

# support for direct run a play script
if [ -x "../bin/epm" ] ; then
    export PATH="$(realpath ../bin):$PATH"
fi

# add to all epm calls
#EPM="$(epm tool which epm)" || fatal
EPM="$(print_command_path epm)" || fatal
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

warn_version_is_not_supported()
{
    [ "$VERSION" = "*" ] && return
    if [ -n "$ipfs" ] ; then
        echo -e "\nWarning: Specifying the version is not supported by vendor. But you run me with --ipfs, so I am working around it ...\n"
        return
    fi
    echo -e "\nWarning: Specifying the version is not supported by vendor. Downloading latest version ...\n"
    VERSION="*"
}

override_pkgname()
{
    PKGNAME="$1"
    export EEPM_INTERNAL_PKGNAME="$PKGNAME"
}

# epm install $PKGURL
install_pkgurl()
{
    local repack=''
    local pkgtype="$(epm print info -p)"

    # we have workaround for their postinstall script, so always repack rpm package
    # TODO: repack for deb systems too
    [ "$pkgtype" = "rpm" ] && repack='--repack'

    [ -n "$PKGURL" ] || fatal "Can't get package URL. Try use epm play --latest <app> to get latest version."

    epm install $repack $PKGURL "$@" || exit
}

# epm pack --install $PKGNAME "$PKGURL"
install_pack_pkgurl()
{
    local repack=''
    local pkgtype="$(epm print info -p)"

    # we have workaround for their postinstall script, so always repack rpm package
    # TODO: repack for deb systems too
    [ "$pkgtype" = "rpm" ] && repack='--repack'

    [ -n "$PKGURL" ] || fatal "Can't get package URL. Try use epm play --latest <app> to get latest version."

    epm pack $repack --install $PKGNAME "$PKGURL" "$@"
}

# ["version"]
parse_json_value()
{
    local field="$1"
    echo "$field" | grep -q -E "^\[" || field='["'$field'"]'
    epm tool json -b | grep -m1 -F "$field" | sed -e 's|.*[[:space:]]||' | sed -e 's|"\(.*\)"|\1|g'
}

# URL/file ["version"]
get_json_value()
{
    if is_url "$1" ; then
        eget -q -O- "$1" | parse_json_value "$2"
    else
        [ -s "$1" ] || fatal "File $1 is missed, can't get json"
        parse_json_value "$2" < "$1"
    fi
}

snap_get_pkgurl()
{
    local SNAPNAME="$1"
    ARCH="$(epm print info --debian-arch)"
    is_url "$SNAPNAME" && SNAPNAME="$(basename "$SNAPNAME")"
    eget -O- -H Snap-Device-Series:16 https://api.snapcraft.io/v2/snaps/info/$SNAPNAME | epm --inscript tool json -b | grep -A 8 "$ARCH" | grep '\["channel-map",[0-9],"download","url"\]' | head -n1 | sed 's/.*"\(https:\/\/.*\)".*/\1/'
}

snap_get_version()
{
    local SNAPNAME="$1"
    ARCH="$(epm print info --debian-arch)"
    is_url "$SNAPNAME" && SNAPNAME="$(basename "$SNAPNAME")"
    eget -O- -H Snap-Device-Series:16 https://api.snapcraft.io/v2/snaps/info/$SNAPNAME | parse_json_value '["channel-map",0,"version"]'
}

# return version only for the first package
get_latest_version()
{
    local ver
    local epmver="$(epm --short --version 2>/dev/null)"
    local URL
    epmver=$(echo "$epmver" | sed -e 's|\.[0-9]*$||')
    for URL in "https://eepm.ru/releases/$epmver/app-versions" ; do
        echo "Getting latest version from $URL/$1 ..." >&2
        ver="$(eget -q -O- "$URL/$1" 2>/dev/null)" || continue
        ver="$(echo "$ver" | head -n1 | cut -d" " -f1)"
        [ -n "$ver" ] && echo "$ver" && return
    done
}

# copied from epm-sh-functions
# copied from eget's filter_glob
# check man glob
__convert_glob__to_regexp()
{
    # translate glob to regexp
    echo "$1" | sed -e "s|\*|.*|g" -e "s|?|.|g"
}

get_github_release_info() {
    local url="$1"
    local user_and_repo=${url#https://github.com/}
    
    eget -O- "https://api.github.com/repos/${user_and_repo%/}/releases"
}

get_github_url()
{
    local url="$1"
    local asset_name="$2"

    # See tdesktop.*.tar.gz
    #echo "$asset_name" | grep -q "\.[*?]" && fatal "Only glob symbols * and ? are supported. Don't use regexp! Input string: $asset_name"
    wc="$(__convert_glob__to_regexp "$asset_name")"

    if [ "$3" == "prerelease" ] ; then
        get_github_release_info "$url" | grep 'browser_download_url' | grep -iEo 'https.*download.*' | grep -E "$wc" | head -n1 | sed -e 's|"$||'
    else
        get_github_release_info "$url" \
        | awk '{
    if ($0 ~ /"prerelease": false/) {
        prerelease = 0;
    } else if ($0 ~ /"prerelease": true/) {
        prerelease = 1;
    }
    if (!prerelease && $0 ~ /"browser_download_url":/) {
        match($0, /"browser_download_url": "(https[^"]*)"/, arr);
        print arr[1];
    }
}' | grep -E "$wc" | head -n1 | sed -e 's|"$||'
    fi

}

get_github_tag()
{
    local url="$1"
    local flag="$2"
    local json
    json="$(get_github_release_info "$url")"

    jv()
    {
        local item="$1"
        local tag="$2"
        echo "$json" | parse_json_value "[$item,\"$tag\"]" 2>/dev/null
    }

    local item
    for item in $(seq 0 100) ; do
        local val
        val=$(jv $item "tag_name")
        [ -n "$val" ] || return
        echo "Checking for [$item,$val] ..." >&2
        #[0,"draft"]     false
        #[0,"prerelease"]        true
        [ "$(jv $item "draft")" = "true" ] && continue
        [ "$flag" == "prerelease" ] && break
        [ "$(jv $item "prerelease")" = "true" ] && continue
        break
    done

    echo "$val" | grep -oP '[0-9]+(\.[0-9]+)*(-[0-9]+)?' | head -n1
    return
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


is_pkg_enough()
{
    local PKG="$1"
    local needed="$2"
    # epm print enough package version "$PKG" "$needed"
    epm status --installed "$PKG" "$needed"
}

# arg: minimal require of libstdc++ version
# return true is we have such version
is_stdcpp_enough()
{
    local needed="$1"
    local STDCPKG="libstdc++"
    epm status --installed $STDCPKG || STDCPKG="libstdc++6"

    is_pkg_enough $STDCPKG $needed
}

is_glibc_enough()
{
    local needed="$1"
    local PKG="glibc-core"
    epm status --installed $PKG || PKG="glibc"

    is_pkg_enough $PKG $needed
}

is_openssl_enough()
{
    local needed="$1"
    local PKG="openssl"

    is_pkg_enough $PKG $needed
}


get_first()
{
    echo "$1"
}

check_alternative_pkgname()
{
    [ -n "$BASEPKGNAME" ] || BASEPKGNAME="$PKGNAME"
    [ -n "$BASEPKGNAME" ] || return

    # default: with first entry in $PRODUCTALT
    BRANCH=$(get_first $PRODUCTALT)
    [ "$BRANCH" = "''" ] && BRANCH=""
    PKGNAME="$BASEPKGNAME-$BRANCH"

    # override with VERSION
    local i
    for i in $PRODUCTALT ; do
        if [ "$i" = "''" ] ; then
            PKGNAME=$BASEPKGNAME
            continue
        fi
        if [ "$VERSION" = "$i" ] ; then
            PKGNAME=$BASEPKGNAME-$i
            BRANCH="$i"
            VERSION=""
            return
        fi
    done

    # when VERSION is not in PRODUCTALT, check installed package
    for i in $PRODUCTALT ; do
        if [ "$i" = "''" ] ; then
            continue
        fi
        if epm status --installed $BASEPKGNAME-$i ; then
            PKGNAME=$BASEPKGNAME-$i
            BRANCH="$i"
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

    epm status --supported || return 1

    [ -n "$force" ] && return 0

    if epm status --original $pkg ; then
       echo "Package $pkg is already installed from repository (use --force to override it)."
       return 1
    fi

    if epm status --certified $pkg ; then
       # allow install/update if we agreed with their package
       return 0
    fi

    if epm status --thirdparty $pkg ; then
       [ -n "$SKIPREPACK" ] && return 0
       echo "Package $pkg is already installed, packaged by vendor $(epm print field Vendor for $pkg)."
       return 1
    fi

    if ! epm status --repacked $pkg ; then
       echo "Package $pkg is already installed (possible, manually packed)."
       return 1
    fi

    return 0
}

is_repacked_packages()
{
    local pkg
    local pkgs="$1"
    [ -n "$pkgs" ] || pkgs="$PKGNAME"
    [ -n "$pkgs" ] || return 0 #fatal "is_repacked_package() is called without package name"
    for pkg in $pkgs ; do
        is_repacked_package $pkg || return
    done
}

check_for_product_update()
{
    # HACK: check version only by first package (we assume all packages have the same version)
    pkgver="$(epm print version for package $PKGNAME | head -n1)"
    latestpkgver="$(get_latest_version $PKGNAME)"

    # ignore update if have no latest package version or the latest package version no more than installed one
    [ -n "$pkgver" ] || return

    if [ -z "$latestpkgver" ] ; then
        echo "Can't get info about latest version of $PKGNAME, so skip updating installed version $pkgver."
        exit
    fi
    # latestpkgver <= $pkgver
    if [ -z "$force" ] || [ -z "$latest" ] ; then
        if [ "$(epm print compare package version $latestpkgver $pkgver)" != "1" ] ; then
            if [ "$latestpkgver" = "$pkgver" ] ; then
                echo "Latest available version of $PKGNAME $latestpkgver is already installed."
            else
                echo "Latest available version of $PKGNAME: $latestpkgver, but you have a newer version installed: $pkgver."
            fi
            exit
        fi
    fi

    #echo "Updating $PKGNAME from $pkgver to the latest available version (equal to $latestpkgver or newer) ..."
    if [ -n "$force" ] || [ -z "$latest" ] ; then
        echo "Updating $PKGNAME from $pkgver to latest available version ..."
    else
        echo "Updating $PKGNAME from $pkgver to $latestpkgver version ..."
        VERSION="$latestpkgver"
    fi
}



case "$1" in
    "--description")
        is_supported_arch "$2" || exit 0
        echo "$DESCRIPTION"
        exit
        ;;
    "--product-alternatives")
        print_product_alt $PRODUCTALT
        exit
        ;;
esac

# set PKGNAME to $BASEPKGNAME-$VERSION if $VERSION is found in PRODUCTALT
[ -n "$PRODUCTALT" ] && check_alternative_pkgname
[ -n "$PKGNAME" ] || fatal "Can't get PKGNAME"

pkgtype="$(epm print info -p)"
# deb targets always in low case
[ "$pkgtype" = "deb" ] && PKGNAME="$(echo $PKGNAME | tr "[A-Z]" "[a-z]")"


case "$1" in
    "--package-name")
        #[ -n "$DESCRIPTION" ] || exit 0
        echo "$PKGNAME"
        exit
        ;;
    "--installed")
        #epm installed $PKGNAME
        is_repacked_packages $PKGNAME
        exit
        ;;
esac

. $(dirname $0)/common-outformat.sh

check_tty

case "$1" in
    "--remove")
        #is_repacked_packages || exit 0
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
    "--installed-version")
        epm print version for package $PKGNAME | head -n1
        exit
        ;;
    "--update")
        pkgtext="package"
        pkgistext="package is"
        epm tool estrlist has_space "$PKGNAME" 2>/dev/null && pkgtext="packages" && pkgistext="packages are"

        if ! epm installed $PKGNAME ; then
            echo "Skipping update of $PKGNAME ($pkgistext not installed)"
            exit
        fi

        if epm mark checkhold $PKGNAME ; then
            echo "Skipping update of $PKGNAME ($pkgistext on hold, see '# epm mark showhold')"
            exit
        fi

        check_for_product_update
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

#epm tool estrlist has_space "$PKGNAME" && fatal "play.d/common does not support a new packages in PKGNAME at all!"

# skip install if there is package installed not via epm play
is_repacked_packages $REPOPKGNAME || exit 0

# hack for hplip
[ "$PKGNAME" = "hplip-plugin" ] && VERSION="*"

if [ -z "$VERSION" ] && [ -z "$force" ] && [ -z "$latest" ] ; then
    # by default use latest known version to install
    VERSION="$(get_latest_version $PKGNAME)"
    CHECKED_VERSION="$VERSION"
fi

# default version value (can be overrided with arg $2 or by update)
[ -n "$VERSION" ] || VERSION="*"

echo
echo "Installing $DESCRIPTION as $PKGNAME $pkgtext ..."

export EEPM_INTERNAL_PKGNAME="$PKGNAME"

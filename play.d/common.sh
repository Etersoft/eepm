#!/bin/sh

# kind of hack: inheritance --force from main epm
echo "$EPM_OPTIONS" | grep -q -- "--force" && force="--force"
echo "$EPM_OPTIONS" | grep -q -- "--auto" && auto="--auto"
echo "$EPM_OPTIONS" | grep -q -- "--latest" && latest="true"
echo "$EPM_OPTIONS" | grep -q -- "--print-url" && print_url="true"
[ -n "$EGET_IPFS_DB" ] && ipfs="true"


fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

info()
{
    echo "$*" >&2
}

[ -n "$BIGTMPDIR" ] || [ -d "/var/tmp" ] && BIGTMPDIR="/var/tmp" || BIGTMPDIR="/tmp"

cd_to_temp_dir()
{
    PKGDIR=$(mktemp -d --tmpdir=$BIGTMPDIR)
    trap 'rm -fr "$PKGDIR"' EXIT
    cd "$PKGDIR" || fatal
}

# detect bash
is_bash()
{
    [ -n "$BASH_VERSION" ]
}

# print a path to the command if exists in $PATH
if is_bash ; then
print_command_path()
{
    type -fpP -- "$1" 2>/dev/null
}
else
print_command_path()
{
    command -v "$1" 2>/dev/null
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

# return major epm version (e.g. 3.64 from 3.64.49)
epm_major_version()
{
    local ver="${EPMVERSION%%-*}"
    echo "${ver%.*}"
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
    [ "$1" = "--quiet" ] && shift && $EPM --quiet "$@" && return
    if [ "$1" != "print" ] && [ "$1" != "tool" ] && [ "$1" != "status" ] ; then
        showcmd "$(basename $EPM) $*"
    fi
    $EPM "$@"
}


eget()
{
    epm tool eget "$@"
}

fetch_url()
{
    info "Fetching $1 ..."
    $EPM --quiet tool eget -q -O- "$1"
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

# set awaited pkgname to check with
override_pkgname()
{
    PKGNAME="$1"
    export EEPM_INTERNAL_PKGNAME="$PKGNAME"
}

__suggest_ipfs_on_error()
{
    if [ -z "$ipfs" ] ; then
        local playname="$(basename $0 .sh)"
        info
        info 'Tip: try $ epm play --ipfs '$playname' to install from IPFS cache.'
    fi
    exit 1
}

# epm install $PKGURL
install_pkgurl()
{
    local repack=''

    # we have workaround for their postinstall script, so always repack rpm package
    # TODO: repack for deb systems too
    [ "$PKGFORMAT" = "rpm" ] && repack='--repack'

    [ -n "$PKGURL" ] || fatal "Can't get package URL. Try use epm play --latest <app> to get latest version."

    if [ -n "$print_url" ] ; then
        echo "$PKGURL"
        exit 0
    fi

    epm install $repack $PKGURL "$@" || __suggest_ipfs_on_error
}

# epm pack --install $PKGNAME "$PKGURL"
install_pack_pkgurl()
{
    local repack=''

    # we have workaround for their postinstall script, so always repack rpm package
    # TODO: repack for deb systems too
    [ "$PKGFORMAT" = "rpm" ] && repack='--repack'

    [ -n "$PKGURL" ] || fatal "Can't get package URL. Try use epm play --latest <app> to get latest version."

    if [ -n "$print_url" ] ; then
        echo "$PKGURL"
        exit 0
    fi

    epm pack $repack --install $PKGNAME "$PKGURL" "$@" || __suggest_ipfs_on_error
}

# ["version"]
parse_json_value()
{
    local field="$1"
    echo "$field" | grep -q -E "^\[" || field='["'$field'"]'
    epm --inscript --quiet tool json -b | grep -m1 -F "$field" | sed -e 's|.*[[:space:]]||' | sed -e 's|"\(.*\)"|\1|g'
}

# URL/file ["version"]
get_json_value()
{
    epm tool json --get-json-value "$1" "$2"
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

# load VERSION and RELEASE from app-versions (sets global variables)
load_latest_version()
{
    local line
    local epmver="$(epm_major_version)"
    local URL
    VERSION=""
    RELEASE=""
    for URL in "https://eepm.ru/releases/$epmver/app-versions" ; do
        echo "Getting latest version from $URL/$1 ..." >&2
        line="$(eget -q -O- "$URL/$1" 2>/dev/null)" || continue
        line="$(echo "$line" | head -n1)"
        VERSION="$(echo "$line" | cut -d" " -f1)"
        RELEASE="$(echo "$line" | cut -d" " -f2 -s)"
        [ -n "$VERSION" ] && return 0
    done
    return 1
}

# return version only for the first package (compatibility wrapper)
get_latest_version()
{
    load_latest_version "$1"
    [ -n "$VERSION" ] && echo "$VERSION"
}

# extract release suffix from package release field
# epm1.repacked.b1 -> b1, epm1.repacked.1 -> 1
get_release_suffix()
{
    echo "$1" | sed -n 's/epm[0-9]*\.repacked\.//p'
}

# build full version string for comparison: VERSION-RELEASE
# usage: build_full_version VERSION [RELEASE]
build_full_version()
{
    local ver="$1"
    local rel="$2"
    if [ -n "$rel" ] ; then
        echo "$ver-$rel"
    else
        echo "$ver"
    fi
}

# get full version of installed package (VERSION-RELEASE)
# usage: get_installed_full_version PKGNAME
get_installed_full_version()
{
    local pkg="$1"
    local ver="$(epm print version for package $pkg 2>/dev/null | head -n1)"
    local rel="$(epm print release for package $pkg 2>/dev/null | head -n1)"
    local rel_suffix="$(get_release_suffix "$rel")"
    build_full_version "$ver" "$rel_suffix"
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
    local flag="$2"
    local user_and_repo=${url#https://github.com/}

    if [ "$flag" = "latest" ] ; then
        fetch_url "https://api.github.com/repos/${user_and_repo%/}/releases/latest"
    else
        fetch_url "https://api.github.com/repos/${user_and_repo%/}/releases"
    fi
}

# Extract browser_download_url values from GitHub release JSON via epm tool json.
# Handles both single-line and multi-line JSON correctly.
__get_github_download_urls()
{
    epm --inscript --quiet tool json -b | grep '"browser_download_url"' | sed -e 's|.*[[:space:]]||' -e 's|"||g'
}

get_github_url()
{
    local url="$1"
    local asset_name="$2"
    local user_and_repo=${url#https://github.com/}
    user_and_repo=${user_and_repo%/}

    # If asset_name has no globs, try direct URL without API call
    if ! echo "$asset_name" | grep -q '[*?]' ; then
        local direct
        for tag in "$VERSION" "v$VERSION" ; do
            direct="https://github.com/$user_and_repo/releases/download/$tag/$asset_name"
            eget --check-url "$direct" 2>/dev/null && echo "$direct" && return
        done
    fi

    # See tdesktop.*.tar.gz
    #echo "$asset_name" | grep -q "\.[*?]" && fatal "Only glob symbols * and ? are supported. Don't use regexp! Input string: $asset_name"
    wc="$(__convert_glob__to_regexp "$asset_name")"

    if [ "$3" == "prerelease" ] ; then
        get_github_release_info "$url" | __get_github_download_urls | grep -E "$wc" | head -n1
    else
        local result
        result="$(get_github_release_info "$url" "latest" | __get_github_download_urls | grep -E "$wc" | head -n1)"
        if [ -z "$result" ] ; then
            result="$(get_github_release_info "$url" \
            | __get_github_download_urls | grep -E "$wc" | head -n1)"
        fi
        echo "$result"
    fi

}

# Get asset checksum from GitHub latest release
# Usage: get_github_asset_checksum repo asset_name
# Returns: sha256 checksum (without sha256: prefix)
get_github_asset_checksum()
{
    local repo="$1"
    local asset_name="$2"
    local json digest

    json=$(fetch_url "https://api.github.com/repos/$repo/releases/latest") || return 1
    # Find the asset by name and extract its digest
    digest=$(echo "$json" | awk -v name="$asset_name" '
        /"name":/ { found = ($0 ~ "\"" name "\"") }
        found && /"digest":/ { gsub(/.*sha256:|".*/, ""); print; exit }
    ')
    echo "$digest"
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
        [ -n "$val" ] || break
        echo "Checking for [$item,$val] ..." >&2
        #[0,"draft"]     false
        #[0,"prerelease"]        true
        [ "$(jv $item "draft")" = "true" ] && continue
        [ "$flag" == "prerelease" ] && break
        [ "$(jv $item "prerelease")" = "true" ] && continue
        break
    done

    local version
    version="$(echo "$val" | grep -oP '[0-9]+(\.[0-9]+)*(-[0-9]+)?' | head -n1)"
    [ -n "$version" ] || fatal "Can't get tag from GitHub. Check network or use epm play <app>=<version>"
    echo "$version"
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
    epm status --installed $PKG || PKG="libc6"

    is_pkg_enough $PKG $needed
}

is_openssl_enough()
{
    local needed="$1"

    is_soname_present "libssl.so.$needed"
}

get_path_by_soname()
{
    local libdir
    for libdir in /usr/lib/x86_64-linux-gnu /usr/lib64 /lib64 ; do
        [ -r $libdir/$1 ] && echo "$libdir/$1" && return
    done
    return 1
}

is_soname_present()
{
    get_path_by_soname "$1" >/dev/null
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

    epm status --installed $pkg >/dev/null 2>&1 || return 0

    if ! epm status --supported $pkg ; then
       echo "Status checking is not supported for $(epm print info -e). Skipping installed package check (use --force to override)."
       return 1
    fi

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

# Check if package is installed and managed by us (for --installed check)
is_installed_by_play()
{
    local pkg="$1"
    [ -n "$pkg" ] || pkg="$PKGNAME"
    [ -n "$pkg" ] || return 1

    # Check exact package first
    if epm status --installed $pkg >/dev/null 2>&1 ; then
        epm status --repacked $pkg >/dev/null 2>&1 && return 0
    fi

    # If BASEPKGNAME and PRODUCTALT are set, check only valid alternatives
    [ -n "$BASEPKGNAME" ] || return 1
    [ -n "$PRODUCTALT" ] || return 1
    local i
    for i in $PRODUCTALT ; do
        if [ "$i" = "''" ] ; then
            # Check base package without suffix
            if epm status --installed "$BASEPKGNAME" >/dev/null 2>&1 ; then
                epm status --repacked "$BASEPKGNAME" >/dev/null 2>&1 && return 0
            fi
        else
            if epm status --installed "$BASEPKGNAME-$i" >/dev/null 2>&1 ; then
                epm status --repacked "$BASEPKGNAME-$i" >/dev/null 2>&1 && return 0
            fi
        fi
    done

    return 1
}

# check if installed version is up to date, exit if no update needed
# --latest: skip version check, update from upstream
# --force: skip "already installed" check
check_for_product_update()
{
    local fullpkgver="$(get_installed_full_version "$(__lowpkgname "$PKGNAME")")"

    # not installed yet, proceed with install
    [ -n "$fullpkgver" ] || return

    # --latest or --force: update from upstream, don't check app-versions
    if [ -n "$latest" ] || [ -n "$force" ] ; then
        echo "Updating $PKGNAME from $fullpkgver to latest upstream version ..."
        return
    fi

    # user specified explicit version (e.g., epm play app=1.2.3): skip app-versions check
    if [ -n "$VERSION" ] && [ "$VERSION" != "*" ] ; then
        echo "Installing $PKGNAME version $VERSION (explicit version requested) ..."
        return
    fi

    load_latest_version $PKGNAME
    local fulllatestver="$(build_full_version "$VERSION" "$RELEASE")"

    if [ -z "$VERSION" ] ; then
        echo "Can't get info about latest version of $PKGNAME, so skip updating installed version $fullpkgver."
        exit
    fi

    # --force: reinstall even if same version
    if [ -n "$force" ] ; then
        echo "Updating $PKGNAME from $fullpkgver to $fulllatestver version (forced) ..."
        return
    fi

    # fulllatestver <= fullpkgver: no update needed
    if [ "$(epm print compare package version $fulllatestver $fullpkgver)" != "1" ] ; then
        if [ "$fulllatestver" = "$fullpkgver" ] ; then
            echo "Latest available version of $PKGNAME $fulllatestver is already installed."
        else
            echo "Latest available version of $PKGNAME: $fulllatestver, but you have a newer version installed: $fullpkgver."
        fi
        exit
    fi

    echo "Updating $PKGNAME from $fullpkgver to $fulllatestver version ..."
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

# lowercase package name for deb package manager commands (alien lowercases when converting rpm to deb)
__lowpkgname() { [ "$PKGFORMAT" = "deb" ] && echo "$1" | tr "A-Z" "a-z" || echo "$1" ; }

case "$1" in
    "--package-name")
        #[ -n "$DESCRIPTION" ] || exit 0
        __lowpkgname "$PKGNAME"
        exit
        ;;
    "--installed")
        is_installed_by_play "$(__lowpkgname "$PKGNAME")"
        exit
        ;;
esac

. $(dirname $0)/common-outformat.sh

check_tty

case "$1" in
    "--remove")
        #is_repacked_packages || exit 0
        epm remove "$(__lowpkgname "$PKGNAME")"
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
        get_installed_full_version "$(__lowpkgname "$PKGNAME")"
        exit
        ;;
    "--available-version")
        load_latest_version $PKGNAME
        build_full_version "$VERSION" "$RELEASE"
        exit
        ;;
    "--update")
        pkgtext="package"
        pkgistext="package is"
        epm tool estrlist has_space "$PKGNAME" 2>/dev/null && pkgtext="packages" && pkgistext="packages are"

        if ! epm installed "$(__lowpkgname "$PKGNAME")" ; then
            echo "Skipping update of $PKGNAME ($pkgistext not installed)"
            exit
        fi

        if epm mark checkhold "$(__lowpkgname "$PKGNAME")" ; then
            echo "Skipping update of $PKGNAME ($pkgistext on hold, see '# epm mark showhold')"
            exit
        fi

        [ -n "$force" ] || [ -n "$latest" ] || check_for_product_update
        # pass to run play code
        ;;
    "--run")
        [ -n "$force" ] || [ -n "$latest" ] || check_for_product_update
        # pass to run play code
        ;;
    *)
        fatal "Unknown command '$1'. Use this script only via epm play."
        ;;
esac

# --update/--run

is_supported_arch "$SYSTEMARCH" || fatal "Only '$SUPPORTEDARCHES' architectures is supported"

#epm tool estrlist has_space "$PKGNAME" && fatal "play.d/common does not support a new packages in PKGNAME at all!"

# skip install if there is package installed not via epm play
is_repacked_packages $REPOPKGNAME || exit 0

# hack for hplip
[ "$PKGNAME" = "hplip-plugin" ] && VERSION="*" && RELEASE="*"

if [ -z "$VERSION" ] && [ -z "$force" ] && [ -z "$latest" ] ; then
    # by default use latest known version to install (also sets RELEASE)
    load_latest_version $PKGNAME
    CHECKED_VERSION="$VERSION"
    # hack
    [ -n "VERSION" ] && [ -z "$RELEASE" ] && RELEASE="1"
fi

# default version value (can be overrided with arg $2 or by update)
[ -n "$VERSION" ] || VERSION="*"
[ -n "$RELEASE" ] || RELEASE="*"

echo
echo "Installing $DESCRIPTION as $PKGNAME $pkgtext ..."

export EEPM_INTERNAL_PKGNAME="$PKGNAME"

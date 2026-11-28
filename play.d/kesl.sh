#!/bin/sh

PKGNAME=kesl
# the vendor package is installed as is: all files are shipped in a staging dir
# (/var/opt/kaspersky/kesl/install_<version>) and the postinstall script runs
# the vendor launcher to install them into /opt/kaspersky/kesl
SKIPREPACK=1
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Kaspersky Endpoint Security for Linux from the official site"
URL="https://www.kaspersky.ru/small-to-medium-business-security/downloads/endpoint"
TIPS="Kaspersky Endpoint Security for Linux requires a commercial license (activation code or key file).
After install configure it interactively:
# /opt/kaspersky/kesl/bin/kesl-setup.pl
or non-interactively with the settings file (see /opt/kaspersky/kesl/doc/autoinstall.ini for the parameters):
# /opt/kaspersky/kesl/bin/kesl-setup.pl --autoinstall=/path/to/autoinstall.ini
Fanotify file interceptor is used by default. The optional kernel module interceptor needs kernel headers, gcc and make.
Only configured application can be updated to a new version."

case "$1" in
    "--remove")
        # the vendor preuninstall script removes the installed files
        epm remove --scripts $PKGNAME
        exit
        ;;
esac

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"
arch="$(epm print info -a)"

case "$pkgtype" in
    rpm)
        ;;
    deb)
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        ;;
    *)
        fatal "$(epm print info -e) is not supported (package type is $pkgtype)"
        ;;
esac

# The download links contain random hash dirs, so the package URL is always
# taken from the vendor downloads API (it lists the several last versions).
APIURL="https://api-router.kaspersky-labs.com/downloads/search/v5/b2b?productcode=2911379&sites=https://www.kaspersky.ru"

# convert version mask to regexp (* means any version)
__ver_re()
{
    if [ "$1" = "*" ] ; then
        echo "[0-9][0-9.]*"
    else
        echo "$1" | sed -e 's|\.|\\.|g'
    fi
}

# get the link to the package file for VERSION and RELEASE (the latest one if several)
get_kesl_url()
{
    local ver_re="$(__ver_re "$1")"
    local rel_re="$(__ver_re "$2")"
    local file_re
    if [ "$pkgtype" = "deb" ] ; then
        file_re="kesl_$ver_re-${rel_re}_$arch\.deb"
    else
        file_re="kesl-$ver_re-$rel_re\.$arch\.rpm"
    fi
    echo "$downloads" | grep -o "\"Link\":\"https://[^\"]*/$file_re\"" | sed -e 's|^"Link":"||' -e 's|"$||' | \
        awk -F/ '{print $NF "\t" $0}' | sort -V | tail -n1 | cut -f2
}

downloads="$(fetch_url "$APIURL")" || fatal "Can't get the downloads list from $APIURL"

PKGURL="$(get_kesl_url "$VERSION" "$RELEASE")"
# app-versions can contain the version without the build number
[ -z "$PKGURL" ] && [ "$RELEASE" != "*" ] && PKGURL="$(get_kesl_url "$VERSION" "*")"
[ -n "$PKGURL" ] || fatal "Can't find kesl $VERSION package for $arch on the vendor site. Try epm play --latest kesl to install the latest version."

if [ -n "$print_url" ] ; then
    echo "$PKGURL"
    exit 0
fi

# install the vendor package with its scripts (they do the actual installation)
epm install --scripts "$PKGURL" || __suggest_ipfs_on_error

echo
echo "$TIPS"

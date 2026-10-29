#!/bin/sh

PKGNAME=1c-enterprise
SUPPORTEDARCHES="x86_64"
VERSION="${2:-*}"
DESCRIPTION="1C:Enterprise platform from an official local package"
URL="https://releases.1c.ru/"
TIPS="Download the official Linux package from $URL and run:
epm play 1c = /path/to/1c-enterprise-*.rpm
epm play 1c = /path/to/client_*.rpm64.zip
epm play 1c = /path/to/client_*.deb64.zip
epm play 1c = /path/to/setup-full-8.*.run"

. $(dirname $0)/common.sh

EPM_LOCAL="$(dirname "$0")/../bin/epm"
[ -x "$EPM_LOCAL" ] && EPM="$(realpath "$EPM_LOCAL")"

SOURCE="$VERSION"

if [ -n "$3" ] && [ ! -r "$SOURCE" ] && [ -r "$SOURCE-$3" ] ; then
    SOURCE="$SOURCE-$3"
fi

print_usage()
{
    cat <<EOF
1C:Enterprise packages are available only after authorization on the 1C site, so eepm cannot download them automatically.

Download the official Linux package from $URL and run one of:

epm play 1c = /path/to/1c-enterprise-*.rpm
epm play 1c = /path/to/client_*.rpm64.zip
epm play 1c = /path/to/client_*.deb64.zip
epm play 1c = /path/to/setup-full-8.*.run

You can also repack/install directly:

EPM_REPACK_SCRIPT=1c-enterprise epm install --repack /path/to/1c-enterprise-*.rpm
epm pack --install 1c83-client /path/to/setup-full-8.*.run
EOF
}

install_package()
{
    local package="$1"
    local abs

    abs="$(realpath "$package")" || fatal "Can't resolve $package"
    case "$package" in
        *.rpm)
            ( unset EEPM_INTERNAL_PKGNAME ; EPM_REPACK_SCRIPT=1c-enterprise "$EPM" --auto repack --install "$abs" )
            ;;
        *.deb)
            ( unset EEPM_INTERNAL_PKGNAME ; "$EPM" --auto pack --install 1c83-universal "$abs" )
            ;;
        *) fatal "Unsupported 1C package format: $package" ;;
    esac
}

install_archive()
{
    case "$(basename "$1")" in
        *deb*.zip|*deb*.tar.gz|*deb*.tgz)
            ( unset EEPM_INTERNAL_PKGNAME ; "$EPM" --auto pack --install 1c83-universal "$1" )
            ;;
        *)
            ( unset EEPM_INTERNAL_PKGNAME ; EPM_REPACK_SCRIPT=1c-enterprise "$EPM" --auto pack --repack --install 1c83-universal "$1" )
            ;;
    esac
}

install_run()
{
    override_pkgname 1c83-client
    "$EPM" --auto pack --install 1c83-client "$1"
}

if [ -z "$SOURCE" ] || [ "$SOURCE" = "*" ] ; then
    print_usage
    exit 1
fi

[ -r "$SOURCE" ] || fatal "Can't read $SOURCE"

if [ -n "$print_url" ] ; then
    echo "$SOURCE"
    exit 0
fi

[ ! -d "$SOURCE" ] || fatal "Use full path to 1C package file with extension, not a directory: $SOURCE"

case "$SOURCE" in
    *.rpm|*.deb)
        install_package "$SOURCE"
        ;;
    *.zip|*.tar.gz|*.tgz)
        install_archive "$SOURCE"
        ;;
    *.run)
        install_run "$SOURCE"
        ;;
    *)
        fatal "Unsupported 1C package format: $SOURCE"
        ;;
esac

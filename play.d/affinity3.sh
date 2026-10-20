#!/bin/sh

PKGNAME=affinity3
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Affinity v3 creative suite (Wine based) from the official site"
URL="https://www.affinity.studio/"
WINGET_VERSIONS_URL="https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/c/Canva/Affinity"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# The online installer has no version; use the latest published Affinity version.
if [ "$VERSION" = "*" ] ; then
    VERSION="$(epm --quiet tool eget -q -t 1 -O- "$WINGET_VERSIONS_URL" 2>/dev/null \
        | epm --inscript --quiet tool json -b 2>/dev/null \
        | sed -n 's/^\[[0-9][0-9]*,"name"\][[:space:]]*"\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)"/\1/p' \
        | sort -V | tail -n1)"
    [ -n "$VERSION" ] || fatal "Can't get latest Affinity v3 version"
fi

PKGURL="https://downloads.affinity.studio/Affinity%20x64.exe"

# Avoid installing prerequisites when only the upstream URL was requested.
[ -n "$print_url" ] && install_pack_pkgurl $VERSION

# Winetricks configures the prefix, while setup.sh points it at the bundled Wine runtime.
epm assure winetricks || fatal "winetricks is required"
epm assure dotnet || fatal ".NET runtime 8 is required"
is_command curl || epm assure wget || fatal "curl or wget is required"
epm assure tar || fatal "tar is required"
epm assure xz || fatal "xz is required"
epm assure zstd || fatal "zstd is required"
is_command unzip || epm assure 7z p7zip || fatal "unzip or 7z is required"
if ! is_command kdialog && ! is_command zenity ; then
    case "${XDG_CURRENT_DESKTOP:-}${DESKTOP_SESSION:-}" in
        *KDE*|*Plasma*|*plasma*) epm assure kdialog || epm assure zenity || fatal "kdialog or zenity is required" ;;
        *) epm assure zenity || epm assure kdialog || fatal "zenity or kdialog is required" ;;
    esac
fi

install_pack_pkgurl $VERSION

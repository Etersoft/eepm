#!/bin/sh

PKGNAME=affinity3
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Affinity v3 creative suite (Wine based) from the official site"
URL="https://www.affinity.studio/"
RELEASE_NOTES_URL="https://www.affinity.studio/help/release-notes/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# The online installer has no version; the release-notes build is monotonic.
if [ "$VERSION" = "*" ] ; then
    VERSION="$(epm --quiet tool eget -q -U -O- "$RELEASE_NOTES_URL" \
        | grep -oE 'Improvements and fixes[^)]*\([0-9]+\)' \
        | head -n1 \
        | sed -n 's/.*(\([0-9][0-9]*\)).*/\1/p')"
    [ -n "$VERSION" ] || fatal "Can't get latest Affinity v3 build"
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

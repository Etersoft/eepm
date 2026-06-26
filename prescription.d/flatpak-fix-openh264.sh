#!/bin/sh

SUPPORTEDARCHES=''
DESCRIPTION="Install OpenH264 codec into the Flatpak runtime (H.264 support)"

. $(dirname $0)/common.sh

assure_root

is_command flatpak || fatal "flatpak is not installed. Run 'epm prescription flatpak' first."

# OpenH264 flatpak extension and its branch (matches org.freedesktop.Platform.openh264 version).
# Pass a version as an argument to override (e.g. epm prescription flatpak-fix-openh264 2.4.1).
EXTENSION="org.freedesktop.Platform.openh264"
OPENH264_VERSION="2.5.1"
for arg in "$@" ; do
    case "$arg" in
        [0-9]*.[0-9]*) OPENH264_VERSION="$arg" ;;
    esac
done

ARCH="$(epm print info -a)"
[ -n "$ARCH" ] || ARCH="$(uname -m)"

# The openh264 extension is shipped masked/empty by default, unmask it first (ignore if not masked)
flatpak mask --remove "$EXTENSION" 2>/dev/null

# Make sure the flathub remote is configured
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null

# Preferred (canonical) way: install the extension straight from flathub.
# It is idempotent: flatpak skips it if the codec is already deployed.
if flatpak install -y flathub "$EXTENSION//$OPENH264_VERSION" ; then
    info "OpenH264 $OPENH264_VERSION extension is installed for $ARCH."
    exit 0
fi

info "Could not install the extension from flathub, falling back to the manual recipe."

# Fallback: replicate the Stapler 'aides' recipe (https://wiki.geekcom.org/ru/guides/openh264_fix)
# Download the archive that bundles openh264-<ver>.tar.gz and unpack it into the runtime dir.
[ "$ARCH" = "x86_64" ] || fatal "Manual fallback supports only x86_64 (got $ARCH)"

RUNTIMEDIR="/var/lib/flatpak/runtime/$EXTENSION/$ARCH/$OPENH264_VERSION"

TMPDIR="$(mktemp -d)" || fatal "Can't create a temporary directory"
trap 'rm -rf "$TMPDIR"' EXIT INT

OUTER="$TMPDIR/install_openh264_v2.tar.gz"
epm tool eget -O "$OUTER" https://github.com/Nospire/fx/releases/download/v2.0.0/install_openh264_v2.tar.gz \
    || fatal "Can't download the OpenH264 archive"

# Unpack the outer archive (it contains openh264-<ver>.tar.gz)
epm tool erc -C "$TMPDIR" unpack "$OUTER" || fatal "Can't unpack $OUTER"

INNER="$(find "$TMPDIR" -name 'openh264-*.tar.gz' | head -n1)"
[ -n "$INNER" ] || fatal "Can't find openh264-*.tar.gz inside the archive"

# Extract the codec right into the Flatpak runtime directory
mkdir -p "$RUNTIMEDIR" || fatal "Can't create $RUNTIMEDIR"
epm tool erc -C "$RUNTIMEDIR" unpack "$INNER" || fatal "Can't unpack $INNER into $RUNTIMEDIR"

info "OpenH264 codec is installed into $RUNTIMEDIR."

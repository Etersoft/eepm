#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

PRODUCT=trivalent
PRODUCTDIR=/opt/trivalent

. $(dirname $0)/common-chromium-browser.sh

# need for Qt theme
RPM_SUFFIX=$(basename "$4" .rpm | sed "s/^$3-//")
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
if epm tool eget -O "$tmpdir/qt6-ui.rpm" "https://repo.secureblue.dev/Packages/trivalent-qt6-ui-$RPM_SUFFIX.rpm"; then
    epm assure rpm2cpio cpio
    (cd "$BUILDROOT" && rpm2cpio "$tmpdir/qt6-ui.rpm" | cpio -idmu --quiet ./usr/lib64/trivalent/libqt6_shim.so) || fatal "Can't extract Trivalent Qt6 shim"
    pack_file /usr/lib64/trivalent/libqt6_shim.so
fi

move_to_opt /usr/lib64/trivalent

remove_file $PRODUCTDIR/trivalent.sh
rm -f "$BUILDROOT/usr/bin/$PRODUCT"

cat <<'EOF' | create_exec_file /usr/bin/trivalent
#!/usr/bin/bash

set -ueo pipefail
shopt -s nullglob

declare -rx LD_LIBRARY_PATH=""
declare -rx LD_AUDIT=""
declare -rx LD_PROFILE=""
declare -rx LD_PRELOAD=""
declare -rx PATH="/usr/bin:/bin"
declare -rx HOME="${HOME}"
declare -rx XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-}"
declare -rx XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-}"
declare -rx XAUTHORITY="${XAUTHORITY:-}"
declare -rx DISPLAY="${DISPLAY:-}"
declare -rx WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-}"

if [ "$(id -u)" -eq 0 ]; then
    echo 'Trivalent must not be run as root.'
    exit 1
fi

declare -r ARCH="$(uname -m)"
[ "$ARCH" != "x86_64" ] || declare -rx GLIBC_TUNABLES="glibc.cpu.x86_ibt=on:glibc.cpu.x86_shstk=permissive"

declare -r CHROMIUM_NAME=trivalent
declare -rx CHROME_WRAPPER=/usr/bin/trivalent
declare -rx CHROME_DESKTOP=trivalent.desktop
declare -rx CHROME_VERSION_EXTRA=custom
declare -rx GNOME_DISABLE_CRASH_DIALOG=SET_BY_GOOGLE_CHROME
declare -r HERE=/opt/trivalent

declare USE_VULKAN="${USE_VULKAN:-false}"
declare USE_WAYLAND="${USE_WAYLAND:-}"
declare FEATURES=""
declare CHROMIUM_FLAGS=""

for conf_file in /etc/trivalent/trivalent.conf.d/*.conf; do
    source "$conf_file"
done

declare -rix BROWSER_LOG_LEVEL="${BROWSER_LOG_LEVEL:-0}"
declare CHROMIUM_SYSTEM_FLAGS=""
[ ! -f /etc/trivalent/trivalent.conf ] || source /etc/trivalent/trivalent.conf
declare -r CHROMIUM_ALL_FLAGS="${CHROMIUM_FLAGS} ${CHROMIUM_SYSTEM_FLAGS}"

declare BWRAP_ARGS=""
if command -v bwrap >/dev/null; then
    declare -r TMPFS_CACHE_DIR="/tmp/${CHROMIUM_NAME}_cache/"
    mkdir -p "$TMPFS_CACHE_DIR"

    BWRAP_ARGS="--dev-bind / / --cap-drop ALL"
    if [[ -r /etc/ld.so.preload ]]; then
        BWRAP_ARGS+=" --ro-bind-try /dev/null /etc/ld.so.preload"
    fi
    BWRAP_ARGS+=" --bind ${TMPFS_CACHE_DIR} ${HOME}/.cache"
    BWRAP_ARGS+=" --setenv GDK_DISABLE icon-nodes"
fi

exec < /dev/null
exec > >(exec cat)
exec 2> >(exec cat >&2)

if [ -n "$BWRAP_ARGS" ]; then
    # shellcheck disable=SC2086
    exec bwrap ${BWRAP_ARGS} -- "$HERE/trivalent" ${CHROMIUM_ALL_FLAGS} "$@"
fi
# shellcheck disable=SC2086
exec "$HERE/trivalent" ${CHROMIUM_ALL_FLAGS} "$@"
EOF

set_alt_alternatives 85
add_chromium_deps

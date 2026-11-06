#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# registerProtocolClient() runs xdg-settings, which invokes xdg-mime and
# changes the user's default protocol handler
XDG_SETTINGS='x\x00d\x00g\x00-\x00s\x00e\x00t\x00t\x00i\x00n\x00g\x00s\x00'
NO_XDG_SETTINGS='/\x00d\x00e\x00v\x00/\x00n\x00u\x00l\x00l\x00/\x00/\x00/\x00'
check_binary "$BUILDROOT/opt/lolka-x/bin/lolka-x" "$XDG_SETTINGS" || fatal "Can't find xdg-settings in Lolka X"
patch_binary "$BUILDROOT/opt/lolka-x/bin/lolka-x" "$XDG_SETTINGS" "$NO_XDG_SETTINGS"

# A non-empty, invalid feed override makes Config::feedBaseUrl() return an
# empty URL, so StartupUpdater::shouldRun() skips the updater entirely.
add_bin_exec_command lolka-x /opt/lolka-x/bin/lolka-x
subst 's|^exec |exec env LOLKA_UPDATE_URL=disabled: |' "$BUILDROOT/usr/bin/lolka-x"

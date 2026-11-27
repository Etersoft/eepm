#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=sunshine

. $(dirname $0)/common.sh

add_conflicts sunshine

epm assure patchelf
epm assure readelf binutils

# Older Sunshine links Fedora ICU (libicuuc.so.77 for the Fedora 43 build), ALT has no such ICU:
# install it via epm play libicu<major> (a fixed URL, so it works with --ipfs too)
ICU_MAJOR="$(a='' patchelf --print-needed "usr/bin/sunshine" | sed -n 's|^libicuuc\.so\.\([0-9][0-9]*\)$|\1|p')"
if [ -n "$ICU_MAJOR" ] && [ ! -e /usr/lib64/libicuuc.so.$ICU_MAJOR ] && [ ! -e /usr/lib/libicuuc.so.$ICU_MAJOR ] ; then
    epm play libicu$ICU_MAJOR || fatal "Can't install libicu$ICU_MAJOR (needed for libicuuc.so.$ICU_MAJOR)"
fi

a='' patchelf --replace-needed "libappindicator3.so.1" "libayatana-appindicator3.so.1" "usr/bin/sunshine"

# newer Sunshine (2026.1127+) has a Qt 6 tray, it uses system Qt 6
qtlibs="$(a='' patchelf --print-needed "usr/bin/sunshine" | grep '^libQt6')"
[ -n "$qtlibs" ] && add_unirequires $qtlibs

fix_desktop_file "^Exec=.*" "Exec=sunshine"

# Older Sunshine has libminiupnpc in NEEDED, but does not import any symbols from it,
# drop this unused entry. Newer Sunshine uses it (libminiupnpc.so.21 is in ALT).
if ! LC_ALL=C a='' readelf --dyn-syms -W "usr/bin/sunshine" | grep -qiE ' UND .*upnp' ; then
    a='' patchelf --print-needed "usr/bin/sunshine" | grep '^libminiupnpc\.so\.' | while read -r lib ; do
        a='' patchelf --remove-needed "$lib" "usr/bin/sunshine" || fatal
    done
fi

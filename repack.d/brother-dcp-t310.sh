#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=dcpt310
PRODUCTDIR=/opt/brother/Printers/dcpt310

. $(dirname $0)/common.sh

# upstream rpm name is dcpt310pdrv, publish it under a human readable name
subst "s|^Name:.*|Name: brother-dcp-t310|" "$SPEC"

# cups itself, plus perl for the lpd wrapper and the brother_lpdwrapper filter
add_requires cups perl

# brprintconf_dcpt310 and brdcpt310filter are 32-bit (i386) ELF binaries:
#   brprintconf_dcpt310 -> libc.so.6
#   brdcpt310filter     -> libstdc++.so.6 libm.so.6 libgcc_s.so.1 libc.so.6
# pull the matching 32-bit runtime libraries on ALT (autoreq is off for repack)
add_requires i586-glibc-core i586-libstdc++6 i586-libgcc1

# Reproduce statically what /opt/brother/Printers/dcpt310/cupswrapper/cupswrapperdcpt310
# does in its (now stripped) %post:
#   1) copies the PPD into the CUPS model dir so the model is discoverable
#   2) symlinks the perl lpd wrapper into the CUPS filter dir (the PPD's
#      *cupsFilter references brother_lpdwrapper_dcpt310; the wrapper derives
#      its base dir from readlink($0), so it must be reached via this symlink)
# We deliberately do NOT restart cups or run lpadmin from the package.

# 1) PPD into the CUPS model directory (cups-driverd scans /usr/share/cups/model)
install_file "$PRODUCTDIR/cupswrapper/brother_dcpt310_printer_en.ppd" \
    /usr/share/cups/model/Brother/brother_dcpt310_printer_en.ppd

# 2) CUPS filter symlink -> the wrapper shipped under /opt
mkdir -p "$BUILDROOT/usr/lib/cups/filter"
ln -snf "$PRODUCTDIR/cupswrapper/brother_lpdwrapper_dcpt310" \
    "$BUILDROOT/usr/lib/cups/filter/brother_lpdwrapper_dcpt310"
pack_file /usr/lib/cups/filter/brother_lpdwrapper_dcpt310

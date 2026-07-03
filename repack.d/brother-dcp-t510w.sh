#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=dcpt510w
PRODUCTDIR=/opt/brother/Printers/dcpt510w

. $(dirname $0)/common.sh

# upstream rpm name is dcpt510wpdrv, publish under a human readable name
subst "s|^Name:.*|Name: brother-dcp-t510w|" "$SPEC"

# cups itself, plus perl for the lpd wrapper and the brother_lpdwrapper filter
add_requires cups perl

# brprintconf_dcpt510w and brdcpt510wfilter are 32-bit (i386) ELF binaries:
#   brprintconf_dcpt510w -> libc.so.6
#   brdcpt510wfilter     -> libstdc++.so.6 libm.so.6 libgcc_s.so.1 libc.so.6
# pull the matching 32-bit runtime libraries on ALT (autoreq is off for repack)
add_requires i586-glibc-core i586-libstdc++6 i586-libgcc1

# Reproduce statically what /opt/brother/Printers/dcpt510w/cupswrapper/cupswrapperdcpt510w
# does in its (now stripped) %post:
#   1) copies the PPD into the CUPS model dir so the model is discoverable
#   2) symlinks the perl lpd wrapper into the CUPS filter dir
# We deliberately do NOT restart cups or run lpadmin from the package.

# 1) PPD into the CUPS model directory (cups-driverd scans /usr/share/cups/model)
install_file "$PRODUCTDIR/cupswrapper/brother_dcpt510w_printer_en.ppd" \
    /usr/share/cups/model/Brother/brother_dcpt510w_printer_en.ppd

# 2) CUPS filter symlink -> the wrapper shipped under /opt
mkdir -p "$BUILDROOT/usr/lib/cups/filter"
ln -snf "$PRODUCTDIR/cupswrapper/brother_lpdwrapper_dcpt510w" \
    "$BUILDROOT/usr/lib/cups/filter/brother_lpdwrapper_dcpt510w"
pack_file /usr/lib/cups/filter/brother_lpdwrapper_dcpt510w

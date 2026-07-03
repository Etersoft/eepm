#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=dcpt720dw
PRODUCTDIR=/opt/brother/Printers/dcpt720dw

. $(dirname $0)/common.sh

# upstream deb name is dcpt720dwpdrv, publish under a human readable name
subst "s|^Name:.*|Name: brother-dcp-t720dw|" "$SPEC"

# cups itself, plus perl for the lpd/perl filter and the brother_lpdwrapper filter
add_requires cups perl

# the printer filter binaries are native x86_64 ELF (64-bit only); autoreq is off
# for repack, so declare the sonames explicitly
add_unirequires "libc.so.6 libstdc++.so.6 libm.so.6 libgcc_s.so.1"

# ship 64-bit only: drop the unused i686 binaries (remove_file cleans the spec too)
remove_file "$PRODUCTDIR/lpd/i686/brdcpt720dwfilter"
remove_file "$PRODUCTDIR/lpd/i686/brprintconf_dcpt720dw"

# Reproduce statically what the deb %post + cupswrapper do (stripped in repack):
#   1) pick the x86_64 binaries via the flat lpd/ symlinks filter_dcpt720dw calls
#   2) /usr/bin/brprintconf_dcpt720w convenience link
#   3) copy the PPD into the CUPS model dir so the model is discoverable
#   4) symlink the CUPS filter to the lpd wrapper shipped under /opt
# We deliberately do NOT restart cups or run lpadmin from the package.

# 1) x86_64 binaries reachable at the flat lpd/ path the filter_dcpt720dw perl uses
ln -snf "$PRODUCTDIR/lpd/x86_64/brdcpt720dwfilter" "$BUILDROOT$PRODUCTDIR/lpd/brdcpt720dwfilter"
ln -snf "$PRODUCTDIR/lpd/x86_64/brprintconf_dcpt720dw" "$BUILDROOT$PRODUCTDIR/lpd/brprintconf_dcpt720dw"
pack_file "$PRODUCTDIR/lpd/brdcpt720dwfilter"
pack_file "$PRODUCTDIR/lpd/brprintconf_dcpt720dw"

# 2) /usr/bin convenience link
mkdir -p "$BUILDROOT/usr/bin"
ln -snf "$PRODUCTDIR/lpd/brprintconf_dcpt720dw" "$BUILDROOT/usr/bin/brprintconf_dcpt720dw"
pack_file /usr/bin/brprintconf_dcpt720dw

# 3) PPD into the CUPS model directory (cups-driverd scans /usr/share/cups/model)
install_file "$PRODUCTDIR/cupswrapper/brother_dcpt720dw_printer_en.ppd" \
    /usr/share/cups/model/Brother/brother_dcpt720dw_printer_en.ppd

# 4) CUPS filter symlink -> the wrapper shipped under /opt
mkdir -p "$BUILDROOT/usr/lib/cups/filter"
ln -snf "$PRODUCTDIR/cupswrapper/brother_lpdwrapper_dcpt720dw" \
    "$BUILDROOT/usr/lib/cups/filter/brother_lpdwrapper_dcpt720dw"
pack_file /usr/lib/cups/filter/brother_lpdwrapper_dcpt720dw

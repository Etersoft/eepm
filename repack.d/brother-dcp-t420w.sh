#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=dcpt420w
PRODUCTDIR=/opt/brother/Printers/dcpt420w

. $(dirname $0)/common.sh

# upstream deb name is dcpt420wpdrv, publish under a human readable name
subst "s|^Name:.*|Name: brother-dcp-t420w|" "$SPEC"

# cups itself, plus perl for the lpd/perl filter and the brother_lpdwrapper filter
add_requires cups perl

# the printer filter binaries are native x86_64 ELF (64-bit only); autoreq is off
# for repack, so declare the sonames explicitly
add_unirequires "libc.so.6 libstdc++.so.6 libm.so.6 libgcc_s.so.1"

# ship 64-bit only: drop the unused i686 binaries (remove_file cleans the spec too)
remove_file "$PRODUCTDIR/lpd/i686/brdcpt420wfilter"
remove_file "$PRODUCTDIR/lpd/i686/brprintconf_dcpt420w"

# Reproduce statically what the deb %post + cupswrapper do (stripped in repack):
#   1) pick the x86_64 binaries via the flat lpd/ symlinks filter_dcpt420w calls
#   2) /usr/bin/brprintconf_dcpt420w convenience link
#   3) copy the PPD into the CUPS model dir so the model is discoverable
#   4) symlink the CUPS filter to the lpd wrapper shipped under /opt
# We deliberately do NOT restart cups or run lpadmin from the package.

# 1) x86_64 binaries reachable at the flat lpd/ path the filter_dcpt420w perl uses
ln -snf "$PRODUCTDIR/lpd/x86_64/brdcpt420wfilter" "$BUILDROOT$PRODUCTDIR/lpd/brdcpt420wfilter"
ln -snf "$PRODUCTDIR/lpd/x86_64/brprintconf_dcpt420w" "$BUILDROOT$PRODUCTDIR/lpd/brprintconf_dcpt420w"
pack_file "$PRODUCTDIR/lpd/brdcpt420wfilter"
pack_file "$PRODUCTDIR/lpd/brprintconf_dcpt420w"

# 2) /usr/bin convenience link
mkdir -p "$BUILDROOT/usr/bin"
ln -snf "$PRODUCTDIR/lpd/brprintconf_dcpt420w" "$BUILDROOT/usr/bin/brprintconf_dcpt420w"
pack_file /usr/bin/brprintconf_dcpt420w

# 3) PPD into the CUPS model directory (cups-driverd scans /usr/share/cups/model)
install_file "$PRODUCTDIR/cupswrapper/brother_dcpt420w_printer_en.ppd" \
    /usr/share/cups/model/Brother/brother_dcpt420w_printer_en.ppd

# 4) CUPS filter symlink -> the wrapper shipped under /opt
mkdir -p "$BUILDROOT/usr/lib/cups/filter"
ln -snf "$PRODUCTDIR/cupswrapper/brother_lpdwrapper_dcpt420w" \
    "$BUILDROOT/usr/lib/cups/filter/brother_lpdwrapper_dcpt420w"
pack_file /usr/lib/cups/filter/brother_lpdwrapper_dcpt420w

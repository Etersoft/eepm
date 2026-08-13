#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

VERSION=1.18
PKGNAME=$PRODUCT-$VERSION

erc --here unpack "$TAR" || fatal

INNER_TAR=$(find . -maxdepth 2 -type f -name 'Sharp-*-UD-PCL6-64bit.tar.gz' | head -n 1)
[ -n "$INNER_TAR" ] || fatal "Can't find Sharp Universal PCL6 tarball"
erc --here unpack "$INNER_TAR" || fatal

DRIVERDIR=$(find . -type f -name 'Sharp-UD-Color-PCL6.ppd' -exec dirname {} \; | head -n 1)
[ -n "$DRIVERDIR" ] || fatal "Can't find Sharp Universal Color PCL6 PPD"
[ -f "$DRIVERDIR/Sharp-UD-Mono-PCL6.ppd" ] || fatal "Can't find Sharp Universal Mono PCL6 PPD"
[ -x "$DRIVERDIR/filter/sv2epjl" ] || fatal "Can't find executable Sharp sv2epjl filter"
[ -f "$DRIVERDIR/mime/sv2ecnv.convs" ] || fatal "Can't find Sharp MIME conversion rules"
[ -f "$DRIVERDIR/mime/sv2etyp.types" ] || fatal "Can't find Sharp MIME type rules"

COLOR_PPD="$DRIVERDIR/Sharp-UD-Color-PCL6.ppd"
MONO_PPD="$DRIVERDIR/Sharp-UD-Mono-PCL6.ppd"

for PPD in "$COLOR_PPD" "$MONO_PPD" ; do
    sed -i 's/\r$//' "$PPD" || fatal "Can't normalize $PPD line endings"
    # Named constraints require matching resolvers, which the Sharp PPDs lack.
    sed -i -E 's/^\*cupsUIConstraints[[:space:]]+[^:]+:/\*cupsUIConstraints:/' "$PPD" \
        || fatal "Can't repair cupsUIConstraints in $PPD"
    # Add the explicit PDF to PCL XL chain required by modern CUPS.
    sed -i '/^\*cupsFilter:.*application\/vnd.cups-pxl.*sv2epjl/i\
*cupsFilter2: "application/pdf application/vnd.cups-pxl 66 gstopxl"\
*cupsFilter2: "application/vnd.cups-pdf application/vnd.cups-pxl 66 gstopxl"\
*cupsFilter2: "application/postscript application/vnd.cups-pxl 100 gstopxl"\
*cupsFilter2: "application/vnd.cups-postscript application/vnd.cups-pxl 100 gstopxl"\
*cupsFilter2: "application/vnd.cups-pxl application/vnd.sharp-pcl6 100 sv2epjl"' "$PPD" || fatal
done

# Avoid monochrome mode when CUPS imports the color PPD.
sed -i 's/^\*DefaultColorModel:[[:space:]]*Automatic/\*DefaultColorModel: RGB/' "$COLOR_PPD" || fatal

install -Dm0555 "$DRIVERDIR/filter/sv2epjl" "usr/lib/cups/filter/sv2epjl"
install -Dm0644 "$COLOR_PPD" "usr/share/cups/model/Sharp/Sharp-UD-Color-PCL6.ppd"
install -Dm0644 "$MONO_PPD" "usr/share/cups/model/Sharp/Sharp-UD-Mono-PCL6.ppd"
install -Dm0644 "$DRIVERDIR/mime/sv2ecnv.convs" "usr/share/cups/mime/sv2ecnv.convs"
install -Dm0644 "$DRIVERDIR/mime/sv2etyp.types" "usr/share/cups/mime/sv2etyp.types"

erc pack "$PKGNAME.tar" usr || fatal

cat <<EOF >"$PKGNAME.tar.eepm.yaml"
name: $PRODUCT
version: $VERSION
group: System/Configuration/Printing
license: GPL-2.0-or-later and LicenseRef-Sharp
url: https://sharpone.sharp.co.uk/
summary: Sharp Universal PCL6 printer driver for Linux
description: Sharp Universal Color and Mono PCL6 printer driver for Linux.
requires: cups cups-filters ghostscript
EOF

return_tar "$PKGNAME.tar"

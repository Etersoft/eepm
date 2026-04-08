#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# Xerox_B215_Linux_PrintDriver_Utilities.tar.gz
BASENAME=$(basename $TAR .tar.gz)

erc --here unpack $TAR || fatal
cd uld || fatal

mkdir usr
mkdir opt
mkdir etc

VERSION=$(cat "noarch/.version-printer")

# printer drivers install 
mkdir -p "usr/share/cups/model/"
mv "noarch/share/ppd/" "usr/share/cups/model/xerox/" 
install -Dm0755 "x86_64/libscmssc.so" "usr/lib/libscmssc.so"
install -Dm0755 "x86_64/smfpnetdiscovery" "usr/lib/cups/backend/smfpnetdiscovery"
install -Dm0755 "x86_64/pstosecps" "usr/lib/cups/filter/pstosecps"
install -Dm0755 "x86_64/rastertospl" "usr/lib/cups/filter/rastertospl"

# scanner drivers install
SANELIB=usr/lib/sane
if [ "$(epm print info -b)" = "64" ] ; then
    SANELIB=usr/lib64/sane
    [ -d /usr/lib/x86_64-linux-gnu ] && SANELIB=usr/lib/x86_64-linux-gnu/sane
fi

install -Dm0644 "x86_64/libsane-smfp.so.1.0.1" "$SANELIB/libsane-smfp.so.1.0.1"

( cd "$SANELIB" && ln -s libsane-smfp.so.1.0.1 libsane-smfp.so.1 && ln -s libsane-smfp.so.1.0.1 libsane-smfp.so )

install -Dm0644 "noarch/etc/smfp.conf" "etc/sane.d/smfp.conf"
install -dm0755 "etc/sane.d/dll.d"

echo smfp > "etc/sane.d/dll.d/smfp-scanner"
echo xerox_mfp-smfp > "etc/sane.d/dll.d/smfp-scanner-fix"

# part from aur, i don't know what is going on here
install -dm0755 "usr/lib/udev/rules.d"
(
    OEM_FILE="noarch/oem.conf"
    INSTALL_LOG_FILE=/dev/null
    . "noarch/scripting_utils"
    . "noarch/package_utils"
    . "noarch/scanner-script.pkg"
    fill_full_template "noarch/etc/smfp.rules.in" "usr/lib/udev/rules.d/60-smfp-xerox.rules"
)

install -Dm0644 "noarch/oem.conf" "opt/xerox/scanner/share/oem.conf"

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr opt etc || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: System/Configuration/Printing
license: Proprietary
url: https://www.xerox.com/
summary: Xerox SPL printer and scanner driver
description: Xerox SPL printer and scanner driver for Linux.
EOF

return_tar $PKGNAME.tar

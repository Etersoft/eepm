#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# Xerox_B215_Linux_PrintDriver_Utilities.tar.gz
BASENAME=$(basename $TAR .tar.gz)

erc unpack $TAR || fatal
cd *

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
install -Dm0644 "x86_64/libsane-smfp.so.1.0.1" "usr/lib/sane/libsane-smfp.so.1.0.1"

pushd "usr/lib/sane/"
ln -s libsane-smfp.so.1.0.1 libsane-smfp.so.1
ln -s libsane-smfp.so.1.0.1 libsane-smfp.so
popd

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

return_tar $PKGNAME.tar

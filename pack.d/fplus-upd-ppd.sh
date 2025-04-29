#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# Lexmark-UPD-PPD-Files-1.0-05252022.x86_64.rpm

erc unpack $TAR || fatal

cd Драйвер*/print

BASENAME=$(basename Generic-UPD-PPD*.x86_64.rpm .rpm)
VERSION=$(echo $BASENAME | sed -e 's|Generic-UPD-PPD-Files-||' | sed -e 's|.x86_64||')

erc unpack $BASENAME.rpm || fatal

# Install PPDs
PPD_ROOT="usr/share/cups/model"

install -Dm644 -t "$PPD_ROOT/Fplus_PPD/Fplus-generic.ppd" usr/local/Generic/ppd/Generic-UPD-PPD-Files/GlobalPPD_1.4/*.ppd

# Install filter scripts
install -Dm755 -t "usr/lib/cups/filter/" "usr/local/Generic/ppd/Generic-UPD-PPD-Files/GlobalPPD_1.4/LexFaxPnHFilter"
install -Dm755 -t "usr/lib/cups/filter/" "usr/local/Generic/ppd/Generic-UPD-PPD-Files/GlobalPPD_1.4/queueCreation.sh"

# Install filter bins
install -Dm755 -t "usr/lib/cups/filter/" "usr/local/Generic/ppd/Generic-UPD-PPD-Files/GlobalPPD_1.4/lib64/LexCommandFileFilterG2"
install -Dm755 -t "usr/lib/cups/filter/" "usr/local/Generic/ppd/Generic-UPD-PPD-Files/GlobalPPD_1.4/lib64/cupsversion"

# Install license file
install -Dm644 -t "usr/share/doc/$PRODUCT/" usr/local/Generic/ppd/Generic-UPD-PPD-Files/License_EU*.txt

rm -fr usr/local

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr || fatal

return_tar $PKGNAME.tar
